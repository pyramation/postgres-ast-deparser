-- Verify: schemas/launchql_private/tables/user_encrypted_secrets/grants/authenticated/insert on pg

BEGIN;
SELECT verify_table_grant('launchql_rls_private.user_encrypted_secrets', 'insert', 'authenticated');
COMMIT;  
