-- Verify schemas/roles_private/tables/user_email_secrets/policies/enable_row_level_security  on pg

BEGIN;

SELECT verify_security ('roles_private.user_email_secrets');

ROLLBACK;