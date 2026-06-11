import insuranceDetailsService from "./insurance_details_Service.js";

class InsuranceDetailsController {
  async getInsuranceDetails(req, res) {
    try {
      const userId = req.user.id;

      const insuranceDetails =
        await insuranceDetailsService.getInsuranceDetailsByUserId(userId);

      return res.status(200).json({
        success: true,
        message: "Insurance details fetched successfully",
        data: insuranceDetails,
      });
    } catch (error) {
      return res.status(500).json({
        success: false,
        message: error.message || "Failed to fetch insurance details",
      });
    }
  }
}

export default new InsuranceDetailsController();