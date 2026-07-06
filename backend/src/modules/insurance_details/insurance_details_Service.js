import insuranceDetailsRepository from "./insurance_details_Repository.js";

class InsuranceDetailsService {
  async getInsuranceDetailsByUserId(userId) {
    
    const insurance = await insuranceDetailsRepository.getInsuranceDetailsByUserId(
      userId
    );    

    if (!insurance) {
      throw new Error("Insurance details not found");
    }

    
    //check if the logged user that check detailes is the owner 
    const isPrimary = insurance.relation_id === null;


    return {
      user: {
        id: insurance.user_id,
        name: insurance.username,
        isPrimary
      },
      insurance: {
        id: insurance.insurance_id,
        policyCode: insurance.policy_code,
        providerName: insurance.provider_name,
        status: insurance.status,
        startDate: insurance.start_date,
        expiryDate: insurance.expiry_date,
      },
      plan: {
        id: insurance.plan_id,
        name: insurance.plan_name,
        coveragePercentage: insurance.coverage_percentage,
        annualLimit: insurance.annual_limit,
        description:insurance.description
      },
    };
  }
}

export default new InsuranceDetailsService();