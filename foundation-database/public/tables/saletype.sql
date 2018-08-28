SELECT xt.create_table('saletype', 'public');

ALTER TABLE public.saletype DISABLE TRIGGER ALL;

SELECT
  xt.add_column('saletype', 'saletype_id',       'SERIAL', 'NOT NULL', 'public'),
  xt.add_column('saletype', 'saletype_code',       'TEXT', 'NOT NULL', 'public'),
  xt.add_column('saletype', 'saletype_descr',      'TEXT', NULL,       'public'),
  xt.add_column('saletype', 'saletype_active',  'BOOLEAN', 'DEFAULT true NOT NULL', 'public'),
  xt.add_column('saletype', 'saletype_default', 'BOOLEAN', 'NOT NULL DEFAULT FALSE', 'public');

SELECT
  xt.add_constraint('saletype', 'saletype_pkey', 'PRIMARY KEY (saletype_id)', 'public');

ALTER TABLE public.saletype ENABLE TRIGGER ALL;

COMMENT ON TABLE saletype IS 'Type or Origination of Sale.';

COMMENT ON COLUMN saletype.saletype_id     IS 'Sequence identifier for sale type.';
COMMENT ON COLUMN saletype.saletype_code   IS 'User defined identifier for sale type.';
COMMENT ON COLUMN saletype.saletype_descr  IS 'Description for sale type.';
COMMENT ON COLUMN saletype.saletype_active IS 'Boolean to deactivate a sale type.';
