BEGIN;

-- 1) Each active dependent gets their own insurance row, copied from the primary.
--    policy_code is UNIQUE, so we derive a per-dependent code: "<primary>-<depId>".
INSERT INTO insurance
  (user_id, insurance_plan_id, policy_code, provider_name, status, start_date, expiry_date)
SELECT
  dep.id,
  own.insurance_plan_id,
  own.policy_code || '-' || dep.id::text,
  own.provider_name,
  own.status,
  own.start_date,
  own.expiry_date
FROM users dep
JOIN LATERAL (
  SELECT i.* FROM insurance i
  WHERE i.user_id = dep.parent_id
  ORDER BY i.id DESC
  LIMIT 1
) own ON TRUE
WHERE dep.parent_id IS NOT NULL
  AND dep.is_active = TRUE
  AND NOT EXISTS (
    SELECT 1 FROM insurance x WHERE x.user_id = dep.id
  );

-- 2) History entry for each newly created dependent policy.
INSERT INTO insurance_history (insurance_id, action_type, description)
SELECT i.id, 'ADDED', 'Dependent added to primary policy'
FROM insurance i
JOIN users dep ON dep.id = i.user_id
WHERE dep.parent_id IS NOT NULL
  AND dep.is_active = TRUE
  AND NOT EXISTS (SELECT 1 FROM insurance_history h WHERE h.insurance_id = i.id);

COMMIT;