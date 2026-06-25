import express from 'express'
import insuranceCoverageController from '../insurance_coverage/insurance_coverage_Controller.js'
import {authMiddleware} from '../../middleware/auth.middleware.js'

const router=express.Router();

router.get(
  '/',
  authMiddleware,
  insuranceCoverageController.getInsuranceCoverageDetails
)

export default router