import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import pool from "../db.js";import dotenv from "dotenv";
dotenv.config();

export const register = async(req,res)=>{
    // Handle both camelCase and snake_case from frontend
    const {username,email,password,country,rank,avatarUrl,avatar_url}=req.body;
    const finalAvatarUrl = avatarUrl || avatar_url;
    
    try{
        // Validate required fields
        if(!username || !email || !password){
            return res.status(400).json({message:"Username, email, and password are required"});
        }
        
        const hashedPassword=await bcrypt.hash(password,10);
        
        // Use fully quoted column names to avoid any reserved word issues
        const query = `INSERT INTO users (
            "username",
            "email", 
            "password", 
            "games_played", 
            "wins", 
            "country", 
            "rank", 
            "avatar_url"
        ) VALUES ($1, $2, $3, 0, 0, $4, $5, $6) 
        RETURNING "id", "username", "email"`;
        const params = [
            username,
            email,
            hashedPassword,
            country || null,
            rank || null,
            finalAvatarUrl || null
        ];
        
        console.log("=== REGISTRATION DEBUG ===");
        console.log("Request body:", JSON.stringify(req.body, null, 2));
        console.log("Executing query:", query);
        console.log("With parameters:", params.map((p, i) => `$${i+1}: ${typeof p === 'string' ? p.substring(0, 20) : p}`));
        console.log("========================");
        
        const result=await pool.query(query, params);
        res.status(201).json({message:"user registered",user:result.rows[0]});
    }catch(err){
        console.error("=== REGISTRATION ERROR ===");
        console.error("Full error object:", JSON.stringify(err, null, 2));
        console.error("Error code:", err.code);
        console.error("Error message:", err.message);
        console.error("Error detail:", err.detail);
        console.error("Error position:", err.position);
        console.error("Error hint:", err.hint);
        console.error("==========================");
        
        if(err.code === '23505'){ // Unique violation
            return res.status(409).json({message:"User already exists"});
        }
        if(err.code === '42703'){ // Undefined column
            return res.status(500).json({
                message:"Database schema error", 
                error: err.message,
                position: err.position,
                hint: err.hint || "Please check if all columns exist in the users table"
            });
        }
        res.status(500).json({message:"User already exists or DB error", error: err.message})
    }
}

export const login=async(req,res)=>{
    const {email,password}=req.body;
    try{
        const result=await pool.query(
            "SELECT * FROM users WHERE email=$1",[email]
        );
        const user=result.rows[0];
        if(!user){
            return res.status(404).json({message:"User not found"});
        }
        const isValid=await bcrypt.compare(password,user.password);
        if(!isValid){
            return res.status(401).json({message:"Invalid credentials:"});
        }
        console.log("Password verified\n");
        const accessToken=jwt.sign({id:user.id,email:user.email},process.env.JWT_SECRET,{expiresIn:"15m"});
        const refereshToken=jwt.sign({id:user.id,email:user.email},process.env.JWT_REFRESH_SECRET,{expiresIn:"7d"})
        await pool.query(
            "UPDATE users SET refresh_token=$1 WHERE id=$2",[refereshToken,user.id]
        );

        res.json({accessToken,refereshToken,user:{id:user.id,username:user.username,email:user.email}})
    }catch(err){
        console.error(err);
        res.status(500).json({error:"Server error"});
    }
}

export const removeUser=async(req,res)=>{
    const {email}=req.body;
    try{
        const result  =await pool.query(
            "DELETE FROM users WHERE email=$1 RETURNING id,username,email",[email]
        );
        const user=result.rows[0];
        res.status(200).json({message:"User deleted",user});
    }catch(err){
        console.error(err);
        console.error(err);
        res.status(500).jaon({message:"Serevr error"});
    }
}

export const refreshToken = async (req,res)=>{
    const {token}=req.body;
    if(!token) return res.status(401).json({message:"No token provided"});
    try{
        const decoded = jwt.verify(token,process.env.JWT_REFRESH_SECRET);
        const result=await pool.query("SELECT refresh_token FROM users WHERE id=$1",[decoded.id]);
        const storedToken=result.rows[0]?.refresh_token;

        if(storedToken!==token){
            return res.status(403).json({message:"Invalid refresh token"});
        }

        const newAccessToken=jwt.sign({id:decoded.id,email:decoded.email},process.env.JWT_SECRET,{expiresIn:"15m"});
        const newRefreshToken=jwt.sign({id:decoded.id,email:decoded.email},process.env.JWT_REFRESH_SECRET,{expiresIn:"7d"});

        await pool.query(
            "UPDATE users SET refresh_token=$1 WHERE id=$2",[newRefreshToken,decoded.id]
        );
        res.json({accessToken:newAccessToken,refereshToken:newRefreshToken});


    }catch(err){
        console.error(err);
        res.status(403).json({message:"Invalid or Expires Refersh token"});
    }   
}

export const logout = async(req,res)=>{
    try{   
        const userId=req.user.id;
        await pool.query("UPDATE users SET refresh_token=NULL WHERE id=$1",[userId]);
        res.json({message:"Logged out successfully"});
    }catch(err){
        console.error(err);
        res.status(500).json({message:"Server error"});
    }
}