import redisClient from "../redis_client.js";

const QUEUE_KEY="matchmaking:queue";
const PLAYER_SET_KEY="matchmaking:players";


export async function joinQueue(player){
    const added=await redisClient.sAdd(PLAYER_SET_KEY,player.id);
    if(added===0){
        console.log(`${player.username} already in queue`);
        return false;
    }

    await redisClient.lPush(QUEUE_KEY, JSON.stringify(player));
    console.log(`${player.username} joined queue`);
    return true;
}

export async function findMatch(){
    const player1=await redisClient.rPop(QUEUE_KEY);
    if(!player1) return null;
    const player2 = await redisClient.rPop(QUEUE_KEY);
    if (!player2) {
        await redisClient.lPush(QUEUE_KEY, player1);
        return null;
    }
    
    const p1 = JSON.parse(player1);
    const p2 = JSON.parse(player2);
    const removed= redisClient.sRem(PLAYER_SET_KEY, p1.id, p2.id);
    console.log(`🧹 Removed ${removed} players from set`);

    console.log(`🎯 Matched ${p1.username} vs ${p2.username}`);
    return { players: [p1, p2] };
}

export async function leaveQueue(playerId) {
  await redisClient.sRem(PLAYER_SET_KEY, playerId);
  console.log(`🚪 Player ${playerId} left queue`);
}
