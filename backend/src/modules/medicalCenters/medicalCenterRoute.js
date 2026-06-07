import express from "express";
import medicalCenterController from "./medicalCenterController.js";
import { authMiddleware } from "../../middleware/auth.middleware.js";

const router = express.Router();

// Get all medical centers
router.get(
  "/",
  authMiddleware,
  medicalCenterController.getAllMedicalCenters
);

// Search centers
router.get(
  "/search",
  authMiddleware,
  medicalCenterController.searchMedicalCenters
);

// Filter by type
router.get(
  "/type/:type",
  authMiddleware,
  medicalCenterController.getMedicalCentersByType
);

// Get center details
router.get(
  "/:id",
  authMiddleware,
  medicalCenterController.getMedicalCenterById
);

export default router;