import insuranceHistoryService from "./insurance_History_Service.js";

class InsuranceHistoryController {
  async getInsuranceHistory(req, res) {
  try {
    const userId = req.user.id;
    const { search } = req.query;

    const insuranceHistory =
      await insuranceHistoryService.getInsuranceHistoryByUserId(
        userId,
        search
      );

    return res.status(200).json({
      success: true,
      message: "Insurance history fetched successfully",
      data: insuranceHistory,
    });
  } catch (error) {
    return res.status(400).json({
      success: false,
      message: error.message,
    });
  }
}
}

export default new InsuranceHistoryController();