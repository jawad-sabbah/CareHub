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
      WHERE i.user_id = $1
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
}

export default new DashboardRepository();