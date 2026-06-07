import insuranceHistoryRepository from "./insurance_History_Repository.js";

class InsuranceHistoryService {
  async getInsuranceHistoryByUserId(userId, search = "") {
  if (!userId) {
    throw new Error("User id is required");
  }


  const history =
    await insuranceHistoryRepository.getInsuranceHistoryByUserId(
      userId,
      search
    );
  return {
    totalPolicies: Number(history.length) || 0,
    history: history.map((item) => ({
      id: item.id,
      planName: item.plan_name,
      providerName: item.provider_name,
      policyCode: item.policy_code,
      actionType: item.action_type,
      description: item.description,
      startDate: item.start_date,
      expiryDate: item.expiry_date,
      createdAt: item.created_at,
    })),
  };
}
}

export default new InsuranceHistoryService();