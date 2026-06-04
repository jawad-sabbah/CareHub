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

  async getUserById(id) {
    const query = `SELECT * FROM users WHERE id = $1`;
    const result = await pool.query(query, [id]);
    return result.rows[0];
  }

  async updatePassword(userId, hashedPassword) {
    const query = `
      UPDATE users
      SET password = $1
      WHERE id = $2
      RETURNING id, username, email, role
    `;

    const result = await pool.query(query, [hashedPassword, userId]);
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

  async registerFamilyMember(fullName, email, phone_number, date_of_birth, hashedPassword, parent_id, relation_id) {
    const query = `
      INSERT INTO users
      (parent_id, username, email, password, phone_number, date_of_birth, gender, role, relation_id)
      VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9)
      RETURNING id, parent_id, username, email, phone_number, date_of_birth, gender, role, relation_id, created_at
    `;

    const values = [
      parent_id,
      fullName,
      email,
      hashedPassword,
      phone_number,
      date_of_birth,
      null,
      'user',
      relation_id
    ];

    const result = await pool.query(query, values);
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


  async getUserByEmailExceptUserId(email, userId) {
  const query = `
    SELECT *
    FROM users
    WHERE email = $1
    AND id != $2
  `;

  const result = await pool.query(query, [email, userId]);
  return result.rows[0];
}

async updateProfile(userId, fullName, email, phone_number, gender) {
  const query = `
    UPDATE users
    SET
      username = $1,
      email = $2,
      phone_number = $3,
      gender = $4
    WHERE id = $5
    RETURNING
      id,
      username,
      email,
      phone_number,
      gender,
      role,
      created_at
  `;

  const result = await pool.query(query, [
    fullName,
    email,
    phone_number,
    gender,
    userId
  ]);

  return result.rows[0];
}

}

export default new AuthRepository();