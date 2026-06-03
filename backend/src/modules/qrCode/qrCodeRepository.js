import pool  from "../../config/db.js";

class QrCodeRepository {
 async findPolicyByCode(policyCode) {
    const query = 'SELECT * FROM insurance WHERE policy_code = $1';
    const values = [policyCode];
    const result = await pool.query(query, values);
    return result.rows[0];
 }
}

export default new QrCodeRepository();