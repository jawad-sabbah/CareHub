import pool from "../../config/db.js";

class DashboardRepository {

  async getUserById(id) {
    const query = `SELECT * FROM users WHERE id = $1`;
    const result = await pool.query(query, [id]);
    return result.rows[0];
  }
  
  async getInsuranceByUserId(userId) {
  const query = `
    SELECT
      i.id,
      i.policy_code,
      i.provider_name,
      i.status,
      i.start_date,
      i.expiry_date,
      ip.id AS insurance_plan_id,
      ip.name,
      ip.coverage_percentage,
      ip.annual_limit,
      ip.description
    FROM insurance i
    JOIN insurance_plan ip
      ON i.insurance_plan_id = ip.id
    JOIN users u
      ON u.id = $1
    WHERE i.user_id = u.id
    LIMIT 1;
  `;

  const result = await pool.query(query, [userId]);
  return result.rows[0];
}

  async getRecentMedicalRecords(userId) {
    const query = `
      SELECT
        mr.id,
        ms.name AS service_name,
        mc.name AS medical_center,
        mr.visit_date
      FROM medical_record mr
      JOIN medical_record_service mrs
        ON mr.id = mrs.medical_record_id
      JOIN medical_service ms
        ON mrs.service_id = ms.id
      JOIN medical_center mc
        ON mr.medical_center_id = mc.id
      WHERE mr.user_id = $1
      ORDER BY mr.visit_date DESC
      LIMIT 3;
    `;

    const result = await pool.query(query, [userId]);
    return result.rows;
  }

  async getFamilyMembersCount(userId) {
    const query = `
      SELECT COUNT(*) AS total
      FROM users
      WHERE parent_id = $1;
    `;

    const result = await pool.query(query, [userId]);
    return Number(result.rows[0].total);
  }

  async getMedicalRecordsCount(userId) {
    const query = `
      SELECT COUNT(*) AS total
      FROM medical_record
      WHERE user_id = $1;
    `;

    const result = await pool.query(query, [userId]);
    return Number(result.rows[0].total);
  }


  async getCoverageUsage(userId) {
    const query = `
      SELECT
        ip.annual_limit,
        COALESCE(usage.used_amount, 0) AS used_amount
      FROM users u
      JOIN insurance i        ON i.user_id = u.id
      JOIN insurance_plan ip  ON i.insurance_plan_id = ip.id
      LEFT JOIN (
        SELECT
          mr.user_id,
          SUM(ms.default_cost * ip2.coverage_percentage / 100) AS used_amount
        FROM medical_record mr
        JOIN medical_record_service mrs ON mrs.medical_record_id = mr.id
        JOIN medical_service ms         ON ms.id = mrs.service_id
        JOIN insurance i2               ON i2.user_id = mr.user_id
        JOIN insurance_plan ip2         ON ip2.id = i2.insurance_plan_id
        GROUP BY mr.user_id
      ) usage ON usage.user_id = u.id
      WHERE u.id = $1
      LIMIT 1;
    `;
    const result = await pool.query(query, [userId]);
    return result.rows[0]; // { annual_limit, used_amount } or undefined
  }

  async getMonthlyVisits(userId) {
    const query = `
      SELECT
        to_char(m.month_start, 'Mon') AS label,
        COALESCE(v.count, 0)::int     AS count
      FROM generate_series(
             date_trunc('month', CURRENT_DATE) - INTERVAL '5 months',
             date_trunc('month', CURRENT_DATE),
             INTERVAL '1 month'
           ) AS m(month_start)
      LEFT JOIN (
        SELECT date_trunc('month', visit_date) AS month_start, COUNT(*) AS count
        FROM medical_record
        WHERE user_id = $1
        GROUP BY 1
      ) v ON v.month_start = m.month_start
      ORDER BY m.month_start ASC;
    `;
    const result = await pool.query(query, [userId]);
    return result.rows;
  }
}

export default new DashboardRepository();
