\echo Use "CREATE EXTENSION db_meta_modules" to load this file. \quit
CREATE TABLE meta_public.emails_module (
 	id uuid PRIMARY KEY DEFAULT ( uuid_generate_v4() ),
	database_id uuid NOT NULL,
	schema_id uuid NOT NULL,
	table_id uuid,
	emails_table text,
	multiple_emails boolean DEFAULT ( FALSE ),
	CONSTRAINT db_fkey FOREIGN KEY ( database_id ) REFERENCES collections_public.database ( id ),
	CONSTRAINT table_fkey FOREIGN KEY ( table_id ) REFERENCES collections_public."table" ( id ),
	CONSTRAINT schema_fkey FOREIGN KEY ( schema_id ) REFERENCES collections_public.schema ( id ) 
);

COMMENT ON CONSTRAINT schema_fkey ON meta_public.emails_module IS E'@omit manyToMany';

COMMENT ON CONSTRAINT table_fkey ON meta_public.emails_module IS E'@omit manyToMany';

COMMENT ON CONSTRAINT db_fkey ON meta_public.emails_module IS E'@omit manyToMany';

CREATE INDEX emails_module_database_id_idx ON meta_public.emails_module ( database_id );

CREATE TABLE meta_public.invites_module (
 	id uuid PRIMARY KEY DEFAULT ( uuid_generate_v4() ),
	database_id uuid NOT NULL,
	schema_id uuid NOT NULL,
	private_schema_id uuid NOT NULL,
	emails_table_id uuid,
	users_table_id uuid,
	invites_table_id uuid,
	claimed_invites_table_id uuid,
	invites_table_name text NOT NULL DEFAULT ( 'invites' ),
	claimed_invites_table_name text NOT NULL DEFAULT ( 'claimed_invites' ),
	submit_invite_code_function text NOT NULL DEFAULT ( 'submit_invite_code' ),
	CONSTRAINT db_fkey FOREIGN KEY ( database_id ) REFERENCES collections_public.database ( id ),
	CONSTRAINT invites_table_fkey FOREIGN KEY ( invites_table_id ) REFERENCES collections_public."table" ( id ),
	CONSTRAINT emails_table_fkey FOREIGN KEY ( emails_table_id ) REFERENCES collections_public."table" ( id ),
	CONSTRAINT users_table_fkey FOREIGN KEY ( users_table_id ) REFERENCES collections_public."table" ( id ),
	CONSTRAINT claimed_invites_table_fkey FOREIGN KEY ( claimed_invites_table_id ) REFERENCES collections_public."table" ( id ),
	CONSTRAINT schema_fkey FOREIGN KEY ( schema_id ) REFERENCES collections_public.schema ( id ),
	CONSTRAINT pschema_fkey FOREIGN KEY ( private_schema_id ) REFERENCES collections_public.schema ( id ) 
);

COMMENT ON CONSTRAINT db_fkey ON meta_public.invites_module IS E'@omit manyToMany';

COMMENT ON CONSTRAINT emails_table_fkey ON meta_public.invites_module IS E'@omit manyToMany';

COMMENT ON CONSTRAINT users_table_fkey ON meta_public.invites_module IS E'@omit manyToMany';

COMMENT ON CONSTRAINT invites_table_fkey ON meta_public.invites_module IS E'@omit manyToMany';

COMMENT ON CONSTRAINT claimed_invites_table_fkey ON meta_public.invites_module IS E'@omit manyToMany';

COMMENT ON CONSTRAINT schema_fkey ON meta_public.invites_module IS E'@omit manyToMany';

COMMENT ON CONSTRAINT pschema_fkey ON meta_public.invites_module IS E'@omit manyToMany';

CREATE INDEX invites_module_database_id_idx ON meta_public.invites_module ( database_id );

CREATE TABLE meta_public.rls_module (
 	id uuid PRIMARY KEY DEFAULT ( uuid_generate_v4() ),
	database_id uuid NOT NULL,
	schema_id uuid NOT NULL,
	private_schema_id uuid NOT NULL,
	tokens_table_id uuid,
	users_table_id uuid,
	authenticate text NOT NULL DEFAULT ( 'authenticate' ),
	"current_role" text NOT NULL DEFAULT ( 'current_user' ),
	current_role_id text NOT NULL DEFAULT ( 'current_user_id' ),
	current_group_ids text NOT NULL DEFAULT ( 'current_group_ids' ),
	CONSTRAINT db_fkey FOREIGN KEY ( database_id ) REFERENCES collections_public.database ( id ),
	CONSTRAINT tokens_table_fkey FOREIGN KEY ( tokens_table_id ) REFERENCES collections_public."table" ( id ),
	CONSTRAINT users_table_fkey FOREIGN KEY ( users_table_id ) REFERENCES collections_public."table" ( id ),
	CONSTRAINT schema_fkey FOREIGN KEY ( schema_id ) REFERENCES collections_public.schema ( id ),
	CONSTRAINT pschema_fkey FOREIGN KEY ( private_schema_id ) REFERENCES collections_public.schema ( id ) 
);

