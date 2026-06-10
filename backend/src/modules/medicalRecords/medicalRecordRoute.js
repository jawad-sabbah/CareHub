import MedicalRecordController from './medicalRecordController.js';
import express from 'express';
import {authMiddleware} from '../../middleware/auth.Middleware.js';

const router = express.Router();

router.get('/',authMiddleware, MedicalRecordController.getAllMedicalRecords);

router.get('/:recordId',authMiddleware, MedicalRecordController.getOneMedicalRecord);

export default router;