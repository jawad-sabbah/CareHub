import medicalCenterService from "./medicalCenterService.js";

class MedicalCenterController {
  async getAllMedicalCenters(req, res) {
    try {
      const centers =
        await medicalCenterService.getAllMedicalCenters();
        

      return res.status(200).json({
        success: true,
        message: "Medical centers fetched successfully",
        data: centers,
      });
    } catch (error) {
      return res.status(500).json({
        success: false,
        message: error.message || "Failed to fetch medical centers",
      });
    }
  }

  async getMedicalCenterById(req, res) {
    try {
      const { id } = req.params;

      const center =
        await medicalCenterService.getMedicalCenterById(id);

      return res.status(200).json({
        success: true,
        message: "Medical center fetched successfully",
        data: center,
      });
    } catch (error) {
      return res.status(404).json({
        success: false,
        message: error.message || "Medical center not found",
      });
    }
  }

  async getMedicalCentersByType(req, res) {
    try {
      const { type } = req.params;

      const centers =
        await medicalCenterService.getMedicalCentersByType(type);

      return res.status(200).json({
        success: true,
        message: "Medical centers fetched successfully",
        data: centers,
      });
    } catch (error) {
      return res.status(400).json({
        success: false,
        message: error.message || "Failed to fetch centers by type",
      });
    }
  }

  async searchMedicalCenters(req, res) {
    try {
      const { q } = req.query;

      const centers =
        await medicalCenterService.searchMedicalCenters(q);

      return res.status(200).json({
        success: true,
        message: "Medical centers fetched successfully",
        data: centers,
      });
    } catch (error) {
      return res.status(400).json({
        success: false,
        message: error.message || "Search failed",
      });
    }
  }
}

export default new MedicalCenterController();