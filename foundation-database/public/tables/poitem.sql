SELECT xt.create_table('poitem', 'public');

ALTER TABLE public.poitem DISABLE TRIGGER ALL;

SELECT
  xt.add_column('poitem', 'poitem_id',              'SERIAL', 'NOT NULL', 'public'),
  xt.add_column('poitem', 'poitem_status',    'CHARACTER(1)', NULL, 'public'),
  xt.add_column('poitem', 'poitem_pohead_id',      'INTEGER', NULL, 'public'),
  xt.add_column('poitem', 'poitem_linenumber',     'INTEGER', NULL, 'public'),
  xt.add_column('poitem', 'poitem_duedate',           'DATE', NULL, 'public'),
  xt.add_column('poitem', 'poitem_itemsite_id',    'INTEGER', NULL, 'public'),
  xt.add_column('poitem', 'poitem_vend_item_descrip', 'TEXT', NULL, 'public'),
  xt.add_column('poitem', 'poitem_vend_uom',          'TEXT', NULL, 'public'),
  xt.add_column('poitem', 'poitem_invvenduomratio',   'NUMERIC(20,10)', NULL, 'public'),
  xt.add_column('poitem', 'poitem_qty_ordered',       'NUMERIC(18,6)', 'NOT NULL', 'public'),
  xt.add_column('poitem', 'poitem_qty_received',      'NUMERIC(18,6)', 'DEFAULT 0.0 NOT NULL', 'public'),
  xt.add_column('poitem', 'poitem_qty_returned',      'NUMERIC(18,6)', 'DEFAULT 0.0 NOT NULL', 'public'),
  xt.add_column('poitem', 'poitem_qty_vouchered',     'NUMERIC(18,6)', 'DEFAULT 0.0 NOT NULL', 'public'),
  xt.add_column('poitem', 'poitem_unitprice',         'NUMERIC(16,6)', NULL, 'public'),
  xt.add_column('poitem', 'poitem_vend_item_number',           'TEXT', NULL, 'public'),
  xt.add_column('poitem', 'poitem_comments',                   'TEXT', NULL, 'public'),
  xt.add_column('poitem', 'poitem_qty_toreceive',     'NUMERIC(18,6)', NULL, 'public'),
  xt.add_column('poitem', 'poitem_expcat_id',               'INTEGER', NULL, 'public'),
  xt.add_column('poitem', 'poitem_itemsrc_id',              'INTEGER', NULL, 'public'),
  xt.add_column('poitem', 'poitem_freight',           'NUMERIC(16,4)', 'DEFAULT 0.0 NOT NULL', 'public'),
  xt.add_column('poitem', 'poitem_freight_received',  'NUMERIC(16,4)', 'DEFAULT 0.0 NOT NULL', 'public'),
  xt.add_column('poitem', 'poitem_freight_vouchered', 'NUMERIC(16,4)', 'DEFAULT 0.0 NOT NULL', 'public'),
  xt.add_column('poitem', 'poitem_prj_id',          'INTEGER', NULL, 'public'),
  xt.add_column('poitem', 'poitem_stdcost',   'NUMERIC(16,6)', NULL, 'public'),
  xt.add_column('poitem', 'poitem_bom_rev_id',      'INTEGER', NULL, 'public'),
  xt.add_column('poitem', 'poitem_boo_rev_id',      'INTEGER', NULL, 'public'),
  xt.add_column('poitem', 'poitem_manuf_name',         'TEXT', NULL, 'public'),
  xt.add_column('poitem', 'poitem_manuf_item_number',  'TEXT', NULL, 'public'),
  xt.add_column('poitem', 'poitem_manuf_item_descrip', 'TEXT', NULL, 'public'),
  xt.add_column('poitem', 'poitem_taxtype_id',      'INTEGER', NULL, 'public'),
  xt.add_column('poitem', 'poitem_tax_recoverable', 'BOOLEAN', 'DEFAULT true NOT NULL', 'public'),
  xt.add_column('poitem', 'poitem_rlsd_duedate',       'DATE', NULL, 'public'),
  xt.add_column('poitem', 'poitem_order_id',        'INTEGER', NULL, 'public'),
  xt.add_column('poitem', 'poitem_order_type', 'CHARACTER(1)', NULL, 'public'),

  xt.add_column('poitem', 'poitem_created',     'TIMESTAMP WITH TIME ZONE', NULL, 'public'),
  xt.add_column('poitem', 'poitem_lastupdated', 'TIMESTAMP WITH TIME ZONE', NULL, 'public');

DELETE FROM poitem
 WHERE NOT EXISTS(SELECT 1
                    FROM pohead
                   WHERE pohead_id=poitem_pohead_id);

SELECT
  xt.add_constraint('poitem', 'poitem_pkey', 'PRIMARY KEY (poitem_id)',                 'public'),
  xt.add_constraint('poitem', 'poitem_poitem_pohead_id_key',
                    'UNIQUE (poitem_pohead_id, poitem_linenumber)',                     'public'), 
  xt.add_constraint('poitem', 'poitem_poitem_status_check',
                    $$CHECK (poitem_status IN ('U', 'O', 'C'))$$,                       'public'),
  xt.add_constraint('poitem', 'poitem_poitem_pohead_id_fkey',
                   'FOREIGN KEY (poitem_pohead_id) REFERENCES pohead(pohead_id)',       'public'),
  xt.add_constraint('poitem', 'poitem_poitem_expcat_id_fkey',
                   'FOREIGN KEY (poitem_expcat_id) REFERENCES expcat(expcat_id)',       'public'),
  xt.add_constraint('poitem', 'poitem_poitem_itemsite_id_fkey',
                   'FOREIGN KEY (poitem_itemsite_id) REFERENCES itemsite(itemsite_id)', 'public'),
  xt.add_constraint('poitem', 'poitem_poitem_itemsrc_id_fkey',
                   'FOREIGN KEY (poitem_itemsrc_id) REFERENCES itemsrc(itemsrc_id)',    'public'),
  xt.add_constraint('poitem', 'poitem_poitem_prj_id_fkey',
                   'FOREIGN KEY (poitem_prj_id) REFERENCES prj(prj_id)',                'public'),
  xt.add_constraint('poitem', 'poitem_poitem_taxtype_id_fkey',
                   'FOREIGN KEY (poitem_taxtype_id) REFERENCES taxtype(taxtype_id)',    'public');

ALTER TABLE public.poitem ENABLE TRIGGER ALL;

COMMENT ON TABLE poitem IS 'Purchase Order Line Item information';
