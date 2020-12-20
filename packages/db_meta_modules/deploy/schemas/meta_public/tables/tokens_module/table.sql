-- Deploy schemas/meta_public/tables/tokens_module/table to pg

-- requires: schemas/meta_public/schema

BEGIN;

CREATE TABLE meta_public.tokens_module (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4 (),
    database_id uuid NOT NULL,

    --
    schema_id uuid,
    table_id uuid,
    owned_table_id uuid,

    tokens_default_expiration interval NOT NULL DEFAULT '3 days'::interval,
    tokens_table text NOT NULL DEFAULT 'api_tokens',
    --

    CONSTRAINT db_fkey FOREIGN KEY (database_id) REFERENCES collections_public.database (id),
    CONSTRAINT schema_fkey FOREIGN KEY (schema_id) REFERENCES collections_public.schema (id),
    CONSTRAINT table_fkey FOREIGN KEY (table_id) REFERENCES collections_public.table (id),
    CONSTRAINT owned_table_fkey FOREIGN KEY (owned_table_id) REFERENCES collections_public.table (id)
);

COMMENT ON CONSTRAINT schema_fkey ON meta_public.tokens_module IS E'@omit manyToMany';
COMMENT ON CONSTRAINT db_fkey ON meta_public.tokens_module IS E'@omit manyToMany';
CREATE INDEX tokens_module_database_id_idx ON meta_public.tokens_module ( database_id );

COMMENT ON CONSTRAINT owned_table_fkey
     ON meta_public.tokens_module IS E'@omit manyToMany';
COMMENT ON CONSTRAINT table_fkey
     ON meta_public.tokens_module IS E'@omit manyToMany';

COMMIT;
