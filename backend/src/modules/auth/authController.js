import authService from './authService.js';

class AuthController {
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

  async registerAsInsuranceOwner(req, res) {
    try {
      const newUser = await authService.registerAsInsuranceOwner(req.body);

      return res.status(201).json({
        success: true,
        message: 'User registered successfully',
        data: newUser
      });
    } catch (error) {
      return this.handleError(res, error);
    }
  }

  async login(req, res) {
    try {
      const { email, password } = req.body;

      const result = await authService.login(email, password);

      return res.status(200).json({
        success: true,
        message: 'Login successful',
        token: result.token,
        data: result.user
      });
    } catch (error) {
      return this.handleError(res, error);
    }
  }

  async logout(req, res) {
    try {
      await authService.logout();

      return res.status(200).json({
        success: true,
        message: 'Logged out successfully'
      });
    } catch (error) {
      return this.handleError(res, error);
    }
  }

  async joinFamilyMember(req, res) {
  try {
    const result =
      await authService.joinFamilyMember(req.body);

    return res.status(200).json({
      success: true,
      message: 'Family member verified successfully',
      token: result.token,
      data: result.familyMember
    });
  } catch (error) {
    return this.handleError(res, error);
  }
}


}

export default new AuthController();