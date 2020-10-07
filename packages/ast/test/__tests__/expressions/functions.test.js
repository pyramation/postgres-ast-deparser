import { getConnections } from '../../utils';
import { functions } from './__fixtures__/functions';

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

it('createfunction stmt from json', async () => {
  const json = functions[0];
  const [{ deparse: result }] = await db.any(`
select deparser.deparse( '${JSON.stringify(json)}'::jsonb );
  `);
  expect(result).toMatchSnapshot();
});

it('create_function_stmt', async () => {
  const [{ deparse: result }] = await db.any(`
select deparser.deparse( ast.create_function_stmt(
  v_funcname := to_jsonb(ARRAY[ ast.string('schemer'),ast.string('funker') ]),
  v_parameters := to_jsonb(ARRAY[
    ast.function_parameter(
      v_name := 'param0',
      v_argType := ast.type_name( 
        v_names := to_jsonb(ARRAY[ast.string('text')])
      ),
      v_mode := 105
    ),
    ast.function_parameter(
      v_name := 'param1',
      v_argType := ast.type_name( 
        v_names := to_jsonb(ARRAY[ast.string('text')])
      ),
      v_mode := 105
    ),
    ast.function_parameter(
      v_name := 'param2',
      v_argType := ast.type_name( 
        v_names := to_jsonb(ARRAY[ast.string('text')]),
        v_arrayBounds := to_jsonb(ARRAY[ast.integer(-1)])
      ),
      v_mode := 105,
      v_defexpr := ast.a_const(ast.null())
    ),
    ast.function_parameter(
      v_name := 'param3',
      v_argType := ast.type_name( 
        v_names := to_jsonb(ARRAY[ast.string('text')]),
        v_arrayBounds := to_jsonb(ARRAY[ast.integer(-1)])
      ),
      v_mode := 105,
      v_defexpr := ast.a_const(ast.null())
    )
  ]::jsonb[]),
  
  v_returnType := ast.type_name( 
    v_names := to_jsonb(ARRAY[ast.string('text')])
  ),

  v_options := to_jsonb(ARRAY[
    ast.def_elem(
      'volatility',
      ast.string('volatile')
    ),
    ast.def_elem(
      'language',
      ast.string('plpgsql')
    ),
    ast.def_elem(
      'security',
      ast.integer(1)
    )
  ]::jsonb[])
))`);
  expect(result).toMatchSnapshot();
});

it('create_function_stmt ast', async () => {
  const [{ create_function_stmt: result }] = await db.any(`
select ast.create_function_stmt(
  v_funcname := to_jsonb(ARRAY[ ast.string('schemer'),ast.string('funker') ]),
  v_parameters := to_jsonb(ARRAY[
    ast.function_parameter(
      v_name := 'param1',
      v_argType := ast.type_name( 
        v_names := to_jsonb(ARRAY[ast.string('text')])
      ),
      v_mode := 105
    ),
    ast.function_parameter(
      v_name := 'param2',
      v_argType := ast.type_name( 
        v_names := to_jsonb(ARRAY[ast.string('text')]),
        v_arrayBounds := to_jsonb(ARRAY[ast.integer(-1)])
      ),
      v_mode := 105
      --ast.a_const(ast.null())
    )
  ]::jsonb[]),

  v_returnType := ast.type_name( 
    v_names := to_jsonb(ARRAY[ast.string('text')])
  ),

  v_options := to_jsonb(ARRAY[
    ast.def_elem(
      'volatility',
      ast.string('volatile')
    ),
    ast.def_elem(
      'language',
      ast.string('plpgsql')
    ),
    ast.def_elem(
      'security',
      ast.integer(1)
    )
  ]::jsonb[])
)`);
  expect(result).toMatchSnapshot();
});

it('create_function', async () => {
  const [{ create_function: result }] = await db.any(`
SELECT ast_helpers.create_function(
  'schema',
  'name',
  'text',
  to_jsonb(ARRAY[
    ast.function_parameter(
      v_name := 'param1',
      v_argType := ast.type_name( 
        v_names := to_jsonb(ARRAY[ast.string('text')])
      ),
      v_mode := 105
    ),
    ast.function_parameter(
      v_name := 'param2',
      v_argType := ast.type_name( 
        v_names := to_jsonb(ARRAY[ast.string('text')]),
        v_arrayBounds := to_jsonb(ARRAY[ast.integer(-1)])
      ),
      v_mode := 105
      --ast.a_const(ast.null())
    )
  ]::jsonb[]),
  'code here',
  'volatile',
  'plpgsql',
  1
)`);
  expect(result).toMatchSnapshot();
});

it('create_function deparse', async () => {
  const [{ deparse: result }] = await db.any(`
SELECT deparser.deparse(ast_helpers.create_function(
  'schema',
  'name',
  'text',
  to_jsonb(ARRAY[
    ast_helpers.simple_param(
      'param1',
      'text'
    ),
    ast_helpers.simple_param(
      'active',
      'bool'
    ),
    ast_helpers.simple_param(
      'sid',
      'uuid',
      'uuid_generate_v4()'
    ),
    ast_helpers.simple_param(
      'description',
      'text',
      'NULL'
    ),
    ast_helpers.simple_param(
      'tags',
      'text[]',
      ast.a_const(ast.null())
    )
  ]::jsonb[]),
  'code here',
  'volatile',
  'plpgsql',
  1
))`);
  expect(result).toMatchSnapshot();
});
