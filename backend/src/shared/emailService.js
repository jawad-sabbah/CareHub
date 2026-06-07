import nodemailer from "nodemailer";



const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS,
  },
});

export const sendContactEmail = async ({ user, subject, message }) => {
  return await transporter.sendMail({
    from: process.env.EMAIL_USER,
    to: process.env.SUPPORT_EMAIL,
    replyTo: user.email,
    subject: `CareHub Contact: ${subject}`,
    text: `
New Contact Message

User ID: ${user.id}
Name: ${user.username}
Email: ${user.email}

Subject: ${subject}

Message:
${message}
    `,
  });
};
