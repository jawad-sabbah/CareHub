import MedicalRecordService from "./medicalRecordService.js";

class MedicalRecordController {
  async getAllMedicalRecords(req, res) {
    try {
      const userId = req.user.id;
      const { type } = req.query; // all | hospital | lab | clinic

      const records = await MedicalRecordService.getAllMedicalRecords(
        userId,
        type
      );

      return res.status(200).json({
        success: true,
        message: "Medical records fetched successfully",
        data: records,
      });
    } catch (error) {
      return res.status(500).json({
        success: false,
        message: error.message || "Failed to fetch medical records",
      });
    }
  }
  async getOneMedicalRecord(req, res) {
    try {
      const userId = req.user.id;
      const { recordId } = req.params;
      const record = await MedicalRecordService.getOneMedicalRecord(recordId, userId);
      return res.status(200).json({
        success: true,
        message: "Medical record fetched successfully",
        data: record,
      });
    }
    catch (error) {
      return res.status(500).json({
        success: false,
        message: error.message || "Failed to fetch medical record",
      });
    }
  }
}

export default new MedicalRecordController();