import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";
import pg from "pg";

const __dirname = path.dirname(fileURLToPath(import.meta.url));

const { Pool } = pg;
const pool = new Pool({
  user: "postgres",          // your DB user
  host: "localhost",         // your DB host
  database: "careHub",       // your DB name
  password: "opas1@",  // your DB password, as a string
  port: 5432,                // your DB port
});

const sql = fs.readFileSync(
  path.join(__dirname, "migrations", "2026_07_shared_policy_code.sql"),
  "utf8"
);

try {
  await pool.query(sql);
  console.log("Migration ran successfully");
} catch (err) {
  console.error("Migration failed:", err.message);
} finally {
  await pool.end();
}