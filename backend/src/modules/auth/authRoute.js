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

router.put(
  '/change-password',
  authMiddleware,
  authController.changePassword.bind(authController)
);

router.post(
  '/invite-family-member',
  authMiddleware,
  authController.registerFamilyMember.bind(authController)
);

router.post(
  '/join-family-member',
  authController.joinFamilyMember.bind(authController)
);


router.put(
  '/profile',
  authMiddleware,
  authController.updateProfile.bind(authController)
);

export default router;