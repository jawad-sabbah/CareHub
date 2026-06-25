import insuranceCoverageService from '../insurance_coverage/insurance_coverage_Service.js'

class insuranceCoverageController
{
  async getInsuranceCoverageDetails(req,res)
  {
    try {
      const userId=req.user.id;
      const insuranceCoverageData=
         await insuranceCoverageService.InsuranceCoverageDetails(
           userId
         )

       return res.status(201).json({
        success:true,
        message:"Insurance Coverage Details fetched successfully ",
        data:insuranceCoverageData
       })  

    } catch (error) {
      return res.status(500).json({
        success: false,
        message: error.message || "Failed to fetch insurance coverage details",
      });
    }
  }
}

export default new insuranceCoverageController()