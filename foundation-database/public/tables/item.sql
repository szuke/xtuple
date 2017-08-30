SELECT xt.create_table('item', 'public');

ALTER TABLE public.item DISABLE TRIGGER ALL;

SELECT
  xt.add_column('item', 'item_id',               'SERIAL', 'NOT NULL',                'public'),
  xt.add_column('item', 'item_number',             'TEXT', 'NOT NULL',                'public'),
  xt.add_column('item', 'item_descrip1',           'TEXT', 'NOT NULL',                'public'),
  xt.add_column('item', 'item_descrip2',           'TEXT', 'NOT NULL',                'public'),
  xt.add_column('item', 'item_classcode_id',    'INTEGER', 'NOT NULL',                'public'),
  xt.add_column('item', 'item_picklist',        'BOOLEAN', 'DEFAULT true NOT NULL',   'public'),
  xt.add_column('item', 'item_comments',           'TEXT', NULL,                      'public'),
  xt.add_column('item', 'item_sold',            'BOOLEAN', 'NOT NULL',                'public'),
  xt.add_column('item', 'item_fractional',      'BOOLEAN', 'NOT NULL',                'public'),
  xt.add_column('item', 'item_active',          'BOOLEAN', 'NOT NULL',                'public'),
  xt.add_column('item', 'item_type',       'CHARACTER(1)', $$DEFAULT 'R' NOT NULL$$,  'public'),
  xt.add_column('item', 'item_prodweight', 'NUMERIC(16,2)', 'DEFAULT 0 NOT NULL',     'public'),
  xt.add_column('item', 'item_packweight', 'NUMERIC(16,2)', 'DEFAULT 0 NOT NULL',     'public'),
  xt.add_column('item', 'item_prodcat_id',      'INTEGER', 'NOT NULL',                'public'),
  xt.add_column('item', 'item_exclusive',       'BOOLEAN', 'DEFAULT false NOT NULL',  'public'),
  xt.add_column('item', 'item_listprice', 'NUMERIC(16,4)', 'NOT NULL',                'public'),
  xt.add_column('item', 'item_config',          'BOOLEAN', ' DEFAULT false',          'public'),
  xt.add_column('item', 'item_extdescrip',         'TEXT', NULL,                      'public'),
  xt.add_column('item', 'item_upccode',            'TEXT', NULL,                      'public'),
  xt.add_column('item', 'item_maxcost',   'NUMERIC(16,6)', 'DEFAULT 0 NOT NULL',      'public'),
  xt.add_column('item', 'item_inv_uom_id',      'INTEGER', 'NOT NULL',                'public'),
  xt.add_column('item', 'item_price_uom_id',    'INTEGER', 'NOT NULL',                'public'),
  xt.add_column('item', 'item_warrdays',        'INTEGER', 'DEFAULT 0',               'public'),
  xt.add_column('item', 'item_freightclass_id', 'INTEGER', NULL,                      'public'),
  xt.add_column('item', 'item_tax_recoverable', 'BOOLEAN', 'DEFAULT false NOT NULL',  'public'),
  xt.add_column('item', 'item_listcost',  'NUMERIC(16,6)', 'DEFAULT 0.0 NOT NULL',    'public'),
  xt.add_column('item', 'item_created',      'TIMESTAMP WITH TIME ZONE', NULL,        'public'),
  xt.add_column('item', 'item_lastupdated',  'TIMESTAMP WITH TIME ZONE', NULL,        'public');

SELECT
  xt.add_constraint('item', 'item_pkey', 'PRIMARY KEY (item_id)', 'public'),
  xt.add_constraint('item', 'item_item_number_key',
                    'UNIQUE (item_number)', 'public'),
  xt.add_constraint('item', 'item_item_number_check',
                    $$CHECK (item_number <> '')$$, 'public'),
  xt.add_constraint('item', 'item_item_type_check',
                    $$CHECK (item_type IN ('P', 'M', 'F', 'O', 'R', 'S',
                                           'T', 'B', 'L', 'Y', 'C', 'K'))$$, 'public'),
  xt.add_constraint('item', 'item_sold_check',
                    'CHECK (NOT (item_sold AND item_prodcat_id = -1))', 'public'),

  xt.add_constraint('item', 'item_item_classcode_id_fkey',
                    'FOREIGN KEY (item_classcode_id) REFERENCES classcode(classcode_id)', 'public'),
  xt.add_constraint('item', 'item_item_freightclass_id_fkey',
                    'FOREIGN KEY (item_freightclass_id) REFERENCES freightclass(freightclass_id)', 'public'),
  xt.add_constraint('item', 'item_item_inv_uom_id_fkey',
                    'FOREIGN KEY (item_inv_uom_id) REFERENCES uom(uom_id)', 'public'),
  xt.add_constraint('item', 'item_item_price_uom_id_fkey',
                    'FOREIGN KEY (item_price_uom_id) REFERENCES uom(uom_id)', 'public');

-- Clean up UPC code prior to making UNIQUE
UPDATE item SET item_upccode = NULL WHERE item_upccode = '';

ALTER TABLE public.item ENABLE TRIGGER ALL;

COMMENT ON TABLE item IS 'Item information';

COMMENT ON COLUMN item.item_maxcost IS 'Maximum cost for item.  Used to constrain purchase order price.';
COMMENT ON COLUMN item.item_listcost IS 'List cost for item.  Basis for markup pricing.';
