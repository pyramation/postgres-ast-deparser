-- Revert schemas/auth_public/grants/grant_schema_to_administrator from pg

BEGIN;

REVOKE USAGE ON SCHEMA auth_public FROM administrator;

COMMIT;