import medicalRecordRepository from "./medicalRecordRepository.js";

class MedicalRecordService {
  async getAllMedicalRecords(userId, type = "all") {
    const records = await medicalRecordRepository.getAllMedicalRecords(userId, type);

    let lastVisitDate = null;

    records.forEach((record) => {
      if (!lastVisitDate || new Date(record.visit_date) > new Date(lastVisitDate)) {
        lastVisitDate = record.visit_date;
      }
    });

    return {
      totalVisits: records.length,
      lastVisit: lastVisitDate,
      records: records.map((record) => ({
        id: record.id,
        diagnosis: record.diagnosis,
        icd10Code: record.icd10_code,
        visitDate: record.visit_date,
        center: record.center_name,
        centerType: record.center_type,
      })),
    };
  }
  async getOneMedicalRecord(recordId, userId) {
  const record = await medicalRecordRepository.getMedicalRecordById(
    recordId,
    userId
  );

  if (!record || record.length === 0) {
    throw new Error("Medical record not found");
  }

  const firstRecord = record[0];

  return {
    id: firstRecord.id,
    diagnosis: firstRecord.diagnosis,
    icd10Code: firstRecord.icd10_code,
    visitDate: firstRecord.visit_date,
    centerName: firstRecord.center_name,

    services: record.map((r) => {
      const coveragePercentage = Number(r.coverage_percentage || 0);
      const cost = Number(r.default_cost || 0);
      const insurancePays = (cost * coveragePercentage) / 100;
      const patientPays = cost - insurancePays;

      return {
        serviceName: r.service_name,
        description: r.description,
        chiefComplaint: r.chief_complaint,
        physicalExam: r.physical_exam,
        cost,
        coveragePercentage,
        insurancePays,
        patientPays,
      };
    }),
  };
}
}

export default new MedicalRecordService();