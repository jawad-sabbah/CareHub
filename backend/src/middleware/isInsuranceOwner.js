import profileRepository from "../modules/profile/profileRepository.js";

export const isInsuranceOwner = async (req, res, next) => {
  try {
    const user = await profileRepository.getUserById(req.user.id);

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    if (user.relation_id !== null) {
      return res.status(403).json({
        success: false,
        message: "Only insurance owner can perform this action",
      });
    }

    next();
  } catch (error) {
    next(error);
  }
};
