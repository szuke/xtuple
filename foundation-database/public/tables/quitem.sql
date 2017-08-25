SELECT xt.create_table('quitem', 'public');

ALTER TABLE public.quitem DISABLE TRIGGER ALL;

SELECT
  xt.add_column('quitem', 'quitem_id',                       'SERIAL', 'NOT NULL',       'public'),
  xt.add_column('quitem', 'quitem_quhead_id',                'INTEGER', NULL,            'public'),
  xt.add_column('quitem', 'quitem_linenumber',               'INTEGER', NULL,            'public'),
  xt.add_column('quitem', 'quitem_subnumber',                'INTEGER', 'NOT NULL DEFAULT 0', 'public'),
  xt.add_column('quitem', 'quitem_itemsite_id',              'INTEGER', NULL,            'public'),
  xt.add_column('quitem', 'quitem_scheddate',                   'DATE', NULL,            'public'),
  xt.add_column('quitem', 'quitem_qtyord',             'NUMERIC(18,6)', NULL,            'public'),
  xt.add_column('quitem', 'quitem_unitcost',           'NUMERIC(16,6)', NULL,            'public'),
  xt.add_column('quitem', 'quitem_price',              'NUMERIC(16,4)', NULL,            'public'),
  xt.add_column('quitem', 'quitem_custprice',          'NUMERIC(16,4)', NULL,            'public'),
  xt.add_column('quitem', 'quitem_memo',                        'TEXT', NULL,            'public'),
  xt.add_column('quitem', 'quitem_custpn',                      'TEXT', NULL,            'public'),
  xt.add_column('quitem', 'quitem_createorder',              'BOOLEAN', NULL,            'public'),
  xt.add_column('quitem', 'quitem_order_warehous_id',        'INTEGER', NULL,            'public'),
  xt.add_column('quitem', 'quitem_item_id',                  'INTEGER', NULL,            'public'),
  xt.add_column('quitem', 'quitem_prcost',             'NUMERIC(16,6)', NULL,            'public'),
  xt.add_column('quitem', 'quitem_imported',                 'BOOLEAN', 'DEFAULT false', 'public'),
  xt.add_column('quitem', 'quitem_qty_uom_id',               'INTEGER', 'NOT NULL',      'public'),
  xt.add_column('quitem', 'quitem_qty_invuomratio',   'NUMERIC(20,10)', 'NOT NULL',      'public'),
  xt.add_column('quitem', 'quitem_price_uom_id',             'INTEGER', 'NOT NULL',      'public'),
  xt.add_column('quitem', 'quitem_price_invuomratio', 'NUMERIC(20,10)', 'NOT NULL',      'public'),
  xt.add_column('quitem', 'quitem_promdate',                    'DATE', NULL,            'public'),
  xt.add_column('quitem', 'quitem_taxtype_id',               'INTEGER', NULL,            'public'),
  xt.add_column('quitem', 'quitem_dropship',                 'BOOLEAN', 'DEFAULT false', 'public'),
  xt.add_column('quitem', 'quitem_itemsrc_id',               'INTEGER', NULL,            'public'),
  xt.add_column('quitem', 'quitem_pricemode',           'CHARACTER(1)', $$DEFAULT 'D' NOT NULL$$, 'public'),
  xt.add_column('quitem', 'quitem_listprice',          'NUMERIC(16,4)', NULL,     'public'),
  xt.add_column('quitem', 'quitem_created',     'TIMESTAMP WITH TIME ZONE', NULL, 'public'),
  xt.add_column('quitem', 'quitem_lastupdated', 'TIMESTAMP WITH TIME ZONE', NULL, 'public');

SELECT
  xt.add_constraint('quitem', 'quitem_pkey', 'PRIMARY KEY (quitem_id)', 'public'),
  xt.add_constraint('quitem', 'valid_quitem_pricemode',
                    $$CHECK (quitem_pricemode IN ('D', 'M'))$$, 'public'),
  xt.add_constraint('quitem', 'quitem_quitem_itemsrc_id_fkey',
                   'FOREIGN KEY (quitem_itemsrc_id) REFERENCES itemsrc(itemsrc_id)', 'public'),
  xt.add_constraint('quitem', 'quitem_quitem_price_uom_id_fkey',
                   'FOREIGN KEY (quitem_price_uom_id) REFERENCES uom(uom_id)', 'public'),
  xt.add_constraint('quitem', 'quitem_quitem_qty_uom_id_fkey',
                   'FOREIGN KEY (quitem_qty_uom_id) REFERENCES uom(uom_id)', 'public'),
  xt.add_constraint('quitem', 'quitem_quitem_taxtype_id_fkey',
                   'FOREIGN KEY (quitem_taxtype_id) REFERENCES taxtype(taxtype_id)', 'public');

ALTER TABLE public.quitem ENABLE TRIGGER ALL;

COMMENT ON TABLE quitem IS 'Quote Line Item information';

COMMENT ON COLUMN quitem.quitem_pricemode IS 'Pricing mode for quote item.  Valid values are D-discount, and M-markup';
COMMENT ON COLUMN public.quitem.quitem_listprice IS 'List price of Item.';
