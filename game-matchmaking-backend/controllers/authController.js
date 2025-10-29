import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
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
        const token=jwt.sign({id:user.id,email:user.email},process.env.JWT_SECRET,{expiresIn:"7d"});
        res.json({token,user:{id:user.id,username:user.username,email:user.email}})
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