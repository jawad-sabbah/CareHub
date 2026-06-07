import express from "express";
import contactController from "./contactController.js";
import {authMiddleware} from "../../middleware/auth.middleware.js"

const router = express.Router();

router.post("/", authMiddleware, contactController.sendContactMessage);

export default router;