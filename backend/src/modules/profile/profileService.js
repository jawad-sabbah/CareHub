import bcrypt from "bcrypt";

import profileRepository from "./profileRepository.js";
import authRepository from "../auth/authRepository.js";

import {
  validateEmail,
  validateGender,
  validatePhone,
} from "../../shared/validators/validUpdateProfileData.js";

class ProfileService {
  async changePassword(userId, currentPassword, newPassword, confirmPassword) {
    if (!currentPassword || !newPassword || !confirmPassword) {
      throw new Error("All password fields are required");
    }

    if (newPassword !== confirmPassword) {
      throw new Error("New password and confirm password do not match");
    }

    const passwordRegex =
      /^(?=.*[0-9])(?=.*[!@#$%^&*])[A-Za-z0-9!@#$%^&*]{8,}$/;

    if (!passwordRegex.test(newPassword)) {
      throw new Error(
        "Password must be at least 8 characters and contain a number and special character"
      );
    }

    const user = await profileRepository.getUserById(userId);

    if (!user) {
      throw new Error("User not found");
    }

    const isMatch = await bcrypt.compare(currentPassword, user.password);

    if (!isMatch) {
      throw new Error("Current password is incorrect");
    }

    const hashedPassword = await bcrypt.hash(newPassword, 10);

    return await profileRepository.updatePassword(userId, hashedPassword);
  }

  async updateProfile(userId, data) {
    const { fullName, email, phone_number, gender } = data;

    if (!fullName || !email || !phone_number || !gender) {
      throw new Error("All profile fields are required");
    }

    validateEmail(email);
    validatePhone(phone_number);
    validateGender(gender);

    const existingEmail = await profileRepository.getUserByEmailExceptUserId(
      email,
      userId
    );

    if (existingEmail) {
      throw new Error("Email already exists");
    }

    const updatedUser = await profileRepository.updateProfile(
      userId,
      fullName,
      email,
      phone_number,
      gender
    );

    if (!updatedUser) {
      throw new Error("User not found");
    }

    return updatedUser;
  }
}

export default new ProfileService();