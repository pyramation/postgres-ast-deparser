-- Deploy schemas/ast_helpers/procedures/helpers to pg

-- requires: schemas/ast_helpers/schema
-- requires: schemas/ast/procedures/types 


BEGIN;


CREATE FUNCTION ast_helpers.coalesce (field text, value text default '')
    RETURNS jsonb
    AS $$
DECLARE
    result jsonb = ast.coalesce_expr(
      v_args := to_jsonb(ARRAY[ ast.string(''), ast.a_const(ast.string('')) ])
    );
BEGIN
	result = jsonb_set(result, '{CoalesceExpr, args, 0, String, str}', to_jsonb(field));
	result = jsonb_set(result, '{CoalesceExpr, args, 1, A_Const, String, str}', to_jsonb(value));
	RETURN result;
END;
$$
LANGUAGE 'plpgsql'
IMMUTABLE;

CREATE FUNCTION ast_helpers.coalesce (field jsonb, value text default '')
    RETURNS jsonb
    AS $$
DECLARE
    result jsonb = ast.coalesce_expr(
      v_args := to_jsonb(ARRAY[ ast.string(''), ast.a_const(ast.string('')) ])
    );
BEGIN
	result = jsonb_set(result, '{CoalesceExpr, args, 0}', field);
	result = jsonb_set(result, '{CoalesceExpr, args, 1, A_Const, String, str}', to_jsonb(value));
	RETURN result;
END;
$$
LANGUAGE 'plpgsql'
IMMUTABLE;

CREATE FUNCTION ast_helpers.tsvectorw (input jsonb, weight text='A')
    RETURNS jsonb
    AS $$
DECLARE
    result jsonb = ast.func_call(
      v_funcname := to_jsonb(ARRAY[ast.string('setweight')]),
      v_args := to_jsonb(ARRAY[input, ast.a_const(ast.string(weight))])
    );
BEGIN
	RETURN result;
END;
$$
LANGUAGE 'plpgsql'
IMMUTABLE;

CREATE FUNCTION ast_helpers.tsvector (input jsonb)
    RETURNS jsonb
    AS $$
DECLARE
    result jsonb = ast.func_call(
      v_funcname := to_jsonb(ARRAY[ast.string('to_tsvector')]),
      v_args := to_jsonb(ARRAY[input])
    );
BEGIN
	RETURN result;
END;
$$
LANGUAGE 'plpgsql'
IMMUTABLE;

CREATE FUNCTION ast_helpers.simple_param (
  name text,
  type text
)
    RETURNS jsonb
    AS $$
BEGIN
	RETURN ast.function_parameter(
      v_name := name,
      v_argType := ast.type_name( 
        v_names := to_jsonb(ARRAY[ast.string(type)])
      ),
      v_mode := 105
    );
END;
$$
LANGUAGE 'plpgsql'
IMMUTABLE;

CREATE FUNCTION ast_helpers.simple_param (
  name text,
  type text,
  default_value text
)
    RETURNS jsonb
    AS $$
BEGIN
	RETURN ast.function_parameter(
      v_name := name,
      v_argType := ast.type_name( 
        v_names := to_jsonb(ARRAY[ast.string(type)])
      ),
      v_mode := 105,
      v_defexpr := ast.string(default_value)
    );
END;
$$
LANGUAGE 'plpgsql'
IMMUTABLE;

CREATE FUNCTION ast_helpers.simple_param (
  name text,
  type text,
  default_value jsonb
)
    RETURNS jsonb
    AS $$
BEGIN
	RETURN ast.function_parameter(
      v_name := name,
      v_argType := ast.type_name( 
        v_names := to_jsonb(ARRAY[ast.string(type)])
      ),
      v_mode := 105,
      v_defexpr := default_value
    );
END;
$$
LANGUAGE 'plpgsql'
IMMUTABLE;

CREATE FUNCTION ast_helpers.tsvector (lang text, input jsonb)
    RETURNS jsonb
    AS $$
DECLARE
    result jsonb = ast.func_call(
      v_funcname := to_jsonb(ARRAY[ast.string('to_tsvector')]),
      v_args := to_jsonb(ARRAY[ast.a_const(ast.string(lang)), input])
    );
BEGIN
	RETURN result;
END;
$$
LANGUAGE 'plpgsql'
IMMUTABLE;

