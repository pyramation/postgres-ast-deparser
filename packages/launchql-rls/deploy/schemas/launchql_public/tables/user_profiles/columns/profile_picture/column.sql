-- Deploy: schemas/launchql_public/tables/user_profiles/columns/profile_picture/column to pg
-- made with <3 @ launchql.com

-- requires: schemas/launchql_public/schema
-- requires: schemas/launchql_public/tables/user_profiles/table
-- requires: schemas/launchql_public/tables/user_profiles/constraints/user_profiles_pkey

BEGIN;

ALTER TABLE "launchql_public".user_profiles ADD COLUMN profile_picture image;
COMMIT;