-- Verify: schemas/launchql_public/tables/user_profiles/policies/authenticated_can_delete_on_user_profiles on pg

BEGIN;
SELECT verify_policy('authenticated_can_delete_on_user_profiles', 'launchql_rls_public.user_profiles');
COMMIT;  
