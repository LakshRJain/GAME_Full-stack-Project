import bcrypt from "bcrypt";
import jwt, { decode } from "jsonwebtoken";
import pool from "../db.js";
import dotenv from "dotenv";
dotenv.config();

export const register = async(req,res)=>{
    const {username,email,password}=req.body;
    try{
        const hashedPassword=await bcrypt.hash(password,10);
        const result=await pool.query(
            "INSERT INTO users (username,email,password) VALUES ($1,$2,$3) RETURNING id,username,email",[username,email,hashedPassword]
        );
        res.status(201).json({message:"user registered",user:result.rows[0]});
    }catch(err){
        console.error(err);
        res.status(500).json({message:"User alreasy exist or DB errro"})
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