-- Verify: schemas/launchql_rls_launchql_rls_collections_public/tables/database/grants/authenticated/delete on pg

BEGIN;
SELECT verify_table_grant('launchql_rls_launchql_rls_collections_public.database', 'delete', 'authenticated');
COMMIT;  

