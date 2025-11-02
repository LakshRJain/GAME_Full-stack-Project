import redisClient from "../redis_client.js";
import db from "../db.js"; // PostgreSQL client
import { v4 as uuidv4 } from "uuid";

const rankOrder = ["Iron", "Bronze", "Silver", "Gold"];

const queueKeyForRank = (rank) => `matchmaking_queue_${rank}`;

export const joinQueue = async (player) => {
    const queueKey = queueKeyForRank(player.rank);
    const players = JSON.parse(await redisClient.get(queueKey)) || [];
    
    const filtered = players.filter(
        (p) => p.id !== player.id && p.username !== player.username
    );

    filtered.push(player);
    await redisClient.set(queueKey, JSON.stringify(filtered));

    console.log(`✅ ${player.username} joined the queue ${queueKey}`);
    return true;
};

export const leaveQueue = async (socketId) => {
    for (const rank of rankOrder) {
        const queueKey = queueKeyForRank(rank);
        const players = JSON.parse(await redisClient.get(queueKey)) || [];
        
        const exists = players.some((p) => p.id === socketId);
        if (exists) {
        const updated = players.filter((p) => p.id !== socketId);
        await redisClient.set(queueKey, JSON.stringify(updated));
        console.log(`🚪 Player with ID ${socketId} left ${rank} queue`);
        return;
        }
    }
};

export const findMatch = async (rank) => {
  const rankIndex = rankOrder.indexOf(rank);
  if (rankIndex === -1) {
    console.error(`❌ Invalid rank: ${rank}`);
    return null;
  }

  const currentKey = queueKeyForRank(rank);
  const players = JSON.parse(await redisClient.get(currentKey)) || [];

  if (players.length >= 2) {
    const match = { id: Date.now(), players: players.slice(0, 2) };
    const [p1, p2] = match.players;
    const room = await createMatchRoom(p1, p2);
    await redisClient.set(currentKey, JSON.stringify(players.slice(2)));
    console.log(`🎮 Match found in ${rank}: ${match.players.map(p => p.username).join(" vs ")}`);
    console.log(`🎮 Match found and room created: ${room.room_id}`);
    return room;
  }

  const upperRank = rankOrder[rankIndex + 1];
  if (upperRank) {
    const upperKey = queueKeyForRank(upperRank);
    const upperPlayers = JSON.parse(await redisClient.get(upperKey)) || [];
    if (players.length >= 1 && upperPlayers.length >= 1) {
      const match = {
        id: Date.now(),
        players: [players[0], upperPlayers[0]],
      };
      const [p1, p2] = match.players;
      const room = await createMatchRoom(p1, p2);
      await redisClient.set(currentKey, JSON.stringify(players.slice(1)));
      await redisClient.set(upperKey, JSON.stringify(upperPlayers.slice(1)));
      console.log(`⚔️ Cross-rank match: ${rank} vs ${upperRank}`);
      console.log(`🎮 Match found and room created: ${room.room_id}`);
      return room;
    }
  }

  const lowerRank = rankOrder[rankIndex - 1];
  if (lowerRank) {
    const lowerKey = queueKeyForRank(lowerRank);
    const lowerPlayers = JSON.parse(await redisClient.get(lowerKey)) || [];
    if (players.length >= 1 && lowerPlayers.length >= 1) {
      const match = {
        id: Date.now(),
        players: [players[0], lowerPlayers[0]],
      };
      const [p1, p2] = match.players;
      const room = await createMatchRoom(p1, p2);
      await redisClient.set(currentKey, JSON.stringify(players.slice(1)));
      await redisClient.set(lowerKey, JSON.stringify(lowerPlayers.slice(1)));
      console.log(`⚔️ Cross-rank match: ${rank} vs ${lowerRank}`);
      console.log(`🎮 Match found and room created: ${room.room_id}`);
      return room;
    }
  }

  return null;
};

export const createMatchRoom = async (player1, player2) => {
  const roomId = uuidv4(); // unique room ID
  try {
    const query = `
      INSERT INTO match_rooms 
      (room_id, player1_id, player2_id, player1_username, player2_username, rank, status)
      VALUES ($1, $2, $3, $4, $5, $6, $7)
      RETURNING *;
    `;
    const values = [
      roomId,
      player1.id,
      player2.id,
      player1.username,
      player2.username,
      player1.rank,
      "waiting"
    ];

    const result = await db.query(query, values);
    console.log(`🏠 Match Room created: ${roomId}`);
    return result.rows[0];
  } catch (err) {
    console.error("❌ Error creating match room:", err);
    throw err;
  }
};