CREATE FUNCTION ast_helpers.a_expr_distinct_tg_field (field text)
    RETURNS jsonb
    AS $$
BEGIN
	RETURN ast.a_expr(v_kind := 3, 
        v_lexpr := ast.column_ref(
          to_jsonb(ARRAY[ ast.string('old'),ast.string(field) ])
        ),
        v_name := to_jsonb(ARRAY[ast.string('=')]),
        v_rexpr := ast.column_ref(
          to_jsonb(ARRAY[ ast.string('new'),ast.string(field) ])
        ) 
    );
END;
$$
LANGUAGE 'plpgsql'
IMMUTABLE;

CREATE FUNCTION ast_helpers.tsvector_index (fields jsonb)
    RETURNS jsonb
    AS $$
DECLARE
  results jsonb[];
  result jsonb;
  r jsonb;
	i int;
BEGIN
  FOR r IN (select jsonb_array_elements(fields))
    LOOP
      -- TODO maybe we get pg_catalog on some machines from get_current_ts_config and don't need to add it?
      IF ( (r->'lang') IS NULL) THEN
        r = jsonb_set(r, '{lang}', to_jsonb(get_current_ts_config()) );
        -- r = jsonb_set(r, '{lang}', to_jsonb('pg_catalog' || '.' || get_current_ts_config()) );
      END IF;

     -- TODO handle simple/english
      IF ( r->'array' = to_jsonb(true)) THEN
        -- handle array
        results = array_append(results, ast_helpers.tsvectorw( ast_helpers.tsvector(r->>'lang',
          -- start the string
          ast_helpers.coalesce(ast.func_call(
            v_funcname := to_jsonb(ARRAY[ast.string('array_to_string')]),
            v_args := to_jsonb(ARRAY[
              -- type cast null to text[] array
              ast.type_cast(
                v_arg := ast.string(r->>'field'),
                v_typeName := ast.type_name( 
                    v_names := to_jsonb(ARRAY[ast.string(r->>'type')]),
                    v_arrayBounds := to_jsonb(ARRAY[ast.integer(-1)])
                )
              ),
              ast.a_const(ast.string(' '))]
            )
          ))
        -- end array to string function call here
      ) , r->>'weight') );
      ELSE
        IF ( (r->'lang') IS NOT NULL) THEN
          results = array_append(results, ast_helpers.tsvectorw( ast_helpers.tsvector(r->>'lang', ast_helpers.coalesce(r->>'field')) , r->>'weight') );
        ELSE
          -- get_current_ts_config() returns 'english', we'd need to add pg_catalog on there...
          results = array_append(results, ast_helpers.tsvectorw( ast_helpers.tsvector(ast_helpers.coalesce(r->>'field')) , r->>'weight') );
        END IF;
      END IF;
    END LOOP;

  -- create the expressions
  FOR i IN SELECT * FROM generate_subscripts(results, 1) g(i)
    LOOP
      IF (i = 1) THEN
        result = results[i];
      ELSE
        result = ast.a_expr(
          v_kind := 0,
          v_lexpr := results[i], 
          v_name := to_jsonb(ARRAY[ast.string('||')]),
          v_rexpr := result );
      END IF;
    END LOOP;

	RETURN result;
END;
$$
LANGUAGE 'plpgsql'
IMMUTABLE;

CREATE FUNCTION ast_helpers.create_trigger_with_fields (
  trigger_name text,
  schema_name text,
  table_name text,
  trigger_fn_schema text,
  trigger_fn_name text,
  fields text[],
  timing int default 2,
  events int default 4 | 16
)
    RETURNS jsonb
    AS $$
DECLARE
  results jsonb[];
  result jsonb;
  whenClause jsonb;
  r jsonb;
	i int;
  field text;
BEGIN

  FOR i IN SELECT * FROM generate_subscripts(fields, 1) g(i)
    LOOP
      field = fields[i];
      IF (i = 1) THEN
        whenClause = ast_helpers.a_expr_distinct_tg_field(field);
      ELSE
        whenClause = ast.bool_expr( 
          v_boolop := 1, 
          v_args := to_jsonb(ARRAY[ast_helpers.a_expr_distinct_tg_field(field), whenClause])
        );
      END IF;
    END LOOP;

  result = ast.create_trig_stmt(
    v_trigname := trigger_name,
    v_relation := ast.range_var(schema_name, table_name, true, 'p'),
    v_funcname := to_jsonb(ARRAY[ ast.string(trigger_fn_schema),ast.string(trigger_fn_name) ]),
    v_row := true,
    v_timing := timing,
    v_events := events,
    v_whenClause := whenClause
  );


	RETURN result;
