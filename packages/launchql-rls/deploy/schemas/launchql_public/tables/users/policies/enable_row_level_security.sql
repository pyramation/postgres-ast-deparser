-- Deploy: schemas/launchql_public/tables/users/policies/enable_row_level_security to pg
-- made with <3 @ launchql.com

-- requires: schemas/launchql_public/schema
-- requires: schemas/launchql_public/tables/users/table

BEGIN;

ALTER TABLE "launchql_public".users
    ENABLE ROW LEVEL SECURITY;
COMMIT;
