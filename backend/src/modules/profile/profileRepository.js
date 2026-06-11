import pool from '../../config/db.js';

class ProfileRepository {
 
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

export default new ProfileRepository();