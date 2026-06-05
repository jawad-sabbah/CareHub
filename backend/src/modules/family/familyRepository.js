import pool from "../../config/db.js";


class FamilyRepository {
   
  async getFamilyMembersByUserId(userId) {
  const query = `
    SELECT
      u.id,
      u.username,
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
}

export default new FamilyRepository();