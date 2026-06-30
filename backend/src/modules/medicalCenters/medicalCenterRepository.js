import pool from "../../config/db.js";

class MedicalCenterRepository {

  async getAllMedicalCenters() {
    const query = `
      SELECT
        id,
        name,
        type,
        address,
        phone,
        is_open
      FROM medical_center
      ORDER BY name;
    `;

    const result = await pool.query(query);
    return result.rows;
  }

  async getMedicalCenterById(id) {
    const query = `
      SELECT
        id,
        name,
        type,
        address,
        phone,
        image_url,
        description,
        email,
        is_open
      FROM medical_center
      WHERE id = $1;
    `;

    const result = await pool.query(query, [id]);
    return result.rows[0];
  }

  async getMedicalCentersByType(type) {
    const query = `
      SELECT
        id,
        name,
        type,
        address,
        phone,
        is_open
      FROM medical_center
      WHERE type = $1
      ORDER BY name;
    `;

    const result = await pool.query(query, [type]);
    return result.rows;
  }

  async searchMedicalCenters(searchTerm) {
    const query = `
      SELECT
        id,
        name,
        type,
        address,
        phone,
        is_open
      FROM medical_center
      WHERE
        LOWER(name) LIKE LOWER($1)
        OR LOWER(type) LIKE LOWER($1)
        OR LOWER(address) LIKE LOWER($1)
      ORDER BY name;
    `;

    const result = await pool.query(query, [`%${searchTerm}%`]);
    return result.rows;
  }
}

export default new MedicalCenterRepository();