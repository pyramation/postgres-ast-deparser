import { getConnections } from '../../utils';
import {
  policies,
  current_groups_ast,
  current_groups_ast2,
  current_user_ast
} from './__fixtures__/policies';
import policyStmt from './__fixtures__/policy';

let db, teardown;
const objs = {
  tables: {}
};

beforeAll(async () => {
  ({ db, teardown } = await getConnections());
  await db.begin();
  await db.savepoint();
});
afterAll(async () => {
  try {
    //try catch here allows us to see the sql parsing issues!
    await db.rollback();
    await db.commit();
    await teardown();
  } catch (e) {}
});

it('deparse', async () => {
  const [{ deparse: result }] = await db.any(`
  select deparser.deparse( '${JSON.stringify(policies[0])}'::jsonb );
  `);
  expect(result).toMatchSnapshot();
});

it('policy deparse', async () => {
  const result = await db.any(`
SELECT deparser.deparse(ast_helpers.create_policy(
  v_policy_name := 'mypolicy',
  v_schema_name := 'schemanamed',
  v_table_name := 'mytable',
  v_roles := '{authenticated}'::text[],
  v_qual := ast.bool_expr('OR_EXPR', to_jsonb(ARRAY[
    ast.a_expr(v_kind := 'AEXPR_OP',
      v_lexpr := ast.column_ref(
        v_fields := to_jsonb(ARRAY[ ast.string('responder_id') ])
      ),
      v_name := to_jsonb(ARRAY[ast.string('=')]),
      v_rexpr := ast.func_call(
        v_funcname := to_jsonb(ARRAY[ ast.string('dbe'), ast.string('get_uid') ]),
        v_args := to_jsonb(ARRAY[ ast.string('c'), ast.string('b') ])
      )  
    ),
    ast.a_expr(v_kind := 'AEXPR_OP',
      v_lexpr := ast.column_ref(
        v_fields := to_jsonb(ARRAY[ ast.string('requester_id') ])
      ),
      v_name := to_jsonb(ARRAY[ast.string('=')]),
      v_rexpr := ast.func_call(
        v_funcname := to_jsonb(ARRAY[ ast.string('dbe'), ast.string('get_other_uid') ]),
        v_args := to_jsonb(ARRAY[ ast.string('c'), ast.string('b') ])
      )  
    )
  ])),
  v_cmd_name := 'INSERT',
  v_with_check := NULL,
  v_permissive := true
))`);
  expect(result).toMatchSnapshot();
});

const getInsertPolicyResult = async (name, vars) => {
  const [{ deparse }] = await db.any(
    `
SELECT deparser.deparse(
  ast_helpers.create_policy(
    v_policy_name := 'v_policy_name',
    v_schema_name := 'v_schema_name',
    v_table_name := 'v_table_name',
    v_roles := ARRAY['authenticated'],
    v_cmd_name := 'INSERT',
    v_permissive := TRUE,
    v_with_check := ast_helpers.create_policy_template(
        $1::text,
        $2::jsonb
    )
  )
)`,
    [name, JSON.stringify(vars)]
  );
  return deparse;
};

const getUpdatePolicyResult = async (name, vars) => {
  const [{ deparse }] = await db.any(
    `
SELECT deparser.deparse(
  ast_helpers.create_policy(
    v_policy_name := 'v_policy_name',
    v_schema_name := 'v_schema_name',
    v_table_name := 'v_table_name',
    v_roles := ARRAY['authenticated'],
    v_cmd_name := 'UPDATE',
    v_permissive := TRUE,
    v_qual := ast_helpers.create_policy_template(
        $1::text,
        $2::jsonb
    )
  )
)`,
    [name, JSON.stringify(vars)]
  );
  return deparse;
};

const getPolicyResult = async (name, vars) => {
  const [{ deparse }] = await db.any(
    `
SELECT deparser.deparse(
  ast_helpers.create_policy_template(
  $1::text,
  $2::jsonb
  ))`,
    [name, JSON.stringify(vars)]
  );

  return {
    insert: await getInsertPolicyResult(name, vars),
    update: await getUpdatePolicyResult(name, vars),
    policy: deparse
  };
};

it('own_records', async () => {
  const result = await getPolicyResult('own_records', {
    entity_field: 'entity_field',
    rls_role_schema: 'rls_schema',
    rls_role: 'role_fn'
  });
  expect(result).toMatchSnapshot();
});

it('own_records defaults', async () => {
  const result = await getPolicyResult('own_records', {
    entity_field: 'entity_field'
  });
  expect(result).toMatchSnapshot();
});

it('multi_owners', async () => {
  const result = await getPolicyResult('multi_owners', {
    entity_fields: ['requester_id', 'responder_id', 'verifier_id'],
    rls_role_schema: 'rls_schema',
    rls_role: 'role_fn'
  });
  expect(result).toMatchSnapshot();
});

it('open', async () => {
  const result = await getPolicyResult('open', {});
  expect(result).toMatchSnapshot();
});

it('policyStmt', async () => {
  const result = await db.any(
    `
SELECT deparser.deparse(
    $1::jsonb
  )`,
    [JSON.stringify(policyStmt)]
  );
  expect(result).toMatchSnapshot();
});

it('drop_policy', async () => {
  const result = await db.any(
    `
SELECT deparser.deparse(
  ast_helpers.drop_policy(
    v_policy_name := 'v_policy_name',
    v_schema_name := 'v_schema_name',
    v_table_name := 'v_table_name'
  )
  )`
  );
  expect(result).toMatchSnapshot();
});
