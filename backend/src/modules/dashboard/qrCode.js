import QRCode from "qrcode";

export const generatePolicyQRCode = async (policyCode) => {
  return await QRCode.toDataURL(policyCode);
};