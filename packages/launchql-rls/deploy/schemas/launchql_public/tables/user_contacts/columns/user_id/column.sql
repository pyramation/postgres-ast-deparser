-- Deploy: schemas/launchql_public/tables/user_contacts/columns/user_id/column to pg
-- made with <3 @ launchql.com

-- requires: schemas/launchql_public/schema
-- requires: schemas/launchql_public/tables/user_contacts/table
-- requires: schemas/launchql_public/tables/user_contacts/triggers/tg_timestamps

BEGIN;

ALTER TABLE "launchql_public".user_contacts ADD COLUMN user_id uuid;
COMMIT;
