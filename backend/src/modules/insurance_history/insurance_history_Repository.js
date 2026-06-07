import pool from "../../config/db.js";

class InsuranceHistoryRepository {
  async getInsuranceHistoryByUserId(userId, search = "") {
  const query = `
    SELECT
      ih.id,
      ih.action_type,
      ih.description,
      ih.created_at,
      i.provider_name,
      i.policy_code,
      i.start_date,
      i.expiry_date,
      ip.name AS plan_name
    FROM insurance_history ih
    INNER JOIN insurance i
      ON ih.insurance_id = i.id
    INNER JOIN insurance_plan ip
      ON i.insurance_plan_id = ip.id
    WHERE i.user_id = $1
      AND (
        $2 = ''
        OR LOWER(ip.name) LIKE LOWER($2)
        OR LOWER(i.policy_code) LIKE LOWER($2)
      )
    ORDER BY ih.created_at DESC;
  `;

  const result = await pool.query(query, [
    userId,
    `%${search}%`,
  ]);

  return result.rows;
}
}

export default new InsuranceHistoryRepository();