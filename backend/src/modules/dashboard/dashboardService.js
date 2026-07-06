import dashboardRepository from "./dashboardRepository.js";
import {generatePolicyQRCode} from "./qrCode.js";

class DashboardService {

  async getDashboardByUserId(userId) {
    try {

      const user = await dashboardRepository.getUserById(userId);

      if (!user) {
        throw new Error("User not found");
      }

      const insuranceCard =
        await dashboardRepository.getInsuranceByUserId(userId);


      let qrCode=null;
      if(insuranceCard){
        qrCode=await generatePolicyQRCode(insuranceCard.policy_code);
      }  

      const recentMedicalRecords =
        await dashboardRepository.getRecentMedicalRecords(userId);

      const familyMembersCount =
        await dashboardRepository.getFamilyMembersCount(userId);

      const medicalRecordsCount =
        await dashboardRepository.getMedicalRecordsCount(userId);


        const coverageUsage =
        await dashboardRepository.getCoverageUsage(userId);

      const monthlyVisits =
        await dashboardRepository.getMonthlyVisits(userId);
        
      return {
        user: {
          id: user.id,
          username: user.username,
        },
        insuranceCard: insuranceCard
        ? {
            id: insuranceCard.id,
            policyCode: insuranceCard.policy_code,
            providerName: insuranceCard.provider_name,
            status: insuranceCard.status,
            planName: insuranceCard.name,
            startDate: insuranceCard.start_date,
            expiryDate: insuranceCard.expiry_date,
            qrCode
          }
        : null,
        recentMedicalRecords: recentMedicalRecords.map((record) => ({
          id: record.id,
          serviceName: record.service_name,
          medicalCenter: record.medical_center,
          visitDate: record.visit_date,
        })),
        counts: {
          familyMembers: familyMembersCount,
          medicalRecords: medicalRecordsCount,
        },
        coverage: coverageUsage
          ? {
              annualLimit: Number(coverageUsage.annual_limit),
              usedAmount: Number(coverageUsage.used_amount),
            }
          : null,
        monthlyVisits: monthlyVisits.map((m) => ({
          label: m.label,
          count: m.count,
        })),
      };

    } catch (error) {
      console.log("Dashboard Service Error:", error);
      throw error;
    }
  }

}

export default new DashboardService();