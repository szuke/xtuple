SELECT xt.create_table('cmitem', 'public');

ALTER TABLE public.cmitem DISABLE TRIGGER ALL;

SELECT
  xt.add_column('cmitem', 'cmitem_id',                        'SERIAL', 'NOT NULL', 'public'),
  xt.add_column('cmitem', 'cmitem_cmhead_id',                'INTEGER', 'NOT NULL', 'public'),
  xt.add_column('cmitem', 'cmitem_linenumber',               'INTEGER', 'NOT NULL', 'public'),
  xt.add_column('cmitem', 'cmitem_itemsite_id',              'INTEGER', NULL,       'public'),
  xt.add_column('cmitem', 'cmitem_qtycredit',          'NUMERIC(18,6)', 'NOT NULL', 'public'),
  xt.add_column('cmitem', 'cmitem_qtyreturned',        'NUMERIC(18,6)', 'NOT NULL', 'public'),
  xt.add_column('cmitem', 'cmitem_unitprice',          'NUMERIC(16,4)', 'NOT NULL', 'public'),
  xt.add_column('cmitem', 'cmitem_comments',                    'TEXT', NULL,       'public'),
  xt.add_column('cmitem', 'cmitem_rsncode_id',               'INTEGER', NULL,       'public'),
  xt.add_column('cmitem', 'cmitem_taxtype_id',               'INTEGER', NULL,       'public'),
  xt.add_column('cmitem', 'cmitem_qty_uom_id',               'INTEGER', NULL,       'public'),
  xt.add_column('cmitem', 'cmitem_qty_invuomratio',   'NUMERIC(20,10)', 'NOT NULL', 'public'),
  xt.add_column('cmitem', 'cmitem_price_uom_id',             'INTEGER', NULL,       'public'),
  xt.add_column('cmitem', 'cmitem_price_invuomratio', 'NUMERIC(20,10)', 'NOT NULL', 'public'),
  xt.add_column('cmitem', 'cmitem_raitem_id',                'INTEGER', NULL,       'public'),
  xt.add_column('cmitem', 'cmitem_updateinv',                'BOOLEAN', 'DEFAULT true NOT NULL', 'public'),
  xt.add_column('cmitem', 'cmitem_number',             'TEXT', NULL, 'public'),
  xt.add_column('cmitem', 'cmitem_descrip',            'TEXT', NULL, 'public'),
  xt.add_column('cmitem', 'cmitem_salescat_id',     'INTEGER', NULL, 'public'),
  xt.add_column('cmitem', 'cmitem_rev_accnt_id',    'INTEGER', NULL, 'public'),
  xt.add_column('cmitem', 'cmitem_listprice', 'NUMERIC(16,4)', NULL, 'public');

SELECT
  xt.add_constraint('cmitem', 'cmitem_pkey', 'PRIMARY KEY (cmitem_id)', 'public'),
  xt.add_constraint('cmitem', 'cmitem_cmhead_id_linenumber_unique',
                    'UNIQUE (cmitem_cmhead_id, cmitem_linenumber)', 'public'),
  xt.add_constraint('cmitem', 'cmitem_itemsite_id_fkey',
                    'FOREIGN KEY (cmitem_itemsite_id) REFERENCES itemsite (itemsite_id)
                     MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION', 'public'),
  xt.add_constraint('cmitem', 'cmitem_salescat_id_fkey',
                    'FOREIGN KEY (cmitem_salescat_id) REFERENCES salescat (salescat_id)
                     MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION', 'public'),
  xt.add_constraint('cmitem', 'cmitem_rev_accnt_id_fkey',
                    'FOREIGN KEY (cmitem_rev_accnt_id) REFERENCES accnt (accnt_id)
                     MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION', 'public'),
  xt.add_constraint('cmitem', 'cmitem_cmhead_id_fkey',
                    'FOREIGN KEY (cmitem_cmhead_id) REFERENCES cmhead(cmhead_id)
                     ON UPDATE CASCADE ON DELETE CASCADE', 'public'),
  xt.add_constraint('cmitem', 'cmitem_cmitem_price_uom_id_fkey',
                    'FOREIGN KEY (cmitem_price_uom_id) REFERENCES uom(uom_id)', 'public'),
  xt.add_constraint('cmitem', 'cmitem_cmitem_qty_uom_id_fkey',
                    'FOREIGN KEY (cmitem_qty_uom_id) REFERENCES uom(uom_id)', 'public'),
  xt.add_constraint('cmitem', 'cmitem_cmitem_taxtype_id_fkey',
                    'FOREIGN KEY (cmitem_taxtype_id) REFERENCES taxtype(taxtype_id)', 'public');

-- drop legacy constraints
ALTER TABLE cmitem ALTER COLUMN cmitem_qty_uom_id DROP NOT NULL;
ALTER TABLE cmitem ALTER COLUMN cmitem_price_uom_id DROP NOT NULL;
ALTER TABLE cmitem ALTER COLUMN cmitem_itemsite_id DROP NOT NULL;

ALTER TABLE public.cmitem ENABLE TRIGGER ALL;

COMMENT ON TABLE cmitem IS 'S/O Credit Memo Line Item information';

COMMENT ON COLUMN public.cmitem.cmitem_listprice IS 'List price of Item.';
