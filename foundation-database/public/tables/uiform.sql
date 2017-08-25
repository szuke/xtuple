SELECT xt.create_table('uiform', 'public');

ALTER TABLE public.uiform DISABLE TRIGGER ALL;

SELECT
  xt.add_column('uiform', 'uiform_id',       'SERIAL', 'NOT NULL',               'public'),
  xt.add_column('uiform', 'uiform_name',       'TEXT', 'NOT NULL',               'public'),
  xt.add_column('uiform', 'uiform_order',   'INTEGER', 'NOT NULL',               'public'),
  xt.add_column('uiform', 'uiform_enabled', 'BOOLEAN', 'DEFAULT false NOT NULL', 'public'),
  xt.add_column('uiform', 'uiform_source',     'TEXT', 'NOT NULL',               'public'),
  xt.add_column('uiform', 'uiform_notes',      'TEXT', NULL,                     'public');

SELECT
  xt.add_constraint('uiform', 'uiform_pkey', 'PRIMARY KEY (uiform_id)', 'public'),
  xt.add_constraint('uiform', 'uiform_uiform_name_order_key',
                    'UNIQUE (uiform_name, uiform_order)', 'public');

ALTER TABLE public.uiform ENABLE TRIGGER ALL;
