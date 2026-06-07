import contactService from "./contactService.js";

class ContactController {
  async sendContactMessage(req, res) {
    try {
      const userId = req.user.id;
      const { subject, message } = req.body;

      const contactMessage = await contactService.sendContactMessage(
        userId,
        subject,
        message
      );

      return res.status(201).json({
        success: true,
        message: "Message submitted successfully",
        data: contactMessage,
      });
    } catch (error) {
      return res.status(400).json({
        success: false,
        message: error.message || "Failed to send contact message",
      });
    }
  }
}

export default new ContactController();