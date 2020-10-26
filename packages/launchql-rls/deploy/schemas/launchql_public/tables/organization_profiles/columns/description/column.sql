-- Deploy: schemas/launchql_public/tables/organization_profiles/columns/description/column to pg
-- made with <3 @ launchql.com

-- requires: schemas/launchql_public/schema
-- requires: schemas/launchql_public/tables/organization_profiles/table
-- requires: schemas/launchql_public/tables/organization_profiles/columns/profile_picture/column

BEGIN;

ALTER TABLE "launchql_public".organization_profiles ADD COLUMN description text;
COMMIT;
