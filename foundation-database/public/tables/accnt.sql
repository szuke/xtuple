SELECT xt.create_table('accnt', 'public');

ALTER TABLE public.accnt DISABLE TRIGGER ALL;

SELECT
  xt.add_column('accnt', 'accnt_id',              'SERIAL', 'NOT NULL', 'public'),
  xt.add_column('accnt', 'accnt_number',            'TEXT', NULL,       'public'),
  xt.add_column('accnt', 'accnt_descrip',           'TEXT', NULL,       'public'),
  xt.add_column('accnt', 'accnt_comments',          'TEXT', NULL,       'public'),
  xt.add_column('accnt', 'accnt_profit',            'TEXT', NULL,       'public'),
  xt.add_column('accnt', 'accnt_sub',               'TEXT', NULL,       'public'),
  xt.add_column('accnt', 'accnt_type',      'CHARACTER(1)', 'NOT NULL', 'public'),
  xt.add_column('accnt', 'accnt_extref',            'TEXT', NULL,       'public'),
  xt.add_column('accnt', 'accnt_company',           'TEXT', NULL,       'public'),
  xt.add_column('accnt', 'accnt_forwardupdate',  'BOOLEAN', NULL,       'public'),
  xt.add_column('accnt', 'accnt_subaccnttype_code', 'TEXT', NULL,       'public'),
  xt.add_column('accnt', 'accnt_curr_id',        'INTEGER', 'DEFAULT basecurrid()', 'public'),
  xt.add_column('accnt', 'accnt_active',         'BOOLEAN', 'DEFAULT true NOT NULL', 'public'),
  xt.add_column('accnt', 'accnt_name',              'TEXT', NULL,        'public'),
  xt.add_column('accnt', 'accnt_1099_form_type',    'TEXT', NULL,        'public');

ALTER TABLE accnt DROP CONSTRAINT IF EXISTS accnt_accnt_1099_form_check;

SELECT
  xt.add_constraint('accnt', 'accnt_pkey', $$PRIMARY KEY (accnt_id)$$, 'public'),
  xt.add_constraint('accnt', 'accnt_accnt_company_fkey',
                    $$FOREIGN KEY (accnt_company) REFERENCES company(company_number)
                      ON UPDATE CASCADE$$, 'public'),
  xt.add_constraint('accnt', 'accnt_to_curr_symbol',
                    $$FOREIGN KEY (accnt_curr_id) REFERENCES curr_symbol(curr_id)$$, 'public'),
  xt.add_constraint('accnt', 'accnt_accnt_1099_form_check',
                    $$CHECK (accnt_1099_form_type IN ('MISC', 'RENT'))$$, 'public'),
  xt.add_constraint('accnt', 'accnt_accnt_type_check',
                    $$CHECK (accnt_type IN ('A', 'E', 'L', 'Q', 'R'))$$, 'public');

ALTER TABLE public.accnt ENABLE TRIGGER ALL;

COMMENT ON TABLE accnt IS 'General Ledger (G/L) Account Number information';