COMMENT ON CONSTRAINT db_fkey ON meta_public.rls_module IS E'@omit manyToMany';

COMMENT ON CONSTRAINT tokens_table_fkey ON meta_public.rls_module IS E'@omit manyToMany';

COMMENT ON CONSTRAINT users_table_fkey ON meta_public.rls_module IS E'@omit manyToMany';

COMMENT ON CONSTRAINT schema_fkey ON meta_public.rls_module IS E'@omit manyToMany';

COMMENT ON CONSTRAINT pschema_fkey ON meta_public.rls_module IS E'@omit manyToMany';

CREATE INDEX rls_module_database_id_idx ON meta_public.rls_module ( database_id );

CREATE TABLE meta_public.user_auth_module (
 	id uuid PRIMARY KEY DEFAULT ( uuid_generate_v4() ),
	database_id uuid NOT NULL,
	schema_id uuid NOT NULL,
	sign_in_function text NOT NULL DEFAULT ( 'login' ),
	sign_up_function text NOT NULL DEFAULT ( 'register' ),
	sign_out_function text NOT NULL DEFAULT ( 'logout' ),
	set_password_function text NOT NULL DEFAULT ( 'set_password' ),
	reset_password_function text NOT NULL DEFAULT ( 'reset_password' ),
	forgot_password_function text NOT NULL DEFAULT ( 'forgot_password' ),
	send_verification_email_function text NOT NULL DEFAULT ( 'send_verification_email' ),
	verify_email_function text NOT NULL DEFAULT ( 'verify_email' ),
	emails_table_id uuid NOT NULL,
	users_table_id uuid NOT NULL,
	secrets_table_id uuid NOT NULL,
	encrypted_table_id uuid NOT NULL,
	tokens_table_id uuid NOT NULL,
	CONSTRAINT db_fkey FOREIGN KEY ( database_id ) REFERENCES collections_public.database ( id ),
	CONSTRAINT schema_fkey FOREIGN KEY ( schema_id ) REFERENCES collections_public.schema ( id ),
	CONSTRAINT email_table_fkey FOREIGN KEY ( emails_table_id ) REFERENCES collections_public."table" ( id ),
	CONSTRAINT users_table_fkey FOREIGN KEY ( users_table_id ) REFERENCES collections_public."table" ( id ),
	CONSTRAINT secrets_table_fkey FOREIGN KEY ( secrets_table_id ) REFERENCES collections_public."table" ( id ),
	CONSTRAINT encrypted_table_fkey FOREIGN KEY ( encrypted_table_id ) REFERENCES collections_public."table" ( id ),
	CONSTRAINT tokens_table_fkey FOREIGN KEY ( tokens_table_id ) REFERENCES collections_public."table" ( id ) 
);

COMMENT ON CONSTRAINT schema_fkey ON meta_public.user_auth_module IS E'@omit manyToMany';

COMMENT ON CONSTRAINT db_fkey ON meta_public.user_auth_module IS E'@omit manyToMany';

CREATE INDEX user_auth_module_database_id_idx ON meta_public.user_auth_module ( database_id );

COMMENT ON CONSTRAINT email_table_fkey ON meta_public.user_auth_module IS E'@omit manyToMany';

COMMENT ON CONSTRAINT users_table_fkey ON meta_public.user_auth_module IS E'@omit manyToMany';

COMMENT ON CONSTRAINT secrets_table_fkey ON meta_public.user_auth_module IS E'@omit manyToMany';

COMMENT ON CONSTRAINT encrypted_table_fkey ON meta_public.user_auth_module IS E'@omit manyToMany';

COMMENT ON CONSTRAINT tokens_table_fkey ON meta_public.user_auth_module IS E'@omit manyToMany';

CREATE TABLE meta_public.uuid_module (
 	id uuid PRIMARY KEY DEFAULT ( uuid_generate_v4() ),
	database_id uuid NOT NULL,
	schema_id uuid NOT NULL,
	uuid_function text NOT NULL DEFAULT ( 'uuid_generate_v4' ),
	uuid_seed text NOT NULL,
	CONSTRAINT schema_fkey FOREIGN KEY ( schema_id ) REFERENCES collections_public.schema ( id ),
	CONSTRAINT db_fkey FOREIGN KEY ( database_id ) REFERENCES collections_public.database ( id ) 
);

COMMENT ON CONSTRAINT db_fkey ON meta_public.uuid_module IS E'@omit manyToMany';

COMMENT ON CONSTRAINT schema_fkey ON meta_public.uuid_module IS E'@omit manyToMany';

CREATE INDEX uuid_module_database_id_idx ON meta_public.uuid_module ( database_id );