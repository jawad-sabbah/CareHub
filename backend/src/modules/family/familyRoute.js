import express from 'express';
import familyController from './familyController.js';
import { authMiddleware } from '../../middleware/auth.middleware.js';

const router = express.Router();

router.get("/", authMiddleware, familyController.getFamilyMembers);

router.delete("/:id", authMiddleware, familyController.deleteFamilyMember);

export default router;