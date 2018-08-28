SELECT xt.create_table('bomitem', 'public');

ALTER TABLE public.bomitem DISABLE TRIGGER ALL;

SELECT
  xt.add_column('bomitem', 'bomitem_id',                'SERIAL', 'NOT NULL', 'public'),
  xt.add_column('bomitem', 'bomitem_parent_item_id',   'INTEGER', 'NOT NULL', 'public'),
  xt.add_column('bomitem', 'bomitem_seqnumber',        'INTEGER', NULL,       'public'),
  xt.add_column('bomitem', 'bomitem_item_id',          'INTEGER', 'NOT NULL', 'public'),
  xt.add_column('bomitem', 'bomitem_qtyper',     'NUMERIC(20,8)', 'NOT NULL', 'public'),
  xt.add_column('bomitem', 'bomitem_scrap',       'NUMERIC(8,4)', 'NOT NULL', 'public'),
  xt.add_column('bomitem', 'bomitem_status',      'CHARACTER(1)', NULL,       'public'),
  xt.add_column('bomitem', 'bomitem_effective',           'DATE', 'NOT NULL', 'public'),
  xt.add_column('bomitem', 'bomitem_expires',             'DATE', 'NOT NULL', 'public'),
  xt.add_column('bomitem', 'bomitem_createwo',         'BOOLEAN', 'NOT NULL', 'public'),
  xt.add_column('bomitem', 'bomitem_issuemethod', 'CHARACTER(1)', 'NOT NULL', 'public'),
  xt.add_column('bomitem', 'bomitem_schedatwooper',    'BOOLEAN', 'NOT NULL', 'public'),
  xt.add_column('bomitem', 'bomitem_ecn',                 'TEXT', NULL, 'public'),
  xt.add_column('bomitem', 'bomitem_moddate',             'DATE', NULL, 'public'),
  xt.add_column('bomitem', 'bomitem_subtype',     'CHARACTER(1)', 'NOT NULL', 'public'),
  xt.add_column('bomitem', 'bomitem_uom_id',           'INTEGER', 'NOT NULL', 'public'),
  xt.add_column('bomitem', 'bomitem_rev_id',           'INTEGER', 'DEFAULT -1', 'public'),
  xt.add_column('bomitem', 'bomitem_booitem_seq_id',   'INTEGER', 'DEFAULT -1', 'public'),
  xt.add_column('bomitem', 'bomitem_char_id',          'INTEGER', NULL, 'public'),
  xt.add_column('bomitem', 'bomitem_value',               'TEXT', NULL, 'public'),
  xt.add_column('bomitem', 'bomitem_notes',               'TEXT', NULL, 'public'),
  xt.add_column('bomitem', 'bomitem_ref',                 'TEXT', NULL, 'public'),
  xt.add_column('bomitem', 'bomitem_qtyfxd',     'NUMERIC(20,8)', 'DEFAULT 0 NOT NULL', 'public'),
  xt.add_column('bomitem', 'bomitem_issuewo',          'BOOLEAN', 'DEFAULT false NOT NULL', 'public'),
  xt.add_column('bomitem', 'bomitem_created',     'TIMESTAMP WITH TIME ZONE', NULL, 'public'),
  xt.add_column('bomitem', 'bomitem_lastupdated', 'TIMESTAMP WITH TIME ZONE', NULL, 'public');

SELECT
  xt.add_constraint('bomitem', 'bomitem_pkey', 'PRIMARY KEY (bomitem_id)', 'public'),
  xt.add_constraint('bomitem', 'bomitem_bomitem_char_id_fkey',
                    'FOREIGN KEY (bomitem_char_id) REFERENCES "char"(char_id)', 'public'),
  xt.add_constraint('bomitem', 'bomitem_bomitem_item_id_fkey',
                    'FOREIGN KEY (bomitem_item_id) REFERENCES item(item_id)', 'public'),
  xt.add_constraint('bomitem', 'bomitem_bomitem_parent_item_id_fkey',
                    'FOREIGN KEY (bomitem_parent_item_id) REFERENCES item(item_id) ON UPDATE RESTRICT ON DELETE CASCADE', 'public'),
  xt.add_constraint('bomitem', 'bomitem_bomitem_uom_id_fkey',
                    'FOREIGN KEY (bomitem_uom_id) REFERENCES uom(uom_id)', 'public'),
  xt.add_constraint('bomitem', 'bomitem_bomitem_issuemethod_check',
                    $$CHECK bomitem_issuemethod IN ('M', 'S', 'L')$$, 'public'),
  xt.add_constraint('bomitem', 'bomitem_bomitem_subtype_check',
                    $$CHECK bomitem_subtype IN ('N', 'I', 'B')$$, 'public');

ALTER TABLE public.bomitem ENABLE TRIGGER ALL;

COMMENT ON TABLE bomitem IS 'Bill of Materials (BOM) component Items information';

COMMENT ON COLUMN bomitem.bomitem_qtyfxd IS 'The fixed quantity required';
