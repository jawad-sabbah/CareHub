import express from 'express';
import authController from './authController.js';
import { authMiddleware } from '../../middleware/auth.middleware.js';

const router = express.Router();

router.post(
  '/register-owner',
  authController.registerAsInsuranceOwner.bind(authController)
);

router.post(
  '/login',
  authController.login.bind(authController)
);

router.post(
  '/logout',
  authController.logout.bind(authController)
);


router.post(
  '/join-family-member',
  authController.joinFamilyMember.bind(authController)
);


export default router;