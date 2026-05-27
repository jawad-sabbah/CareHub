import pool from "../../config/db.js";

class DashboardRepository {

   async getInsurancePoliciesByUserId(userId){
    const query='select * from insurance join insurance_plan on insurance.insurance_plan_id=insurance_plan.id where insurance.user_id=$1';
    const values=[userId];
    const result=await pool.query(query,values);
    return result.rows;
   }

   
}

export default new DashboardRepository();