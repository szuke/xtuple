SELECT xt.create_table('itemsrc', 'public');

ALTER TABLE public.itemsrc DISABLE TRIGGER ALL;

SELECT
  xt.add_column('itemsrc', 'itemsrc_id',                        'SERIAL', 'NOT NULL',                       'public'),
  xt.add_column('itemsrc', 'itemsrc_item_id',                  'INTEGER', 'NOT NULL',                       'public'),
  xt.add_column('itemsrc', 'itemsrc_vend_id',                  'INTEGER', 'NOT NULL',                       'public'),
  xt.add_column('itemsrc', 'itemsrc_vend_item_number',            'TEXT', NULL,                             'public'),
  xt.add_column('itemsrc', 'itemsrc_vend_item_descrip',           'TEXT', NULL,                             'public'),
  xt.add_column('itemsrc', 'itemsrc_comments',                    'TEXT', NULL,                             'public'),
  xt.add_column('itemsrc', 'itemsrc_vend_uom',                    'TEXT', 'NOT NULL',                       'public'),
  xt.add_column('itemsrc', 'itemsrc_invvendoruomratio', 'NUMERIC(20,10)', 'NOT NULL',                       'public'),
  xt.add_column('itemsrc', 'itemsrc_minordqty',          'NUMERIC(18,6)', 'NOT NULL',                       'public'),
  xt.add_column('itemsrc', 'itemsrc_multordqty',         'NUMERIC(18,6)', 'NOT NULL',                       'public'),
  xt.add_column('itemsrc', 'itemsrc_leadtime',                 'INTEGER', 'NOT NULL',                       'public'),
  xt.add_column('itemsrc', 'itemsrc_ranking',                  'INTEGER', 'NOT NULL',                       'public'),
  xt.add_column('itemsrc', 'itemsrc_active',                   'BOOLEAN', 'NOT NULL',                       'public'),
  xt.add_column('itemsrc', 'itemsrc_manuf_name',                  'TEXT', $$NOT NULL DEFAULT ''::TEXT$$,    'public'),
  xt.add_column('itemsrc', 'itemsrc_manuf_item_number',           'TEXT', $$NOT NULL DEFAULT ''::TEXT$$,    'public'),
  xt.add_column('itemsrc', 'itemsrc_manuf_item_descrip',          'TEXT', NULL,                             'public'),
  xt.add_column('itemsrc', 'itemsrc_default',                  'BOOLEAN', 'NOT NULL',                       'public'),
  xt.add_column('itemsrc', 'itemsrc_upccode',                     'TEXT', NULL,                             'public'),
  xt.add_column('itemsrc', 'itemsrc_effective',                   'DATE', 'NOT NULL DEFAULT startoftime()', 'public'),
  xt.add_column('itemsrc', 'itemsrc_expires',                     'DATE', 'NOT NULL DEFAULT endoftime()',   'public'),
  xt.add_column('itemsrc', 'itemsrc_contrct_id',               'INTEGER', NULL,                             'public'),
  xt.add_column('itemsrc', 'itemsrc_contrct_max',        'NUMERIC(18,6)', 'NOT NULL DEFAULT 0.0',           'public'),
  xt.add_column('itemsrc', 'itemsrc_contrct_min',        'NUMERIC(18,6)', 'NOT NULL DEFAULT 0.0',           'public');

ALTER TABLE public.itemsrc DROP CONSTRAINT IF EXISTS itemsrc_itemsrc_vend_id_key;

SELECT
  xt.add_constraint('itemsrc', 'itemsrc_pkey', 'PRIMARY KEY (itemsrc_id)',   'public'),
  xt.add_constraint('itemsrc', 'itemsrc_itemsrc_item_id_fkey',
                    'FOREIGN KEY (itemsrc_item_id) REFERENCES item(item_id) ON DELETE CASCADE',    'public'),
  xt.add_constraint('itemsrc', 'itemsrc_itemsrc_vend_id_fkey',
                    'FOREIGN KEY (itemsrc_vend_id) REFERENCES vendinfo(vend_id) ON DELETE CASCADE',    'public'),
  xt.add_constraint('itemsrc', 'itemsrc_itemsrc_contrct_id_fkey',
                    'FOREIGN KEY (itemsrc_contrct_id) REFERENCES contrct(contrct_id)',    'public'),
  xt.add_constraint('itemsrc', 'itemsrc_vend_item_unq',
                    'UNIQUE (itemsrc_vend_id, itemsrc_item_id, itemsrc_vend_item_number, itemsrc_effective, itemsrc_expires, itemsrc_contrct_id)',    'public');

ALTER TABLE public.itemsrc ENABLE TRIGGER ALL;

COMMENT ON TABLE public.itemsrc IS 'Item Source information';
COMMENT ON COLUMN public.itemsrc.itemsrc_effective IS 'Effective date for item source.';
COMMENT ON COLUMN public.itemsrc.itemsrc_expires IS 'Expiration date for item source.';
COMMENT ON COLUMN public.itemsrc.itemsrc_contrct_id IS 'Associated contract for item source.  Inherits effective, expiration dates.';
