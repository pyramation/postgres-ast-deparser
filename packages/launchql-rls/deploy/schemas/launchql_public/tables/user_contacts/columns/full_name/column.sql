-- Deploy: schemas/launchql_public/tables/user_contacts/columns/full_name/column to pg
-- made with <3 @ launchql.com

-- requires: schemas/launchql_public/schema
-- requires: schemas/launchql_public/tables/user_contacts/table
-- requires: schemas/launchql_public/tables/user_contacts/columns/vcf/column

BEGIN;

ALTER TABLE "launchql_public".user_contacts ADD COLUMN full_name text;
COMMIT;