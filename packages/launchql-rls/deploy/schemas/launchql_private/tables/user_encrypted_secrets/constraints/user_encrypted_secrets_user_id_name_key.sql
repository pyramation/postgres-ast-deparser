-- Deploy: schemas/launchql_private/tables/user_encrypted_secrets/constraints/user_encrypted_secrets_user_id_name_key to pg
-- made with <3 @ launchql.com

-- requires: schemas/launchql_private/schema
-- requires: schemas/launchql_private/tables/user_encrypted_secrets/table
-- requires: schemas/launchql_private/tables/user_encrypted_secrets/constraints/user_encrypted_secrets_pkey

BEGIN;

ALTER TABLE "launchql_private".user_encrypted_secrets
    ADD CONSTRAINT user_encrypted_secrets_user_id_name_key UNIQUE (user_id,name);
COMMIT;