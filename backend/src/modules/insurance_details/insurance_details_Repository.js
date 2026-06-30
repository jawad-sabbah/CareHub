import pool from '../../config/db.js'

class insuranceDetailsRepository
{
  async getInsuranceDetailsByUserId(userId){
     const query=`
      select
        users.id as user_id,
        username,
        relation_id,
        insurance.id as insurance_id,
        policy_code,
        provider_name,
        status,
        start_date,
        expiry_date,
        insurance_plan.id as plan_id,
        name as plan_name,
        coverage_percentage,
        annual_limit,
        description
      from users
      join insurance
      on insurance.user_id = COALESCE(users.parent_id, users.id)
      join insurance_plan
      on insurance.insurance_plan_id=insurance_plan.id
      where users.id=$1
     `
    const result = await pool.query(query, [userId]);
    return result.rows[0];
  }
}

export default new insuranceDetailsRepository()