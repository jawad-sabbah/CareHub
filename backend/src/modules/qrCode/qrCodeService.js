import QRCode from "qrcode";
import qrCodeRepository from "./qrCodeRepository.js";

class QrCodeService {

  async generatePolicyQr(policyCode) {

    const policy =
      await qrCodeRepository.findPolicyByCode(policyCode);

    if (!policy) {
      throw new Error("Policy not found");
    }

    const qrCode = await QRCode.toDataURL(policy.policy_code);

    return {
      policyCode: policy.policy_code,
      qrCode
    };
  }
}

export default new QrCodeService();