-- Deploy: schemas/collections_public/tables/schema/grants/authenticated/delete to pg
-- made with <3 @ launchql.com

-- requires: schemas/collections_public/schema
-- requires: schemas/collections_public/tables/schema/table
-- requires: schemas/collections_public/tables/schema/grants/authenticated/update

BEGIN;
GRANT DELETE ON TABLE collections_public.schema TO authenticated;
COMMIT;
