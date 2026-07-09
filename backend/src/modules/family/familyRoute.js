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


// Give Insurance: find this owner's inactive dependents, then reactivate one.
router.get("/search", authMiddleware, isInsuranceOwner, familyController.searchInactiveMembers);
router.post("/reactivate", authMiddleware, isInsuranceOwner, familyController.reactivateMember);

export default router;