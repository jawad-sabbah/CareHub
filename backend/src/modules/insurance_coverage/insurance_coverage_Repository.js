import pool from '../../config/db.js'

class InsuranceCoverageRepository
{
   async getPlanCoverageByUserId(userId){
     const query=`
      SELECT
        u.id AS user_id,
        u.username,
        i.policy_code,
        i.provider_name,
        i.status,
        i.expiry_date,

        ip.name AS plan_name,
        ip.coverage_percentage,
        ip.annual_limit,

        COALESCE(usage.used_amount, 0) AS used_amount,
        ip.annual_limit - COALESCE(usage.used_amount, 0) AS remaining_amount,

        json_agg(DISTINCT ipb.benefit) AS benefits

      FROM users u

      JOIN insurance i
        ON i.user_id = u.id

      JOIN insurance_plan ip
        ON i.insurance_plan_id = ip.id

      LEFT JOIN insurance_plan_benefit ipb
        ON ip.id = ipb.insurance_plan_id

      LEFT JOIN (
        SELECT
          mr.user_id,
          SUM(ms.default_cost * ip2.coverage_percentage / 100) AS used_amount
        FROM medical_record mr
        JOIN medical_record_service mrs
          ON mrs.medical_record_id = mr.id
        JOIN medical_service ms
          ON ms.id = mrs.service_id
        JOIN insurance i2
          ON i2.user_id = mr.user_id
        JOIN insurance_plan ip2
          ON ip2.id = i2.insurance_plan_id
        GROUP BY mr.user_id
      ) usage
        ON usage.user_id = u.id

      WHERE u.id = $1

      GROUP BY
        u.id,
        u.username,
        i.policy_code,
        i.provider_name,
        i.status,
        i.expiry_date,
        ip.name,
        ip.coverage_percentage,
        ip.annual_limit,
        usage.used_amount;
     `
     const result=await pool.query(query,[userId])
     return result.rows[0]
   }
}
export default new InsuranceCoverageRepository()