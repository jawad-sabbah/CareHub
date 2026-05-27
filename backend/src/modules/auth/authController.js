import authService from "./authService.js";


class AuthController {

  async registerAsInsuranceOwner(req,res){
   try {
    
      const newUser=await authService.registerAsInsuranceOwner(req.body);
      res.status(201).json({
        success:true,
        message:'User registered successfully',
        data:newUser
      });
    } catch (error) {
      if(error.message==='Email already exists'){
        res.status(400).json({  
          success:false,
          message:'Email already exists'
        });
      }
      else if(error.message==='Data is required'){
        res.status(400).json({
          success:false,
          message:'Data is required'
        });
      }
      else{
        res.status(500).json({
          success:false,
          message:'Server error'
        });
      }
    }
  }

  async login(req,res){
    
    const {email,password}=req.body;
    try {
      const result=await authService.login(email,password);
      res.json({
        success:true,
        message:'Login successful',
        token:result.token,
        data:result.user
      });
    } catch (error) {
      if(error.message==='Invalid email or password'){
        res.status(401).json({
          success:false,
          message:'Invalid email or password'
        });
      }
      else if(error.message==='Email and password are required'){
        res.status(400).json({
          success:false,
          message:'Email and password are required'
        });
      }
      else{
        res.status(500).json({
          success:false,
          message:'Server error'
        });
      }
    }
  }
}

export default new AuthController();