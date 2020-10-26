-- Deploy: schemas/launchql_public/tables/user_profiles/columns/user_id/column to pg
-- made with <3 @ launchql.com

-- requires: schemas/launchql_public/schema
-- requires: schemas/launchql_public/tables/user_profiles/table
-- requires: schemas/launchql_public/tables/user_profiles/triggers/tg_timestamps

BEGIN;

ALTER TABLE "launchql_public".user_profiles ADD COLUMN user_id uuid;
COMMIT;
