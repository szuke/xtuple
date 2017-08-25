SELECT xt.create_table('aropen', 'public');

ALTER TABLE public.aropen DISABLE TRIGGER ALL;

SELECT
  xt.add_column('aropen', 'aropen_id',                     'SERIAL', 'NOT NULL', 'public'),
  xt.add_column('aropen', 'aropen_docdate',                  'DATE', 'NOT NULL', 'public'),
  xt.add_column('aropen', 'aropen_duedate',                  'DATE', 'NOT NULL', 'public'),
  xt.add_column('aropen', 'aropen_terms_id',              'INTEGER', NULL,       'public'),
  xt.add_column('aropen', 'aropen_cust_id',               'INTEGER', NULL,       'public'),
  xt.add_column('aropen', 'aropen_doctype',          'CHARACTER(1)', NULL,       'public'),
  xt.add_column('aropen', 'aropen_docnumber',                'TEXT', NULL,       'public'),
  xt.add_column('aropen', 'aropen_applyto',                  'TEXT', NULL,       'public'),
  xt.add_column('aropen', 'aropen_ponumber',                 'TEXT', NULL,       'public'),
  xt.add_column('aropen', 'aropen_amount',          'NUMERIC(20,2)', 'NOT NULL', 'public'),
  xt.add_column('aropen', 'aropen_notes',                    'TEXT', NULL,       'public'),
  xt.add_column('aropen', 'aropen_posted',                'BOOLEAN', 'DEFAULT false NOT NULL', 'public'),
  xt.add_column('aropen', 'aropen_salesrep_id',           'INTEGER', NULL,       'public'),
  xt.add_column('aropen', 'aropen_commission_due',  'NUMERIC(20,2)', NULL,       'public'),
  xt.add_column('aropen', 'aropen_commission_paid',       'BOOLEAN', 'DEFAULT false', 'public'),
  xt.add_column('aropen', 'aropen_ordernumber',              'TEXT', NULL,       'public'),
  xt.add_column('aropen', 'aropen_cobmisc_id',            'INTEGER', 'DEFAULT -1', 'public'),
  xt.add_column('aropen', 'aropen_journalnumber',         'INTEGER', NULL,       'public'),
  xt.add_column('aropen', 'aropen_paid',            'NUMERIC(20,2)', 'DEFAULT 0', 'public'),
  xt.add_column('aropen', 'aropen_open',                  'BOOLEAN', NULL,       'public'),
  xt.add_column('aropen', 'aropen_username',                 'TEXT', NULL,       'public'),
  xt.add_column('aropen', 'aropen_rsncode_id',            'INTEGER', NULL,       'public'),
  xt.add_column('aropen', 'aropen_salescat_id',           'INTEGER', 'DEFAULT -1', 'public'),
  xt.add_column('aropen', 'aropen_accnt_id',              'INTEGER', 'DEFAULT -1', 'public'),
  xt.add_column('aropen', 'aropen_curr_id',               'INTEGER', 'DEFAULT basecurrid()', 'public'),
  xt.add_column('aropen', 'aropen_closedate',                'DATE', NULL,       'public'),
  xt.add_column('aropen', 'aropen_distdate',                 'DATE', NULL,       'public'),
  xt.add_column('aropen', 'aropen_curr_rate',             'NUMERIC', 'NOT NULL', 'public'),
  xt.add_column('aropen', 'aropen_discount',              'BOOLEAN', 'DEFAULT false NOT NULL', 'public'),
  xt.add_column('aropen', 'aropen_fincharg_date',            'DATE', NULL,       'public'),
  xt.add_column('aropen', 'aropen_fincharg_amount', 'NUMERIC(20,2)', NULL,       'public'),
  xt.add_column('aropen', 'aropen_taxzone_id',            'INTEGER', NULL,       'public');

select
  xt.add_constraint('aropen', 'aropen_pkey', 'PRIMARY KEY (aropen_id)', 'public'),
  xt.add_constraint('aropen', 'aropen_aropen_cust_id_fkey',
                    'FOREIGN KEY (aropen_cust_id) REFERENCES custinfo(cust_id)', 'public'),
  xt.add_constraint('aropen', 'aropen_aropen_salesrep_id_fkey',
                    'FOREIGN KEY (aropen_salesrep_id) REFERENCES salesrep(salesrep_id)', 'public'),
  xt.add_constraint('aropen', 'aropen_to_curr_symbol',
                    'FOREIGN KEY (aropen_curr_id) REFERENCES curr_symbol(curr_id)', 'public'),
  xt.add_constraint('aropen','aropen_taxzone_id_fkey',
                    'FOREIGN KEY (aropen_taxzone_id) REFERENCES taxzone(taxzone_id)', 'public');

ALTER TABLE public.aropen ENABLE TRIGGER ALL;

COMMENT ON TABLE aropen IS 'Accounts Receivable (A/R) open Items information';
