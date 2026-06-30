import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import authRoutes from "./routes/auth.js";
import userRoutes from "./routes/user.js";
import pool from "./db.js";
import http from 'http';
import { Server } from "socket.io";
import { joinQueue, findMatch, leaveQueue } from "./controllers/matchmaking.js";
import { connectRedis } from "./redis_client.js";
dotenv.config();

await connectRedis();
const app=express();
const server=http.createServer(app);
const io=new Server(server,{
  cors:{
    origin:"*",
  }
});


pool.connect()
  .then(() => console.log("✅ Connected to PostgreSQL"))
  .catch(err => console.error("❌ Database connection error:", err));
app.use(cors());
app.use(express.json());
app.use("/api/user", userRoutes);
app.use("/api/auth", authRoutes);

app.listen(process.env.PORT, '0.0.0.0', () => {
  console.log("APP RUNNING ON PORT " + process.env.PORT);
});

let queue=[];
io.on("connection",(socket)=>{
  console.log("User connected: ",socket.id);
  socket.on("join_room",async ({roomId,username})=>{
    socket.join(roomId);
    console.log(`👥 ${username} joined room: ${roomId}`);
    socket.to(roomId).emit("player_joined",{username});

  });

  socket.on("send_message",({roomId,sender,message})=>{
    console.log(`💬 Message from ${sender} in room ${roomId}: ${message}`);
    io.to(roomId).emit("receive_message",{sender,message});
  });

  socket.on("player_ready",({roomId,username})=>{
    console.log(`✅ ${username} is ready in room ${roomId}`);
    io.to(roomId).emit("ready_update", {
      'username': username,
      'ready': true  // or false depending on context
    });


  });

  socket.on("join_queue",async (data)=>{
    const player = { id: socket.id, username: data.username, mode: data.preferredMode,rank:data.rank };
    const joined = await joinQueue(player);
    if (!joined) return;
    const match = await findMatch(player.rank);
    if (match) {
      console.log(match['player1_id']);
      console.log(match['player2_id']);
      io.to(match['player1_id']).emit("match_found", match);
      io.to(match['player2_id']).emit("match_found", match);
    }
  });

  socket.on("leave_queue",async () => {
    await leaveQueue(socket.id);
  });

  socket.on("disconnect",async ()=>{
    await leaveQueue(socket.id);
    console.log("User disconnected:", socket.id);
  });
});



server.listen(process.env.SERVER_PORT,'0.0.0.0',()=>{
  console.log("SERVER RUNNING ON PORT ",process.env.SERVER_PORT)
})
