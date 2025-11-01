import { createClient } from "redis";

const redisClient = createClient({
  url: process.env.REDIS_URL || "redis://localhost:6379",
});

redisClient.on("error", (err) => console.error("❌ Redis Client Error", err));

let isConnected = false;

export async function connectRedis() {
  if (!isConnected) {
    await redisClient.connect();
    console.log("✅ Connected to Redis successfully");
    isConnected = true;
  }
}

export default redisClient;
