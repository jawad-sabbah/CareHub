import express from "express";
import insuranceDetailsController from "./insurance_details_Controller.js";
import {authMiddleware} from "../../middleware/auth.middleware.js";

const router = express.Router();

router.get(
  "/",
  authMiddleware,
  insuranceDetailsController.getInsuranceDetails
);

export default router;