-- Deploy: schemas/launchql_private/tables/user_encrypted_secrets/columns/enc/column to pg
-- made with <3 @ launchql.com

-- requires: schemas/launchql_private/schema
-- requires: schemas/launchql_private/tables/user_encrypted_secrets/table
-- requires: schemas/launchql_private/tables/user_encrypted_secrets/columns/value/column

BEGIN;

ALTER TABLE "launchql_private".user_encrypted_secrets ADD COLUMN enc text;
COMMIT;