END;
$$
LANGUAGE 'plpgsql'
IMMUTABLE;


CREATE FUNCTION ast_helpers.create_function (
  schema text,
  name text,
  type text,
  parameters jsonb,
  body text,
  vol text,
  lan text,
  sec int
)
    RETURNS jsonb
    AS $$
DECLARE
  ast jsonb;
BEGIN

  select * FROM ast.create_function_stmt(
    v_funcname := to_jsonb(ARRAY[ ast.string(schema),ast.string(name) ]),
    v_parameters := parameters,
    v_returnType := ast.type_name( 
        v_names := to_jsonb(ARRAY[ast.string(type)])
    ),
    v_options := to_jsonb(ARRAY[
      ast.def_elem(
        'as',
        to_jsonb(ARRAY[ast.string(body)])
      ),
      ast.def_elem(
        'volatility',
        ast.string(vol)
      ),
      ast.def_elem(
        'language',
        ast.string(lan)
      ),
      ast.def_elem(
        'security',
        ast.integer(sec)
      )
    ]::jsonb[])
  ) INTO ast;

  RETURN ast;

END;
$$
LANGUAGE 'plpgsql'
IMMUTABLE;

CREATE FUNCTION ast_helpers.create_policy (
  v_policy_name text default null,
  v_schema_name text default null,
  v_table_name text default null,
  v_roles text[] default null,
  v_qual jsonb default null,
  v_cmd_name text default null,
  v_with_check jsonb default null,
  v_permissive boolean default null

)
RETURNS jsonb
    AS $$
DECLARE
  ast jsonb;
  roles jsonb[];
  i int;
BEGIN

  IF (v_permissive IS NULL) THEN 
    -- Policies default to permissive
    v_permissive = TRUE;
  END IF;

  -- if there are no roles then use PUBLIC
  IF (v_roles IS NULL OR cardinality(v_roles) = 0) THEN 
      roles = array_append(roles, ast.role_spec(
        v_roletype:=ast_constants.role_spec_type(
          'ROLESPEC_PUBLIC'
        )
      ));
  ELSE
    FOR i IN 
    SELECT * FROM generate_series(1, cardinality(v_roles))
    LOOP
      roles = array_append(roles, ast.role_spec(
        v_roletype:=ast_constants.role_spec_type(
          'ROLESPEC_CSTRING'
        ),
        v_rolename:=v_roles[i]
      ));
    END LOOP;
  END IF;

  select * FROM ast.create_policy_stmt(
    v_policy_name := v_policy_name,
    v_table := ast.range_var(
      v_schemaname := v_schema_name,
      v_relname := v_table_name,
      v_inh := true,
      v_relpersistence := 'p'
    ),
    v_roles := to_jsonb(roles),
    v_qual := v_qual,
    v_cmd_name := v_cmd_name,
    v_with_check := v_with_check,
    v_permissive := v_permissive
  ) INTO ast;

  RETURN ast.raw_stmt(
    v_stmt := ast,
    v_stmt_len := 1
  );
END;
$$
LANGUAGE 'plpgsql'
IMMUTABLE;

CREATE FUNCTION ast_helpers.drop_policy (
  v_policy_name text default null,
  v_schema_name text default null,
  v_table_name text default null
)
RETURNS jsonb
    AS $$
DECLARE
  ast jsonb;
BEGIN
  ast = ast.raw_stmt(
    v_stmt := ast.drop_stmt(
      v_objects := to_jsonb(ARRAY[ARRAY[
        ast.string(v_schema_name),
        ast.string(v_table_name),
        ast.string(v_policy_name)
      ]]),
      v_removeType := ast_constants.object_type('OBJECT_POLICY')
    ),
    v_stmt_len := 1
  );
  RETURN ast;
END;
$$
LANGUAGE 'plpgsql'
IMMUTABLE;

CREATE FUNCTION ast_helpers.create_table (
  v_schema_name text,
  v_table_name text
)
    RETURNS jsonb
    AS $$
  select ast.raw_stmt(
    v_stmt := ast.create_stmt(
      v_relation := ast.range_var(
        v_schemaname:= v_schema_name,
        v_relname:= v_table_name,
        v_inh := TRUE,
        v_relpersistence := 'p'
      ),
      v_oncommit := 0
    ),
    v_stmt_len := 1
  );
