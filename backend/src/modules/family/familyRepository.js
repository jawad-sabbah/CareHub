import pool from "../../config/db.js";


class FamilyRepository {
   
  async getFamilyMembersByUserId(userId) {
  const query = `
    SELECT
      u.id,
      u.username,
      u.email,
      u.phone_number,
      u.date_of_birth,
      u.gender,
      u.created_at,
      r.description AS relation
    FROM users u
    LEFT JOIN relation r
      ON u.relation_id = r.id
    WHERE
      (u.id = $1 OR u.parent_id = $1)
      AND u.is_active = TRUE
    ORDER BY
      CASE
        WHEN u.id = $1 THEN 0
        ELSE 1
      END;
  `;

  const result = await pool.query(query, [userId]);

  return result.rows;
}

  async getFamilyMembersCount(userId) {
  const query = `
    SELECT COUNT(*) AS total
    FROM users
    WHERE parent_id = $1
      AND is_active = TRUE;
  `;

  const result = await pool.query(query, [userId]);

  return Number(result.rows[0].total);
}

  async registerFamilyMember(fullName, email, phone_number, date_of_birth,gender, hashedPassword, parent_id, relation_id) {
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
      gender,
      'user',
      relation_id
    ];

    const result = await pool.query(query, values);
    return result.rows[0];
  }

  async deleteFamilyMember(memberId, userId) {
  const query = `
    UPDATE users
    SET is_active = FALSE
    WHERE id = $1
      AND parent_id = $2
      AND is_active = TRUE
    RETURNING id, username, is_active;
  `;

  const values = [memberId, userId];

  const result = await pool.query(query, values);

  return result.rows[0];
}


async searchEligibleMembers(ownerId, term) {
    const query = `
      SELECT u.id, u.username, u.email
      FROM users u
      WHERE u.is_active = TRUE
        AND u.id <> $1
        AND COALESCE(u.parent_id, 0) <> $1
        AND (u.username ILIKE $2 OR u.email ILIKE $2)
      ORDER BY u.username
      LIMIT 10;
    `;
    const result = await pool.query(query, [ownerId, `%${term}%`]);
    return result.rows;
  }

  async enrollMember(ownerId, memberId, relationId) {
    const query = `
      UPDATE users
      SET parent_id = $1, relation_id = $3
      WHERE id = $2
        AND is_active = TRUE
        AND COALESCE(parent_id, 0) <> $1
      RETURNING id, username, email;
    `;
    const result = await pool.query(query, [ownerId, memberId, relationId]);
    return result.rows[0];
  }


}

export default new FamilyRepository();