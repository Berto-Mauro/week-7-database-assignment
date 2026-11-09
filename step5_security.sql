-- Step 5: least-privilege roles
-- Run as a superuser AFTER the Flyway migrations (roles are cluster-wide,
-- so this is deliberately not a versioned migration).

CREATE ROLE app_read;
CREATE ROLE app_write;

GRANT CONNECT ON DATABASE bootcamp TO app_read, app_write;
GRANT USAGE ON SCHEMA public TO app_read, app_write;

GRANT SELECT ON ALL TABLES IN SCHEMA public TO app_read;
GRANT SELECT, INSERT, UPDATE, DELETE
ON ALL TABLES IN SCHEMA public TO app_write;

CREATE USER api
LOGIN PASSWORD 'strong-secret'
IN ROLE app_write;

-- ---- Extras beyond the lab text (small, safe hardening) ----
-- 1) SERIAL columns (categories.id) need sequence access for INSERTs.
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO app_write;

-- 2) An audit log the app can edit is not an audit log. The trigger only
--    needs INSERT, so remove UPDATE/DELETE from app_write.
REVOKE UPDATE, DELETE ON audit_log FROM app_write;
