import express from "express";
import { verifyToken } from "../middleware/authMiddleware.js";
import { register,login,removeUser, refreshToken,logout }from "../controllers/authController.js";

const router= express.Router();
router.post("/register",register);
router.post("/login",login);
router.post("/removeUser",removeUser)
router.post("/refresh",refreshToken);
router.post("/logout",verifyToken,logout);
export default router;