import express from "express";
import InsuranceHistoryController from "./insurance_history_Controller.js";
import { authMiddleware } from "../../middleware/auth.middleware.js";

const router = express.Router();

router.get(
  "/",
  authMiddleware,
  InsuranceHistoryController.getInsuranceHistory
);



export default router;