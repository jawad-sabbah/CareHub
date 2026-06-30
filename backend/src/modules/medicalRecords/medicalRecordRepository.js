import pool from '../../config/db.js';

class MedicalRecordRepository {
  async getAllMedicalRecords(userId, type) {
    let query = `
      SELECT 
        mr.*,
        mc.name AS center_name,
        mc.type AS center_type,
        mc.address AS center_address,
        mc.phone AS center_phone
      FROM medical_record mr
      JOIN medical_center mc
        ON mr.medical_center_id = mc.id
      WHERE mr.user_id = $1
    `;

    const values = [userId];

    if (type && type !== 'all') {
      values.push(type);
      query += ` AND LOWER(mc.type) = LOWER($${values.length})`;
    }

    query += ` ORDER BY mr.visit_date DESC`;

    const result = await pool.query(query, values);
    return result.rows;
  }

  async getMedicalRecordById(recordId, userId) {
      const query = `SELECT
    mr.id AS record_id,  
    mr.diagnosis,
    mr.icd10_code,
    mr.visit_date,

    mc.name AS center_name,

    mrs.chief_complaint,
    mrs.physical_exam,

    ms.name AS service_name,
    ms.description,
    ms.default_cost,

    cd.coverage_percentage

FROM medical_record mr

JOIN medical_center mc
    ON mc.id = mr.medical_center_id

JOIN medical_record_service mrs
    ON mrs.medical_record_id = mr.id

JOIN medical_service ms
    ON ms.id = mrs.service_id

JOIN insurance i
    ON i.user_id = mr.user_id

JOIN coverage_details cd
    ON cd.medical_service_id = ms.id
   AND cd.insurance_plan_id = i.insurance_plan_id

WHERE mr.id = $1
  AND mr.user_id = $2;`;

    const result = await pool.query(query, [recordId, userId]);
    return result.rows
  }
}

export default new MedicalRecordRepository();