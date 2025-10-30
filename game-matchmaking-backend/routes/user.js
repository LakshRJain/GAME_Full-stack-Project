import express from "express";
import { verifyToken } from "../middleware/authMiddleware.js";
import { getProfile ,changePassword ,updateProfiler,getAllPlayers} from "../controllers/userController.js";
const router=express.Router();

router.get("/me",verifyToken,getProfile);
router.get("/all",verifyToken,getAllPlayers);
router.put("/changePassword", verifyToken, changePassword);
router.put("/updateProfile",verifyToken,updateProfiler);


export default router;