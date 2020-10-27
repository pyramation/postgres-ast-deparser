-- Deploy: schemas/collections_public/tables/rls_function/policies/authenticated_can_select_on_rls_function to pg
-- made with <3 @ launchql.com

-- requires: schemas/collections_public/schema
-- requires: schemas/collections_public/tables/rls_function/table
-- requires: schemas/collections_public/tables/rls_function/policies/enable_row_level_security

BEGIN;
CREATE POLICY authenticated_can_select_on_rls_function ON collections_public.rls_function FOR SELECT TO authenticated USING ( (SELECT p.owner_id = ANY( "launchql_public".get_current_role_ids() ) FROM collections_public.database AS p WHERE p.id = database_id) );
COMMIT;