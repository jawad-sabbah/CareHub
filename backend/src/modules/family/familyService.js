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

    return await familyRepository.registerFamilyMember(
      fullName,
      email,
      phone_number,
      date_of_birth,
      gender,
      hashedPassword,
      ownerId,
      relation_id
    );
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

  async searchEligibleMembers(ownerId, term) {
    if (!term || term.trim().length < 2) {
      throw new Error("Search term must be at least 2 characters");
    }
    const rows = await familyRepository.searchEligibleMembers(ownerId, term.trim());
    return rows.map((r) => ({ id: r.id, name: r.username, email: r.email }));
  }

  async enrollMember(ownerId, memberId, relationId) {
    if (!memberId || !relationId) {
      throw new Error("Member and relationship are required");
    }
    const enrolled = await familyRepository.enrollMember(ownerId, memberId, relationId);
    if (!enrolled) {
      throw new Error("Member not found or already on a policy");
    }
    return { id: enrolled.id, name: enrolled.username, email: enrolled.email };
  }
  
}

export default new FamilyService();