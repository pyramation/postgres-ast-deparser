-- Revert: schemas/launchql_public/tables/users/policies/authenticated_can_delete_on_users from pg

BEGIN;
DROP POLICY authenticated_can_delete_on_users ON "launchql_rls_public".users;
COMMIT;  
