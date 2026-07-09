import familyService from "./familyService.js";

class FamilyController {
  
  async getFamilyMembers(req, res) {
  try {
    const userId = req.user.id;

    const familyData =
      await familyService.getFamilyMembersByUserId(userId);

    return res.status(200).json({
      success: true,
      message: "Family members fetched successfully",
      data: familyData,
    });

  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
}

  async deleteFamilyMember(req, res) {
  try {
    const userId = req.user.id;
    const memberId = req.params.id;

    const result =
      await familyService.deleteFamilyMember(memberId, userId);

    return res.status(200).json({
      success: true,
      message: "Family member deleted successfully",
      data: result,
    });

  } catch (error) {
    return res.status(404).json({
      success: false,
      message: error.message || "Failed to delete family member",
    });
  }
}

 async registerFamilyMember(req, res) {
    try {
      const ownerId = req.user.id;

      const newUser = await familyService.registerFamilyMember(
        ownerId,
        req.body
      );

      return res.status(201).json({
        success: true,
        message: 'Family member invited successfully',
        data: newUser
      });
    } catch (error) {
     return res.status(404).json({
      success: false,
      message: error.message || "Failed to add family member",
    });
    }
  }

  async searchInactiveMembers(req, res) {
    try {
      const data = await familyService.searchInactiveMembers(req.user.id, req.query.q || "");
      return res.status(200).json({ success: true, message: "Members found", data });
    } catch (error) {
      return res.status(400).json({ success: false, message: error.message });
    }
  }
  
    async reactivateMember(req, res) {
    try {
      const { member_id } = req.body;
      const data = await familyService.reactivateMember(req.user.id, member_id);
      return res.status(200).json({ success: true, message: "Member reactivated", data });
    } catch (error) {
      return res.status(400).json({ success: false, message: error.message });
    }
  }



  async getFamilyMemberCards(req, res) {
    try{

       const userId = req.user.id; // from JWT middleware
        const memberId = req.params.memberId;

        const card = await familyService.getCard(userId, memberId);

        return res.status(200).json({
            success: true,
            message: "Card fetched successfully",
            data: card,
        });
    }
    catch(error)
    {
        return res.status(404).json({
            success: false,
            message: error.message || "Failed to fetch card",
        });
    }
  }
  
}

export default new FamilyController();