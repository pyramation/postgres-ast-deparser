-- Revert: schemas/launchql_public/tables/user_connections/triggers/tg_peoplestamps from pg

BEGIN;


ALTER TABLE "launchql_rls_public".user_connections DROP COLUMN created_by;
ALTER TABLE "launchql_rls_public".user_connections DROP COLUMN updated_by;

DROP TRIGGER tg_peoplestamps
ON "launchql_rls_public".user_connections;


COMMIT;  

