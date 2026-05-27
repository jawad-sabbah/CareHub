import bcrypt from 'bcrypt';
import authRepository from './authRepository.js';
import generateToken from "../../utils/generateToken.js";

class AuthService {
  async registerAsInsuranceOwner(data){
   const {fullName,email,phone_number,date_of_birth,gender,password}=data;

    const saltRounds=10;
    try {
    
      if (!fullName || !email || !phone_number || !date_of_birth || !gender || !password) {
        throw new Error("All fields are required");
      }
      //check if email already exists
      const existingUser=await authRepository.getUserByEmail(email);
      if(existingUser){
        throw new Error('Email already exists');
      }
      //hash the password
      const hashedPassword=await bcrypt.hash(password,saltRounds);
     
      //create the user account
      const newUser=await authRepository.registerAsInsuranceOwner(fullName,email,phone_number,date_of_birth,gender,hashedPassword);
     
      return newUser;

    } catch (error) {
      console.log('Error in registerAsInsuranceOwner:', error);
      throw error;
    }
  }

  async login(email,password){
    try {
      if (!email || !password) {
        throw new Error('Email and password are required');
      }
      const user=await authRepository.getUserByEmail(email);
      if(!user){
        throw new Error('Invalid email or password');
      }
      const isMatch=await bcrypt.compare(password,user.password);
      if(!isMatch){
        throw new Error('Invalid email or password');
      }

      const token=generateToken(user);
      return{
        token,
        user:{
          id:user.id,
          username:user.username,
          email:user.email
        }
      }

    } catch (error) {
      console.log('Error in login Service:', error);
      throw error;
    }
  }

  
}

export default new AuthService();