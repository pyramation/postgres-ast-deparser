-- Deploy: schemas/launchql_private/tables/user_encrypted_secrets/policies/enable_row_level_security to pg
-- made with <3 @ launchql.com

-- requires: schemas/launchql_private/schema
-- requires: schemas/launchql_private/tables/user_encrypted_secrets/table
-- requires: schemas/launchql_public/tables/users/grants/authenticated/select

BEGIN;

ALTER TABLE "launchql_private".user_encrypted_secrets
    ENABLE ROW LEVEL SECURITY;
COMMIT;
