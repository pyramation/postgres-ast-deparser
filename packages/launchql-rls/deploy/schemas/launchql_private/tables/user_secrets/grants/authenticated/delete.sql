-- Deploy: schemas/launchql_private/tables/user_secrets/grants/authenticated/delete to pg
-- made with <3 @ launchql.com

-- requires: schemas/launchql_private/schema
-- requires: schemas/launchql_private/tables/user_secrets/table
-- requires: schemas/launchql_private/tables/user_secrets/grants/authenticated/update

BEGIN;
GRANT DELETE ON TABLE "launchql_private".user_secrets TO authenticated;
COMMIT;
