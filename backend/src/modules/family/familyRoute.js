import express from 'express';
import familyController from './familyController.js';
import { authMiddleware } from '../../middleware/auth.middleware.js';
import {isInsuranceOwner} from '../../middleware/isInsuranceOwner.js'

const router = express.Router();


router.get("/", authMiddleware, familyController.getFamilyMembers);

router.get("/cards/:memberId", authMiddleware, familyController.getFamilyMemberCards);

router.delete("/:id", authMiddleware,isInsuranceOwner, familyController.deleteFamilyMember);

router.post('/invite-family-member',authMiddleware,isInsuranceOwner,familyController.registerFamilyMember
);


router.get("/search", authMiddleware, isInsuranceOwner, familyController.searchEligibleMembers);
router.post("/enroll", authMiddleware, isInsuranceOwner, familyController.enrollMember);

export default router;