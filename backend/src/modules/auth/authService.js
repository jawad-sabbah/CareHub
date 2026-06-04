import bcrypt from 'bcrypt';
import authRepository from './authRepository.js';
import generateToken from '../../utils/generateToken.js';

class AuthService {
  validateRegisterData(data) {
    const { fullName, email, phone_number, date_of_birth, gender, password } = data;

    if (!fullName || !email || !phone_number || !date_of_birth || !gender || !password) {
      throw new Error('All fields are required');
    }

    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      throw new Error('Invalid email format');
    }

    if (!/^\d{8}$/.test(phone_number)) {
      throw new Error('Phone number must be 8 digits');
    }

    if (!['M', 'F'].includes(gender)) {
      throw new Error('Gender must be M or F');
    }

    if (password.length < 6) {
      throw new Error('Password must be at least 6 characters');
    }

    if (isNaN(new Date(date_of_birth).getTime())) {
      throw new Error('Invalid date of birth format');
    }
  }

  validateFamilyMemberData(data) {
    const { fullName, email, phone_number, date_of_birth, relation_id } = data;

    if (!fullName || !email || !phone_number || !date_of_birth || !relation_id) {
      throw new Error('All family member fields are required');
    }

    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      throw new Error('Invalid email format');
    }

    if (!/^\d{8}$/.test(phone_number)) {
      throw new Error('Phone number must be 8 digits');
    }

    if (isNaN(new Date(date_of_birth).getTime())) {
      throw new Error('Invalid date of birth format');
    }
  }

  validateUpdateProfileData(data) {
  const {
    fullName,
    email,
    phone_number,
    gender
  } = data;

  if (!fullName || !email || !phone_number || !gender) {
    throw new Error('All profile fields are required');
  }

  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

  if (!emailRegex.test(email)) {
    throw new Error('Invalid email format');
  }

  if (!/^\d{8}$/.test(phone_number)) {
    throw new Error('Phone number must be 8 digits');
  }

  if (!['M', 'F'].includes(gender)) {
    throw new Error('Gender must be M or F');
  }
}

  async registerAsInsuranceOwner(data) {
    this.validateRegisterData(data);

    const { fullName, email, phone_number, date_of_birth, gender, password } = data;

    const existingUser = await authRepository.getUserByEmail(email);

    if (existingUser) {
      throw new Error('Email already exists');
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    return await authRepository.registerAsInsuranceOwner(
      fullName,
      email,
      phone_number,
      date_of_birth,
      gender,
      hashedPassword
    );
  }

  async login(email, password) {
    if (!email || !password) {
      throw new Error('Email and password are required');
    }

    const user = await authRepository.getUserByEmail(email);

    if (!user) {
      throw new Error('Invalid email or password');
    }

    const isMatch = await bcrypt.compare(password, user.password);

    if (!isMatch) {
      throw new Error('Invalid email or password');
    }

    const token = generateToken(user);

    return {
      token,
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        role: user.role
      }
    };
  }

  async logout() {
    return true;
  }

  async changePassword(userId, currentPassword, newPassword, confirmPassword) {
    if (!currentPassword || !newPassword || !confirmPassword) {
      throw new Error('All password fields are required');
    }

    if (newPassword !== confirmPassword) {
      throw new Error('New password and confirm password do not match');
    }

    const passwordRegex = /^(?=.*[0-9])(?=.*[!@#$%^&*])[A-Za-z0-9!@#$%^&*]{8,}$/;

    if (!passwordRegex.test(newPassword)) {
      throw new Error('Password must be at least 8 characters and contain a number and special character');
    }

    const user = await authRepository.getUserById(userId);

    if (!user) {
      throw new Error('User not found');
    }

    const isMatch = await bcrypt.compare(currentPassword, user.password);

    if (!isMatch) {
      throw new Error('Current password is incorrect');
    }

    const hashedPassword = await bcrypt.hash(newPassword, 10);

    return await authRepository.updatePassword(userId, hashedPassword);
  }

  async registerFamilyMember(ownerId, data) {
    this.validateFamilyMemberData(data);

    const { fullName, email, phone_number, date_of_birth, relation_id } = data;

    const existingUser = await authRepository.getUserByEmail(email);

    if (existingUser) {
      throw new Error('Email already exists');
    }

    const temporaryPassword = phone_number;
    const hashedPassword = await bcrypt.hash(temporaryPassword, 10);

    return await authRepository.registerFamilyMember(
      fullName,
      email,
      phone_number,
      date_of_birth,
      hashedPassword,
      ownerId,
      relation_id
    );
  }

   async joinFamilyMember(data) {
  const {
    policy_code,
    owner_email,
    fullName,
    relation_id
  } = data;

  if (!policy_code || !owner_email || !fullName || !relation_id) {
    throw new Error('All join family fields are required');
  }

  const owner = await authRepository.getUserByEmail(owner_email);

  if (!owner) {
    throw new Error('Insurance owner not found');
  }

  const insurance =
    await authRepository.getInsuranceByOwnerAndPolicyCode(
      owner.id,
      policy_code
    );

  if (!insurance) {
    throw new Error('Invalid family policy information');
  }

  const familyMember =
    await authRepository.findFamilyMemberInvite(
      owner.id,
      fullName,
      relation_id
    );

  if (!familyMember) {
    throw new Error('Family member invite not found');
  }

  const token = generateToken({
    id: familyMember.id,
    role: 'family_member'
  });

  return {
    token,
    familyMember
  };
}


async updateProfile(userId, data) {
  const {
    fullName,
    email,
    phone_number,
    gender
  } = data;

  this.validateUpdateProfileData(data);

  const existingEmail =
    await authRepository.getUserByEmailExceptUserId(
      email,
      userId
    );

  if (existingEmail) {
    throw new Error('Email already exists');
  }

  const updatedUser = await authRepository.updateProfile(
    userId,
    fullName,
    email,
    phone_number,
    gender
  );

  if (!updatedUser) {
    throw new Error('User not found');
  }

  return updatedUser;
}

}

export default new AuthService();