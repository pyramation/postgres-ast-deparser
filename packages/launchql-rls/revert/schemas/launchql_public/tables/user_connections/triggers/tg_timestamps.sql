-- Revert: schemas/launchql_public/tables/user_connections/triggers/tg_timestamps from pg

BEGIN;


ALTER TABLE "launchql_rls_public".user_connections DROP COLUMN created_at;
ALTER TABLE "launchql_rls_public".user_connections DROP COLUMN updated_at;

DROP TRIGGER tg_timestamps ON "launchql_rls_public".user_connections;

COMMIT;  

