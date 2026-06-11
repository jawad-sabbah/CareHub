import express from 'express';
import profileController from './profileController.js';
import { authMiddleware } from '../../middleware/auth.middleware.js';

const router = express.Router();

router.put(
  '/change-password',
  authMiddleware,
  profileController.changePassword.bind(profileController)
);

router.put(
  '/update',
  authMiddleware,
  profileController.updateProfile.bind(profileController)
)

export default router