-- Revert: schemas/launchql_public/tables/user_profiles/columns/id/column from pg

BEGIN;


ALTER TABLE "launchql_rls_public".user_profiles DROP COLUMN id;
COMMIT;  

