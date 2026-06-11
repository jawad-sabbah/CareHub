import pool from '../../config/db.js';

class AuthRepository {
  async registerAsInsuranceOwner(fullName, email, phone_number, date_of_birth, gender, password) {
    const query = `
      INSERT INTO users
      (parent_id, username, email, password, phone_number, date_of_birth, gender, role, relation_id)
      VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9)
      RETURNING id, username, email, phone_number, date_of_birth, gender, role, created_at
    `;

    const values = [
      null,
      fullName,
      email,
      password,
      phone_number,
      date_of_birth,
      gender,
      'user',
      null
    ];

    const result = await pool.query(query, values);
    return result.rows[0];
  }

  async getUserByEmail(email) {
    const query = `SELECT * FROM users WHERE email = $1`;
    const result = await pool.query(query, [email]);
    return result.rows[0];
  }

  async getInsuranceByOwnerAndPolicyCode(ownerId, policyCode) {
    const query = `
      SELECT *
      FROM insurance
      WHERE user_id = $1
      AND policy_code = $2
    `;

    const result = await pool.query(query, [ownerId, policyCode]);
    return result.rows[0];
  }

  async findFamilyMemberInvite(ownerId, fullName, relationId) {
    const query = `
      SELECT id, parent_id, username, email, phone_number, date_of_birth, gender, role, relation_id, created_at
      FROM users
      WHERE parent_id = $1
      AND LOWER(username) = LOWER($2)
      AND relation_id = $3
    `;

    const result = await pool.query(query, [
      ownerId,
      fullName,
      relationId
    ]);

    return result.rows[0];
  }

}

export default new AuthRepository();