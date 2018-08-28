SELECT xt.create_table('apapply', 'public');

ALTER TABLE public.apapply DISABLE TRIGGER ALL;

SELECT
  xt.add_column('apapply', 'apapply_id',                 'SERIAL', 'NOT NULL', 'public'),
  xt.add_column('apapply', 'apapply_vend_id',           'INTEGER', NULL, 'public'),
  xt.add_column('apapply', 'apapply_postdate',             'DATE', NULL, 'public'),
  xt.add_column('apapply', 'apapply_username',             'TEXT', NULL, 'public'),
  xt.add_column('apapply', 'apapply_source_apopen_id',  'INTEGER', NULL, 'public'),
  xt.add_column('apapply', 'apapply_source_doctype',       'TEXT', NULL, 'public'),
  xt.add_column('apapply', 'apapply_source_docnumber',     'TEXT', NULL, 'public'),
  xt.add_column('apapply', 'apapply_target_apopen_id',  'INTEGER', NULL, 'public'),
  xt.add_column('apapply', 'apapply_target_doctype',       'TEXT', NULL, 'public'),
  xt.add_column('apapply', 'apapply_target_docnumber',     'TEXT', NULL, 'public'),
  xt.add_column('apapply', 'apapply_journalnumber',     'INTEGER', NULL, 'public'),
  xt.add_column('apapply', 'apapply_amount',      'NUMERIC(20,2)', NULL, 'public'),
  xt.add_column('apapply', 'apapply_curr_id',           'INTEGER', 'DEFAULT basecurrid()', 'public'),
  xt.add_column('apapply', 'apapply_target_paid', 'NUMERIC(20,2)', NULL, 'public'),
  xt.add_column('apapply', 'apapply_checkhead_id',      'INTEGER', NULL, 'public'),
  xt.add_column('apapply', 'apapply_target_curr_id',    'INTEGER', NULL, 'public'),
  xt.add_column('apapply', 'apapply_reversed',          'BOOLEAN', 'NOT NULL DEFAULT false', 'public');

select
  xt.add_constraint('apapply', 'apapply_pkey',
                    'PRIMARY KEY (apapply_id)', 'public'),
  xt.add_constraint('apapply', 'apapply_apapply_checkhead_id_fkey',
                    'FOREIGN KEY (apapply_checkhead_id) REFERENCES checkhead(checkhead_id)', 'public'),
  xt.add_constraint('apapply', 'apapply_apapply_vend_id_fkey',
                    'FOREIGN KEY (apapply_vend_id) REFERENCES vendinfo(vend_id)', 'public'),
  xt.add_constraint('apapply', 'apapply_to_curr_symbol',
                    'FOREIGN KEY (apapply_curr_id) REFERENCES curr_symbol(curr_id)', 'public'),
  xt.add_constraint('apapply', 'apapply_target_curr_id_fkey',
                    'FOREIGN KEY (apapply_target_curr_id) REFERENCES curr_symbol(curr_id)', 'public');

ALTER TABLE public.apapply ENABLE TRIGGER ALL;

COMMENT ON TABLE apapply IS 'Applications (e.g., Payments, A/P Credit Memos) made to Accounts Payable (A/P) Documents';
COMMENT ON COLUMN apapply.apapply_source_apopen_id IS 'If apapply_source_doctype is "C" (credit memo) then apapply_source_apopen_id acts as a foreign key to the apopen table. If the source doctype is "K" (check) then the apapply_source_apopen_id acts as a foreign key to the checkhead table. If the apapply_source_apopen_id is -1 then the internal id of the source document is not known (always the case for checks posted before release 3.2.0BETA).';
