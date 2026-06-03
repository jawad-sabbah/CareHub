import qrCodeService from "./qrCodeService.js";

class QrCodeController {

  async generatePolicyQr(req, res) {
    try {

      const { policyCode } = req.params;

      const result =
        await qrCodeService.generatePolicyQr(policyCode);

      return res.status(200).json({
        success: true,
        message: "QR code generated successfully",
        data: result
      });

    } catch (error) {

      if (error.message === "Policy not found") {
        return res.status(404).json({
          success: false,
          message: error.message
        });
      }

      return res.status(500).json({
        success: false,
        message: "Failed to generate QR code"
      });
    }
  }
}

export default new QrCodeController();