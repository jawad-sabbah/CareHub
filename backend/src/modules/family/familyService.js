import familyRepository from "./familyRepository.js";


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
}

export default new FamilyService();