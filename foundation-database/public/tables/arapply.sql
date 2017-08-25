SELECT xt.create_table('arapply', 'public');

ALTER TABLE public.arapply DISABLE TRIGGER ALL;

SELECT
  xt.add_column('arapply', 'arapply_id',                 'SERIAL', 'NOT NULL', 'public'),
  xt.add_column('arapply', 'arapply_postdate',             'DATE', NULL, 'public'),
  xt.add_column('arapply', 'arapply_cust_id',           'INTEGER', NULL, 'public'),
  xt.add_column('arapply', 'arapply_source_doctype',       'TEXT', NULL, 'public'),
  xt.add_column('arapply', 'arapply_source_docnumber',     'TEXT', NULL, 'public'),
  xt.add_column('arapply', 'arapply_target_doctype',       'TEXT', NULL, 'public'),
  xt.add_column('arapply', 'arapply_target_docnumber',     'TEXT', NULL, 'public'),
  xt.add_column('arapply', 'arapply_fundstype',            'TEXT', NULL, 'public'),
  xt.add_column('arapply', 'arapply_refnumber',            'TEXT', NULL, 'public'),
  xt.add_column('arapply', 'arapply_applied',     'NUMERIC(20,2)', NULL, 'public'),
  xt.add_column('arapply', 'arapply_closed',            'BOOLEAN', NULL, 'public'),
  xt.add_column('arapply', 'arapply_journalnumber',        'TEXT', NULL, 'public'),
  xt.add_column('arapply', 'arapply_source_aropen_id',  'INTEGER', NULL, 'public'),
  xt.add_column('arapply', 'arapply_target_aropen_id',  'INTEGER', NULL, 'public'),
  xt.add_column('arapply', 'arapply_username',             'TEXT', NULL, 'public'),
  xt.add_column('arapply', 'arapply_curr_id',           'INTEGER', 'DEFAULT basecurrid()', 'public'),
  xt.add_column('arapply', 'arapply_distdate',             'DATE', 'NOT NULL', 'public'),
  xt.add_column('arapply', 'arapply_target_paid', 'NUMERIC(20,2)', NULL, 'public'),
  xt.add_column('arapply', 'arapply_reftype',              'TEXT', NULL, 'public'),
  xt.add_column('arapply', 'arapply_ref_id',            'INTEGER', NULL, 'public'),
  xt.add_column('arapply', 'arapply_reversed',          'BOOLEAN', 'NOT NULL DEFAULT false', 'public');

SELECT
  xt.add_constraint('arapply', 'arapply_pkey', 'PRIMARY KEY (arapply_id)', 'public'),
  xt.add_constraint('arapply', 'arapply_to_curr_symbol',
                    'FOREIGN KEY (arapply_curr_id) REFERENCES curr_symbol(curr_id)', 'public');

ALTER TABLE public.arapply ENABLE TRIGGER ALL;

COMMENT ON TABLE arapply IS 'Applications (e.g., Cash Receipts, A/R Credit Memos) made to Accounts Receivable (A/R) Documents';
