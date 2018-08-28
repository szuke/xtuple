SELECT xt.create_table('itemlocdist', 'public');

ALTER TABLE public.itemlocdist DISABLE TRIGGER ALL;

SELECT xt.add_column('itemlocdist', 'itemlocdist_id',             'SERIAL',        'PRIMARY KEY', 'public'),
       xt.add_column('itemlocdist', 'itemlocdist_itemlocdist_id', 'INTEGER',       NULL, 'public'),
       xt.add_column('itemlocdist', 'itemlocdist_source_type',    'CHARACTER(1)',  NULL, 'public'),
       xt.add_column('itemlocdist', 'itemlocdist_source_id',      'INTEGER',       NULL, 'public'),
       xt.add_column('itemlocdist', 'itemlocdist_qty',            'NUMERIC(18,6)', NULL, 'public'),
       xt.add_column('itemlocdist', 'itemlocdist_series',         'INTEGER',       NULL, 'public'),
       xt.add_column('itemlocdist', 'itemlocdist_invhist_id',     'INTEGER',       NULL, 'public'),
       xt.add_column('itemlocdist', 'itemlocdist_itemsite_id',    'INTEGER',       NULL, 'public'),
       xt.add_column('itemlocdist', 'itemlocdist_reqlotserial',   'BOOLEAN',       'DEFAULT false', 'public'),
       xt.add_column('itemlocdist', 'itemlocdist_flush',          'BOOLEAN',       'DEFAULT false', 'public'),
       xt.add_column('itemlocdist', 'itemlocdist_expiration',     'DATE',          NULL, 'public'),
       xt.add_column('itemlocdist', 'itemlocdist_distlotserial',  'BOOLEAN',       NULL, 'public'),
       xt.add_column('itemlocdist', 'itemlocdist_warranty',       'DATE',          NULL, 'public'),
       xt.add_column('itemlocdist', 'itemlocdist_ls_id',          'INTEGER',       NULL, 'public'),
       xt.add_column('itemlocdist', 'itemlocdist_order_type',     'TEXT',          NULL, 'public'),
       xt.add_column('itemlocdist', 'itemlocdist_order_id',       'INTEGER',       NULL, 'public'),
       xt.add_column('itemlocdist', 'itemlocdist_child_series',   'INTEGER',       NULL, 'public'),
       xt.add_column('itemlocdist', 'itemlocdist_transtype',      'TEXT',          NULL, 'public');

SELECT
  xt.add_constraint('itemlocdist', 'itemlocdist_pkey', 'PRIMARY KEY (itemlocdist_id)', 'public'),
  xt.add_constraint('itemlocdist', 'itemlocdist_itemlocdist_id_fkey',
                    'FOREIGN KEY (itemlocdist_itemlocdist_id) REFERENCES itemlocdist(itemlocdist_id)', 'public');

ALTER TABLE public.itemlocdist ENABLE TRIGGER ALL;

COMMENT ON TABLE itemlocdist IS 'Temporary table for storing information about Inventory distributions involving Lot/Serial and Multiple Location Control (MLC) Items';

COMMENT ON COLUMN public.itemlocdist.itemlocdist_order_id
  IS 'This is actually orderitem_id';
