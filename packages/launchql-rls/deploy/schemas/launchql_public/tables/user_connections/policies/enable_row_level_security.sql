-- Deploy: schemas/launchql_public/tables/user_connections/policies/enable_row_level_security to pg
-- made with <3 @ launchql.com

-- requires: schemas/launchql_public/schema
-- requires: schemas/launchql_public/tables/user_connections/table
-- requires: schemas/launchql_public/tables/user_connections/constraints/user_connections_requester_id_responder_id_key

BEGIN;

ALTER TABLE "launchql_public".user_connections
    ENABLE ROW LEVEL SECURITY;
COMMIT;