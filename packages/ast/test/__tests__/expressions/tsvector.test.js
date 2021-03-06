import { getConnections } from '../../utils';

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

it('pure psql', async () => {
  const [{ deparse: result }] = await db.any(`
select deparser.deparse(
  ast.a_expr(
  v_kind := 'AEXPR_OP',
  v_lexpr := ast_helpers.tsvectorw( ast_helpers.tsvector(ast_helpers.coalesce('NEW.field1')) , 'A'),
  v_name := to_jsonb(ARRAY[ast.string('||')]),
  v_rexpr := ast_helpers.tsvectorw( ast_helpers.tsvector(ast_helpers.coalesce('NEW.field2')) , 'A')
  )
);`);
  expect(result).toMatchSnapshot();
});

it('tsvector', async () => {
  const [result] = await db.any(`
select deparser.deparse( ast_helpers.tsvector(ast_helpers.coalesce('NEW.field1') ));
  `);
  expect(result).toMatchSnapshot();
});

it('tsvector with lang', async () => {
  const [result] = await db.any(`
select deparser.deparse( ast_helpers.tsvector('pg_catalog.english', ast_helpers.coalesce('NEW.field1') ));
  `);
  expect(result).toMatchSnapshot();
});

it('tsvector index', async () => {
  const fields = [
    {
      lang: 'pg_catalog.english',
      field: 'name',
      weight: 'A'
    },
    {
      field: 'description',
      weight: 'B'
    },
    {
      lang: 'pg_catalog.simple',
      field: 'name',
      weight: 'A'
    }
  ];
  const [result] = await db.any(`
  select deparser.deparse( ast_helpers.tsvector_index('${JSON.stringify(
    fields
  )}'::jsonb) );
  `);
  expect(result).toMatchSnapshot();
});

it('trigger tsvector index', async () => {
  const fields = [
    {
      lang: 'pg_catalog.english',
      field: 'name',
      weight: 'A'
    },
    {
      field: 'description',
      weight: 'B'
    },
    {
      lang: 'pg_catalog.simple',
      field: 'name',
      weight: 'A'
    },
    {
      lang: 'pg_catalog.simple',
      field: 'tags',
      weight: 'A',
      type: 'citext',
      array: true
    }
  ];
  const [result] = await db.any(`
  select deparser.deparse( ast_helpers.tsvector_index('${JSON.stringify(
    fields
  )}'::jsonb) );
  `);
  expect(result).toMatchSnapshot();
});
