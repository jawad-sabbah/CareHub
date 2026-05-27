import dashboardRepository from "./dashboardRepository.js";
import authRepository from "../auth/authRepository.js";

class DashboardService {

    async getInsurancePoliciesByUserId(userId){
      try {
        const user=await authRepository.getUserById(userId);
        if(!user){
          throw new Error("User not found");
        }
        const policies=await dashboardRepository.getInsurancePoliciesByUserId(userId);
        if (!policies || policies.length === 0) {
          throw new Error("No insurance policies found for the user");
        }
        return { user, policies };
      } catch (error) {
        console.log('Error in getInsurancePoliciesByUserId Service:', error);
        throw Error
      }
    }
}

export default new DashboardService();