-- Verify schemas/roles_public/tables/role_settings/table on pg

BEGIN;

SELECT verify_table ('roles_public.role_settings');

ROLLBACK;