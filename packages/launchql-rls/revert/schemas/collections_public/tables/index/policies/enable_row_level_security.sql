-- Revert: schemas/collections_public/tables/index/policies/enable_row_level_security from pg

BEGIN;


ALTER TABLE launchql_rls_collections_public.index
    DISABLE ROW LEVEL SECURITY;

COMMIT;  