$$
LANGUAGE 'sql'
IMMUTABLE;

CREATE FUNCTION ast_helpers.drop_table (
  v_schema_name text,
  v_table_name text,
  v_cascade boolean default false
)
    RETURNS jsonb
    AS $$
  select ast.raw_stmt(
    v_stmt := ast.drop_stmt(
      v_objects := to_jsonb(ARRAY[ARRAY[
        ast.string(v_schema_name),
        ast.string(v_table_name)
      ]]),
      v_removeType := ast_constants.object_type('OBJECT_TABLE'),
      v_behavior:= (CASE when v_cascade IS TRUE then 1 else 0 END)
    ),
    v_stmt_len := 1
  );
$$
LANGUAGE 'sql'
IMMUTABLE;

CREATE FUNCTION ast_helpers.create_index (
  v_index_name text,
  v_schema_name text,
  v_table_name text,
  v_fields text[],
  v_accessMethod text default null
)
    RETURNS jsonb
    AS $$
DECLARE
  parameters jsonb[];

  item text;
  i int;

  ast jsonb;
BEGIN
  FOR i IN
    SELECT * FROM generate_series(1, cardinality(v_fields)) g (i)
  LOOP
    parameters = array_append(parameters, ast.index_elem(
      v_name := v_fields[i],
      v_ordering := 0,
      v_nulls_ordering := 0
    ));
  END LOOP;

  SELECT ast.raw_stmt(
    v_stmt := ast.index_stmt(
      v_idxname := v_index_name,
      v_relation := ast.range_var(
        v_schemaname := v_schema_name,
        v_relname := v_table_name,
        v_inh := true,
        v_relpersistence := 'p'::text
      ),
      v_accessMethod := v_accessMethod,
      v_indexParams := to_jsonb(parameters)
    ),
    v_stmt_len:= 1
  ) INTO ast;

  RETURN ast;
END;
$$
LANGUAGE 'plpgsql'
IMMUTABLE;

CREATE FUNCTION ast_helpers.drop_index (
  v_schema_name text,
  v_index_name text
)
    RETURNS jsonb
AS $$
  select ast.raw_stmt(
    v_stmt := ast.drop_stmt(
      v_objects:= to_jsonb(ARRAY[
        to_jsonb(ARRAY[
          ast.string(v_schema_name),
          ast.string(v_index_name)
        ])
      ]),
      v_removeType:= ast_constants.object_type('OBJECT_INDEX'),
      v_behavior:= 0
    ),
    v_stmt_len := 1
  );
$$
LANGUAGE 'sql'
IMMUTABLE;

CREATE FUNCTION ast_helpers.table_grant (
  v_schema_name text,
  v_table_name text,
  v_priv_name text,
  v_is_grant boolean,
  v_role_name text,
  v_cols text[] default null
)
    RETURNS jsonb
    AS $$
DECLARE
  ast jsonb;
  cols jsonb[];
  i int;
BEGIN
  FOR i IN 
  SELECT * FROM generate_series(1, cardinality(v_cols))
  LOOP 
    cols = array_append(cols, ast.string(v_cols[i]));
  END LOOP;

  SELECT ast.raw_stmt(
    v_stmt := ast.grant_stmt(
      v_is_grant := v_is_grant,
      v_targtype := 0, -- why?
      v_objtype := 1, --why?
      v_objects := to_jsonb(ARRAY[
        ast.range_var(
          v_schemaname := v_schema_name,
          v_relname := v_table_name,
          v_inh := true,
          v_relpersistence := 'p'
        )
      ]),
      v_privileges := to_jsonb(ARRAY[
        ast.access_priv(
          v_priv_name := v_priv_name,
          v_cols := to_jsonb(cols)
        )
      ]),
      v_grantees := to_jsonb(ARRAY[
        ast.role_spec(
          v_roletype:=ast_constants.role_spec_type(
          'ROLESPEC_CSTRING'
          ),
          v_rolename:= v_role_name
        )
      ])
    ),
    v_stmt_len:= 1
  ) INTO ast;

  RETURN ast;
END;
$$
LANGUAGE 'plpgsql'
IMMUTABLE;



COMMIT;
