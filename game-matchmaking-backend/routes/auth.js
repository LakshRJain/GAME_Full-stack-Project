import express from "express";
import { register,login,removeUser }from "../controllers/authController.js";

const router= express.Router();
router.post("/register",register);
router.post("/login",login);
router.post("/removeUser",removeUser)
export default router;