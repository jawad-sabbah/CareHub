import express from 'express';
import authController from './authController.js';

const router=express.Router();

router.post('/register-owner',authController.registerAsInsuranceOwner);
router.post('/login',authController.login);

export default router;