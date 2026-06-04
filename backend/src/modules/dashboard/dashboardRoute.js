import express from "express";
import dashboardController from "./dashboardController.js";
import {authMiddleware} from "../../middleware/auth.middleware.js";

const router=express.Router();

router.get(
  "/",
  authMiddleware,
  dashboardController.getDashboard
);


export default router;