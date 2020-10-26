-- Deploy: schemas/collections_public/tables/foreign_key_constraint/policies/authenticated_can_insert_on_foreign_key_constraint to pg
-- made with <3 @ launchql.com

-- requires: schemas/collections_public/schema
-- requires: schemas/collections_public/tables/foreign_key_constraint/table
-- requires: schemas/collections_public/tables/foreign_key_constraint/policies/enable_row_level_security
-- requires: schemas/collections_public/tables/foreign_key_constraint/policies/authenticated_can_select_on_foreign_key_constraint

BEGIN;
CREATE POLICY authenticated_can_insert_on_foreign_key_constraint ON collections_public.foreign_key_constraint FOR INSERT TO authenticated WITH CHECK ( (SELECT p.owner_id = ANY( "launchql_public".get_current_role_ids() ) FROM collections_public.database AS p WHERE p.id = database_id) );
COMMIT;
