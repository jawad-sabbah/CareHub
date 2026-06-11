import pool from '../../config/db.js'

class insuranceDetailsRepository
{
  async getInsuranceDetailsByUserId(userId){
     const query=`
      select users.id as user_id,username,relation_id,policy_code,provider_name,status,start_date,expiry_date,name as planName,coverage_percentage,annual_limit,description
      from users 
      join insurance
      on users.id=insurance.user_id
      join insurance_plan
      on insurance.insurance_plan_id=insurance_plan.id
      where users.id=$1
     `
    const result = await pool.query(query, [userId]);
    return result.rows[0];
  }
}

export default new insuranceDetailsRepository()