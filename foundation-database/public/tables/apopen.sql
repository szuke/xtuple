SELECT xt.create_table('apopen', 'public');

ALTER TABLE public.apopen DISABLE TRIGGER ALL;

SELECT
  xt.add_column('apopen', 'apopen_id',             'SERIAL', 'NOT NULL',  'public'),
  xt.add_column('apopen', 'apopen_docdate',          'DATE', NULL,        'public'),
  xt.add_column('apopen', 'apopen_duedate',          'DATE', NULL,        'public'),
  xt.add_column('apopen', 'apopen_terms_id',      'INTEGER', NULL,        'public'),
  xt.add_column('apopen', 'apopen_vend_id',       'INTEGER', NULL,        'public'),
  xt.add_column('apopen', 'apopen_doctype',  'CHARACTER(1)', NULL,        'public'),
  xt.add_column('apopen', 'apopen_docnumber',        'TEXT', NULL,        'public'),
  xt.add_column('apopen', 'apopen_amount',  'NUMERIC(20,2)', NULL,        'public'),
  xt.add_column('apopen', 'apopen_notes',            'TEXT', NULL,        'public'),
  xt.add_column('apopen', 'apopen_posted',        'BOOLEAN', NULL,        'public'),
  xt.add_column('apopen', 'apopen_reference',        'TEXT', NULL,        'public'),
  xt.add_column('apopen', 'apopen_invcnumber',       'TEXT', NULL,        'public'),
  xt.add_column('apopen', 'apopen_ponumber',         'TEXT', NULL,        'public'),
  xt.add_column('apopen', 'apopen_journalnumber', 'INTEGER', NULL,        'public'),
  xt.add_column('apopen', 'apopen_paid',    'NUMERIC(20,2)', 'DEFAULT 0', 'public'),
  xt.add_column('apopen', 'apopen_open',          'BOOLEAN', NULL,        'public'),
  xt.add_column('apopen', 'apopen_username',         'TEXT', NULL,        'public'),
  xt.add_column('apopen', 'apopen_discount',      'BOOLEAN', 'DEFAULT false NOT NULL', 'public'),
  xt.add_column('apopen', 'apopen_accnt_id',      'INTEGER', 'DEFAULT -1', 'public'),
  xt.add_column('apopen', 'apopen_curr_id',       'INTEGER', 'DEFAULT basecurrid()', 'public'),
  xt.add_column('apopen', 'apopen_closedate',        'DATE', NULL,        'public'),
  xt.add_column('apopen', 'apopen_distdate',         'DATE', NULL,        'public'),
  xt.add_column('apopen', 'apopen_void',          'BOOLEAN', 'DEFAULT false NOT NULL', 'public'),
  xt.add_column('apopen', 'apopen_curr_rate',     'NUMERIC', 'NOT NULL',  'public'),
  xt.add_column('apopen', 'apopen_discountable_amount', 'NUMERIC(20,2)', 'DEFAULT 0', 'public'),
  xt.add_column('apopen', 'apopen_status',           'TEXT', NULL,        'public'),
  xt.add_column('apopen', 'apopen_taxzone_id',    'INTEGER', NULL,        'public'),
  xt.add_column('apopen', 'apopen_hold_comment',     'TEXT', NULL,        'public');

SELECT
  xt.add_constraint('apopen', 'apopen_pkey',   'PRIMARY KEY (apopen_id)', 'public'),
  xt.add_constraint('apopen', 'apopen_apopen_vend_id_fkey',
                    'FOREIGN KEY (apopen_vend_id) REFERENCES vendinfo(vend_id)', 'public'),
  xt.add_constraint('apopen', 'apopen_to_curr_symbol',
                    'FOREIGN KEY (apopen_curr_id) REFERENCES curr_symbol(curr_id)', 'public'),
  xt.add_constraint('apopen', 'apopen_apopen_status_notnull', 'NOT NULL', 'public'),
  xt.add_constraint('apopen', 'apopen_apopen_status_check',
                    $$CHECK apopen_status IN ('O', 'H', 'C')$$, 'public'),
  xt.add_constraint('apopen','apopen_taxzone_id_fkey',
                    'FOREIGN KEY (apopen_taxzone_id) REFERENCES taxzone(taxzone_id)', 'public');

ALTER TABLE public.apopen ENABLE TRIGGER ALL;

COMMENT ON TABLE apopen IS 'Accounts Payable (A/P) open Items information';
