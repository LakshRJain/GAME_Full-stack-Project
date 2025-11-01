import pool from "../db.js";
import bcrypt from "bcrypt";

export const getProfile = async (req,res)=>{
    try{
        const userId=req.user.id;
        const result=await pool.query(
            'SELECT id, username, email, "rank", games_played, wins, preferred_game_mode, country, avatar_url, created_at FROM users WHERE id=$1',
            [userId]
        );

        if(result.rows.length===0){
            return res.status(404).json({message:"User not found"});
        }
        console.log(result.rows[0]);
        res.json(result.rows[0]);
    }catch(err){
        console.error(err);
        res.status(500).json({message:"Server error"});
    }
}

export const updateProfiler = async (req,res) => {
    try{
        const userId = req.user.id;
        const {username, country, preferred_game_mode, avatar_url}=req.body;
        const result = await pool.query(
            `UPDATE users 
            SET username= COALESCE($1,username), 
            country= COALESCE($2,country),
            preferred_game_mode= COALESCE($3,preferred_game_mode),
            avatar_url= COALESCE($4,avatar_url) 
            WHERE id=$5 RETURNING id, username, email, "rank", games_played, wins, preferred_game_mode, country, avatar_url`,
            [username,country,preferred_game_mode,avatar_url,userId]
        );
        res.json(result.rows[0]);
    }catch(err){
        console.error(err);
        res.status(500).json({message:"Serner error"});
    }
}

export const changePassword = async (req,res)=>{
    try{
        const userId=req.user.id;
        const {oldPassword,newPassword}=req.body;

        const result=await pool.query(
            "SELECT password FROM users where id=$1",[userId]
        );

        const user = result.rows[0];
        const isMatch = await bcrypt.compare(oldPassword,user.password);
        if(!isMatch){
            return res.status(401).json({message:"Old password is incorrect"});
        }
        const hashed=await bcrypt.hash(newPassword,10);
        await pool.query(
            "UPDATE users SET password=$1 WHERE id=$2",[hashed,userId]
        );
        res.json({message:"Pasword changed successfully"});

    }catch(err){
        console.error(err);
        res.status(500).json({message:"Serevr error"});
    }
}

export const getAllPlayers = async(req,res)=>{
    try{
        const result=await pool.query(
            "SELECT id,username,email FROM users ORDER BY id ASC"
        )
        res.json(result.rows);

    }catch(err){
        console.error(err);
        res.status(500).json({mesage:"Serever error"});
    }
}