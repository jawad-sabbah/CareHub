import pool from "../../config/db.js";

class ContactRepository {
  async createContactMessage(userId, subject, message) {
    const query = `
      INSERT INTO contact_message
      (user_id, subject, message)
      VALUES ($1, $2, $3)
      RETURNING id, user_id, subject, message, created_at;
    `;

    const result = await pool.query(query, [userId, subject, message]);
    return result.rows[0];
  }
}

export default new ContactRepository();