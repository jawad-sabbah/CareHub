import InsuranceCoverageRepository from "./insurance_coverage_repository.js";

class InsuranceCoverageService {
  async InsuranceCoverageDetails(userId) {
    const insuranceCoverageDetails =
      await InsuranceCoverageRepository.getPlanCoverageByUserId(userId);

    if (!insuranceCoverageDetails || insuranceCoverageDetails.length === 0) {
      throw new Error("Insurance Coverage Details not found");
    }

     console.log(insuranceCoverageDetails);
     


    return {
      user: {
        id:insuranceCoverageDetails.id,
        username: insuranceCoverageDetails.username,
      },

      insurance: {
        policy_code: insuranceCoverageDetails.policy_code,
        provider_name: insuranceCoverageDetails.provider_name,
        status: insuranceCoverageDetails.status,
        expiry_date: insuranceCoverageDetails.expiry_date,
      },

      plan: {
        coverage_percentage: insuranceCoverageDetails.coverage_percentage,
        annual_limit: Number(insuranceCoverageDetails.annual_limit),
        used_amount:insuranceCoverageDetails.used_amount,
        remaining_amount:insuranceCoverageDetails.remaining_amount
      },

      benefits: insuranceCoverageDetails.benefits,
    };
  }
}

export default new InsuranceCoverageService();