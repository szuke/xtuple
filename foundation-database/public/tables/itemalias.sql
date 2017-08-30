SELECT xt.create_table('itemalias', 'public');

ALTER TABLE public.itemalias DISABLE TRIGGER ALL;

SELECT
  xt.add_column('itemalias', 'itemalias_id',          'SERIAL', 'NOT NULL', 'public'),
  xt.add_column('itemalias', 'itemalias_item_id',    'INTEGER', 'NOT NULL', 'public'),
  xt.add_column('itemalias', 'itemalias_number',        'TEXT', 'NOT NULL', 'public'),
  xt.add_column('itemalias', 'itemalias_comments',      'TEXT', NULL,       'public'),
  xt.add_column('itemalias', 'itemalias_usedescrip', 'BOOLEAN', 'NOT NULL', 'public'),
  xt.add_column('itemalias', 'itemalias_descrip1',      'TEXT', NULL,      'public'),
  xt.add_column('itemalias', 'itemalias_descrip2',      'TEXT', NULL,      'public'),
  xt.add_column('itemalias', 'itemalias_crmacct_id', 'INTEGER', NULL,      'public');

ALTER TABLE itemalias DROP CONSTRAINT IF EXISTS itemalias_itemalias_item_id_key;

SELECT
  xt.add_constraint('itemalias', 'itemalias_pkey', 'PRIMARY KEY (itemalias_id)', 'public'),
  xt.add_constraint('itemalias', 'itemalias_itemalias_item_id_key',
                    'UNIQUE (itemalias_item_id, itemalias_crmacct_id, itemalias_number)', 'public'),
  xt.add_constraint('itemalias', 'itemalias_itemalias_number_check',
                    $$CHECK (itemalias_number <> '')$$, 'public'),
  xt.add_constraint('itemalias', 'itemalias_itemalias_crmacct_id_fkey',
                    'FOREIGN KEY (itemalias_crmacct_id) REFERENCES crmacct(crmacct_id)', 'public'),
  xt.add_constraint('itemalias', 'itemalias_itemalias_item_id_fkey',
                    'FOREIGN KEY (itemalias_item_id) REFERENCES item(item_id)', 'public');

ALTER TABLE public.itemalias ENABLE TRIGGER ALL;

COMMENT ON TABLE itemalias IS 'Item Alias information';

COMMENT ON COLUMN itemalias.itemalias_crmacct_id IS 'Associated crmacct for item alias.';
