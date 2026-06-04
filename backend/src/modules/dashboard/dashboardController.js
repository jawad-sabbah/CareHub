import dashboardService from "./dashboardService.js";

class DashboardController {
  async getDashboard(req, res) {
  const userId = req.user.id;

  try {

    const dashboardData =
      await dashboardService.getDashboardByUserId(userId);

    return res.status(200).json({
      success: true,
      message: "Dashboard fetched successfully",
      data: dashboardData,
    });

  } catch (error) {

    return res.status(500).json({
      success: false,
      message: error.message || "Failed to fetch dashboard",
    });

  }
}
}

export default new DashboardController();