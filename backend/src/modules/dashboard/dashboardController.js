import dashboardService from "./dashboardService.js";

class DashboardController {
  async getInsurancePoliciesByUserId(req, res) {
    const userId = req.user.id;

    try {
      const { user, policies: rawPolicies } =
        await dashboardService.getInsurancePoliciesByUserId(userId);

      const policies = rawPolicies.map((p) => ({
        id: p.id,
        policyCode: p.policy_code,
        providerName: p.provider_name,
        status: p.status,

        startDate: p.start_date
          ? p.start_date.toISOString().split("T")[0]
          : null,

        expiryDate: p.expiry_date
          ? p.expiry_date.toISOString().split("T")[0]
          : null,

        createdAt: p.created_at
          ? p.created_at.toISOString().split("T")[0]
          : null,

        plan: {
          id: p.insurance_plan_id,
          name: p.name,
          coveragePercentage: p.coverage_percentage,
          annualLimit: Number(p.annual_limit),
          description: p.description,
        },
      }));

     return res.status(200).json({
        success: true,
        message: "Dashboard fetched successfully",

        data: {
          greeting: `Hello, ${user.username}`,
          user: {
            id: user.id,
            username: user.username,
          },
          policies,
        },
      });

    } catch (error) {
      console.error("Dashboard Controller Error:", error);

      if (error.message === "No insurance policies found for the user") {
        return res.status(404).json({
          success: false,
          message: error.message,
        });
      }

      return res.status(500).json({
        success: false,
        message: "Failed to fetch dashboard data",
      });
    }
  }
}

export default new DashboardController();