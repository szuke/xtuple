SELECT xt.create_table('wo', 'public');

ALTER TABLE public.wo DISABLE TRIGGER ALL;

SELECT
  xt.add_column('wo', 'wo_id',                 'SERIAL', 'NOT NULL',           'public'),
  xt.add_column('wo', 'wo_number',            'INTEGER', NULL,                 'public'),
  xt.add_column('wo', 'wo_subnumber',         'INTEGER', NULL,                 'public'),
  xt.add_column('wo', 'wo_status',       'CHARACTER(1)', NULL,                 'public'),
  xt.add_column('wo', 'wo_itemsite_id',       'INTEGER', NULL,                 'public'),
  xt.add_column('wo', 'wo_startdate',            'DATE', NULL,                 'public'),
  xt.add_column('wo', 'wo_duedate',              'DATE', NULL,                 'public'),
  xt.add_column('wo', 'wo_ordtype',      'CHARACTER(1)', NULL,                 'public'),
  xt.add_column('wo', 'wo_ordid',             'INTEGER', NULL,                 'public'),
  xt.add_column('wo', 'wo_qtyord',      'NUMERIC(18,6)', NULL,                 'public'),
  xt.add_column('wo', 'wo_qtyrcv',      'NUMERIC(18,6)', NULL,                 'public'),
  xt.add_column('wo', 'wo_adhoc',             'BOOLEAN', NULL,                 'public'),
  xt.add_column('wo', 'wo_itemcfg_series',    'INTEGER', NULL,                 'public'),
  xt.add_column('wo', 'wo_imported',          'BOOLEAN', NULL,                 'public'),
  xt.add_column('wo', 'wo_wipvalue',    'NUMERIC(16,6)', 'DEFAULT 0',          'public'),
  xt.add_column('wo', 'wo_postedvalue', 'NUMERIC(16,6)', 'DEFAULT 0',          'public'),
  xt.add_column('wo', 'wo_prodnotes',            'TEXT', NULL,                 'public'),
  xt.add_column('wo', 'wo_prj_id',            'INTEGER', NULL,                 'public'),
  xt.add_column('wo', 'wo_priority',          'INTEGER', 'DEFAULT 1 NOT NULL', 'public'),
  xt.add_column('wo', 'wo_brdvalue',    'NUMERIC(16,6)', 'DEFAULT 0',          'public'),
  xt.add_column('wo', 'wo_bom_rev_id',        'INTEGER', 'DEFAULT -1',         'public'),
  xt.add_column('wo', 'wo_boo_rev_id',        'INTEGER', 'DEFAULT -1',         'public'),
  xt.add_column('wo', 'wo_cosmethod',    'CHARACTER(1)', NULL,                 'public'),
  xt.add_column('wo', 'wo_womatl_id',         'INTEGER', NULL,                 'public'),
  xt.add_column('wo', 'wo_username',             'TEXT', 'DEFAULT geteffectivextuser()', 'public'),
  xt.add_column('wo', 'wo_created',     'TIMESTAMP WITH TIME ZONE', NULL, 'public'),
  xt.add_column('wo', 'wo_lastupdated', 'TIMESTAMP WITH TIME ZONE', NULL, 'public'),
  xt.add_column('wo', 'wo_closedate',   'TIMESTAMP WITH TIME ZONE', NULL, 'public');

SELECT
  xt.add_constraint('wo', 'wo_pkey', 'PRIMARY KEY (wo_id)', 'public'),
  xt.add_constraint('wo', 'chk_wo_cosmethod',
                    $$CHECK (wo_cosmethod = NULL OR wo_cosmethod IN ('D', 'P'))$$, 'public'),
  xt.add_constraint('wo', 'wo_wo_womatl_id_fkey',
                    'FOREIGN KEY (wo_womatl_id) REFERENCES womatl(womatl_id)
                     ON DELETE SET NULL', 'public');

ALTER TABLE public.wo ENABLE TRIGGER ALL;

COMMENT ON TABLE wo IS 'Work Order information';
