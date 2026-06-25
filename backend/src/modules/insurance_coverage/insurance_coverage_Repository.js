import pool from '../../config/db.js'

class InsuranceCoverageRepository
{
   async getPlanCoverageByUserId(userId){
     const query=`
      SELECT 
    u.username,
    i.policy_code,
    i.provider_name,
    i.status,
    i.expiry_date,

    ip.name AS plan_name,
    ip.coverage_percentage,
    ip.annual_limit,

    COALESCE(SUM(mr.cost * ip.coverage_percentage / 100), 0) AS used_amount,
    ip.annual_limit - COALESCE(SUM(mr.cost * ip.coverage_percentage / 100), 0) AS remaining_amount,

    json_agg(DISTINCT ipb.benefit) AS benefits

FROM users u

JOIN insurance i 
    ON u.id = i.user_id

JOIN insurance_plan ip 
    ON i.insurance_plan_id = ip.id

LEFT JOIN medical_record mr
    ON mr.user_id = u.id

LEFT JOIN insurance_plan_benefit ipb
    ON ip.id = ipb.insurance_plan_id

WHERE u.id = $1

GROUP BY 
    u.username,
    i.policy_code,
    i.provider_name,
    i.status,
    i.expiry_date,
    ip.name,
    ip.coverage_percentage,
    ip.annual_limit;
     `
     const result=await pool.query(query,[userId])
     return result.rows[0]
   }
}
export default new InsuranceCoverageRepository()