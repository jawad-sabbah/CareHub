import express from "express";
import qrCodeController from "./qrCodeController.js";

const router = express.Router();

router.get(
  "/generate/:policyCode",
  qrCodeController.generatePolicyQr
);

export default router;