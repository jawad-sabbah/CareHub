BEGIN;

-- Drop the UNIQUE constraint on policy_code so the family can share one code.
DO $$
DECLARE
  cname text;
BEGIN
  SELECT con.conname INTO cname
  FROM pg_constraint con
  JOIN pg_attribute a
    ON a.attrelid = con.conrelid AND a.attnum = ANY(con.conkey)
  WHERE con.conrelid = 'insurance'::regclass
    AND con.contype = 'u'
    AND a.attname = 'policy_code'
    AND array_length(con.conkey, 1) = 1
  LIMIT 1;

  IF cname IS NOT NULL THEN
    EXECUTE format('ALTER TABLE insurance DROP CONSTRAINT %I', cname);
  END IF;
END $$;

-- Reset existing dependents to share the primary's exact policy_code
-- (removes the "-<id>" suffix added earlier).
UPDATE insurance dep_ins
SET policy_code = own.policy_code
FROM users dep
JOIN LATERAL (
  SELECT i.policy_code
  FROM insurance i
  WHERE i.user_id = dep.parent_id
  ORDER BY i.id DESC
  LIMIT 1
) own ON TRUE
WHERE dep_ins.user_id = dep.id
  AND dep.parent_id IS NOT NULL;

COMMIT;