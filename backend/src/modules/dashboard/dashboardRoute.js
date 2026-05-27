import express from "express";
import dashboardController from "./dashboardController.js";
import {authMiddleware} from "../../middleware/auth.middleware.js";

const router=express.Router();

router.get('/insurance-details',authMiddleware,dashboardController.getInsurancePoliciesByUserId);

export default router;