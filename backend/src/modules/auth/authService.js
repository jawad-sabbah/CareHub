import bcrypt from 'bcrypt';
import authRepository from './authRepository.js';
import generateToken from '../../utils/generateToken.js';
import { validateRegisterData } from '../../shared/validators/validRegisterData.js';

class AuthService {
  
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

  async registerAsInsuranceOwner(data) {

    validateRegisterData(data);
   
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

}

export default new AuthService();