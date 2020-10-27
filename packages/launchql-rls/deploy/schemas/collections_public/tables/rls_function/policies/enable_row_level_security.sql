-- Deploy: schemas/collections_public/tables/rls_function/policies/enable_row_level_security to pg
-- made with <3 @ launchql.com

-- requires: schemas/collections_public/schema
-- requires: schemas/collections_public/tables/rls_function/table
-- requires: schemas/collections_public/tables/index/grants/authenticated/delete

BEGIN;

ALTER TABLE collections_public.rls_function
    ENABLE ROW LEVEL SECURITY;
COMMIT;