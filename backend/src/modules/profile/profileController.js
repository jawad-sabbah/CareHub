import profileService from "./profileService.js";

class ProfileController
{
  handleError(res, error) {
    const badRequestErrors = [
      'All fields are required',
      'Email already exists',
      'Invalid email format',
      'Phone number must be 8 digits',
      'Gender must be M or F',
      'Password must be at least 6 characters',
      'Invalid date of birth format',
      'Email and password are required',
      'All password fields are required',
      'New password and confirm password do not match',
      'Password must be at least 8 characters and contain a number and special character',
      'All family member fields are required',
      'All join family fields are required',
      'User not found',
      'Insurance owner not found',
      'Invalid family policy information',
      'Family member invite not found',
      'All profile fields are required',
      'No profile for this user'
    ];

    if (badRequestErrors.includes(error.message)) {
      return res.status(400).json({
        success: false,
        message: error.message
      });
    }

    if (
      error.message === 'Invalid email or password' ||
      error.message === 'Current password is incorrect'
    ) {
      return res.status(401).json({
        success: false,
        message: error.message
      });
    }

    console.error(error);

    return res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
  
async userProfile(req,res)
{
  try {
    const userId=req.user.id
    const userData=await profileService.getUserProfile(userId)
    return res.status(201).json({
      success:true,
      message:'user Profile data fetched successfully',
      data:userData
    })
    
  } catch (error) {
     return this.handleError(res, error);
  }
}

async changePassword(req, res) {
    try {
      const userId = req.user.id;

      const { currentPassword, newPassword, confirmPassword } = req.body;

      const updatedUser = await profileService.changePassword(
        userId,
        currentPassword,
        newPassword,
        confirmPassword
      );

      return res.status(200).json({
        success: true,
        message: 'Password updated successfully',
        data: updatedUser
      });
    } catch (error) {
      return this.handleError(res, error);
    }
  }

async updateProfile(req, res) {
  try {
    const userId = req.user.id;

    const updatedUser = await profileService.updateProfile(
      userId,
      req.body
    );

    return res.status(200).json({
      success: true,
      message: 'Profile updated successfully',
      data: updatedUser
    });
  } catch (error) {
    return this.handleError(res, error);
  }
  }
}

export default new ProfileController()