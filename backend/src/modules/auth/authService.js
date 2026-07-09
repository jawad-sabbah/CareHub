import bcrypt from 'bcrypt';
import authRepository from './authRepository.js';
import generateToken from '../../utils/generateToken.js';
import { validateRegisterData } from '../../shared/validators/validRegisterData.js';

class AuthService{


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

}

export default new AuthService();