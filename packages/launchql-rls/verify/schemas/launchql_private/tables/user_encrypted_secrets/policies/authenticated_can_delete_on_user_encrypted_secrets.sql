-- Verify: schemas/launchql_private/tables/user_encrypted_secrets/policies/authenticated_can_delete_on_user_encrypted_secrets on pg

BEGIN;
SELECT verify_policy('authenticated_can_delete_on_user_encrypted_secrets', 'launchql_rls_private.user_encrypted_secrets');
COMMIT;  

