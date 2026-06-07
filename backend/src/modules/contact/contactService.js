import contactRepository from "./contactRepository.js";
import authRepository from "../auth/authRepository.js";
import { sendContactEmail } from "../../shared/emailService.js";

class ContactService {
  async sendContactMessage(userId, subject, message) {
    if (!subject || !message) {
      throw new Error("Subject and message are required");
    }

    const user = await authRepository.getUserById(userId);

    if (!user) {
      throw new Error("User not found");
    }

    const savedMessage = await contactRepository.createContactMessage(
      userId,
      subject,
      message
    );

    await sendContactEmail({
      user,
      subject,
      message,
    });

    return {
      id: savedMessage.id,
      subject: savedMessage.subject,
      message: savedMessage.message,
      createdAt: savedMessage.created_at,
    };
  }
}

export default new ContactService();