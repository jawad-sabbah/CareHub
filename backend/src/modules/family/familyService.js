import familyRepository from "./familyRepository.js";
import authRepository from "../auth/authRepository.js"
import {
validateDateOfBirth,validateEmail,validateGender,validatePhone
} from '../../shared/validators/validFamilyMemberData.js'
import bcrypt from 'bcrypt'

class FamilyService {
  
  async getFamilyMembersByUserId(userId) {
    const members = await familyRepository.getFamilyMembersByUserId(userId);

    if (!members || members.length === 0) {
      return {
        totalMembers: 0,
        planStatus: "inactive",
        members: [],
      };
    }

    return {
      totalMembers: members.length,
      planStatus: "active",

      members: members.map((member) => ({
        id: member.id,
        name: member.username,
        email: member.email,
        phoneNumber: member.phone_number,
        relation: member.relation || "Primary Policy Holder",
        gender: member.gender,
        dateOfBirth: member.date_of_birth,
        isPrimary: member.id === userId,
        status: "active",
      })),
    };
  }
  async getFamilyMembersCount(userId) {
    const count = await familyRepository.getFamilyMembersCount(userId);

    if (count === 0) {
      return {
        totalMembers: 0,
      };
    }

    return {
      totalMembers: count,
    };
  }

  async registerFamilyMember(ownerId, data) {
      const { fullName, email, phone_number, date_of_birth,gender, relation_id } = data;

    if (!fullName || !email || !phone_number || !date_of_birth|| !gender || !relation_id) {
      throw new Error("All family member fields are required");
    }

    validateEmail(email);
    validatePhone(phone_number);
    validateGender(gender)
    validateDateOfBirth(date_of_birth);

    const existingUser = await authRepository.getUserByEmail(email);

    if (existingUser) {
      throw new Error("Email already exists");
    }

    const temporaryPassword = phone_number;
    const hashedPassword = await bcrypt.hash(temporaryPassword, 10);

    const newMember = await familyRepository.registerFamilyMember(
      fullName,
      email,
      phone_number,
      date_of_birth,
      gender,
      hashedPassword,
      ownerId,
      relation_id
    );

    // Give the dependent their own coverage record, copied from the primary.
    await familyRepository.attachPrimaryInsurance(newMember.id, ownerId);

    return newMember;
  }

  async deleteFamilyMember(memberId, userId) {
  const deletedMember =
    await familyRepository.deleteFamilyMember(memberId, userId);

  if (!deletedMember) {
    throw new Error("Family member not found or already deleted");
  }

  return {
    id: deletedMember.id,
    name: deletedMember.username,
    isActive: deletedMember.is_active,
  };
  }


  async searchInactiveMembers(ownerId, term) {
    const rows = await familyRepository.searchInactiveMembers(
      ownerId,
      (term || "").trim()
    );

    return rows.map((r) => ({
      id: r.id,
      name: r.username,
      email: r.email
    }));
  }


   async reactivateMember(ownerId, memberId) {
    if (!memberId) {
      throw new Error("Member is required");
    }

    const reactivated = await familyRepository.reactivateMember(ownerId, memberId);
    if (!reactivated) {
      throw new Error("Member not found or already active");
    }

    // Safety net: if this dependent somehow has no coverage row, copy one
    // from the primary. Guarded by NOT EXISTS, so it is a no-op when their
    // original insurance is still intact after a "remove".
    await familyRepository.attachPrimaryInsurance(reactivated.id, ownerId);

    return { id: reactivated.id, name: reactivated.username, email: reactivated.email };
  }
  
  
  async getCard(userId, memberId){

    const user = await authRepository.getUserById(userId);

    const members =
        await familyRepository.getFamilyMembersByUserId(memberId);


    const member = members[0];


    if (!member) {
        throw new Error("Family member not found");
    }


    // primary user check
    const isPrimary = user.parent_id == null;


    if (!isPrimary && user.id != memberId) {
        throw new Error(
          "Access denied"
        );
    }


    const card =
        await familyRepository.getCardByMemberId(memberId);


    if(!card){
        throw new Error(
          "Insurance card not found"
        );
    }

       console.log("CARD PAYLOAD:", { annualLimit: card.annual_limit, coverage: card.coverage_percentage, used: card.used_amount });
      
       return {

        memberId: member.id,

        name: member.username,

        relationship:
            member.relation || "Dependent",


        policyCode:
            card.policy_code || "",


        providerName:
            card.provider_name || "",


        planName:
            card.name || "",


        insuranceStatus:
            card.status || "ACTIVE",


        coveragePercentage:
            Number(card.coverage_percentage) || 0,


        annualLimit:
            Number(card.annual_limit) || 0,


        usedAmount:
            Number(card.used_amount) || 0,


        remainingAmount:
            Number(card.remaining_amount) || 0,


        cardNumber:
            card.card_number || "",

    };
    

}


}

export default new FamilyService();