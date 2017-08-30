SELECT xt.create_table('company', 'public');

ALTER TABLE public.company DISABLE TRIGGER ALL;

SELECT
  xt.add_column('company', 'company_id',                      'SERIAL', 'NOT NULL', 'public'),
  xt.add_column('company', 'company_number',                    'TEXT', 'NOT NULL', 'public'),
  xt.add_column('company', 'company_descrip',                   'TEXT', NULL,       'public'),
  xt.add_column('company', 'company_external',               'BOOLEAN', 'DEFAULT false NOT NULL', 'public'),
  xt.add_column('company', 'company_server',                    'TEXT', NULL,       'public'),
  xt.add_column('company', 'company_port',                   'INTEGER', NULL,       'public'),
  xt.add_column('company', 'company_database',                  'TEXT', NULL,       'public'),
  xt.add_column('company', 'company_curr_id',                'INTEGER', NULL,       'public'),
  xt.add_column('company', 'company_yearend_accnt_id',       'INTEGER', NULL,       'public'),
  xt.add_column('company', 'company_gainloss_accnt_id',      'INTEGER', NULL,       'public'),
  xt.add_column('company', 'company_dscrp_accnt_id',         'INTEGER', NULL,       'public'),
  xt.add_column('company', 'company_unrlzgainloss_accnt_id', 'INTEGER', NULL,       'public'),
  xt.add_column('company', 'company_unassigned_accnt_id',    'INTEGER', '',         'public');

SELECT
  xt.add_constraint('company', 'company_pkey', 'PRIMARY KEY (company_id)', 'public'),
  xt.add_constraint('company', 'company_company_number_key', 'UNIQUE (company_number)', 'public'),
  xt.add_constraint('company', 'company_company_number_check',
                    $$CHECK (company_number <> '')$$, 'public'),
  xt.add_constraint('company', 'company_company_curr_id_fkey',
                    'FOREIGN KEY (company_curr_id) REFERENCES curr_symbol(curr_id)', 'public'),
  xt.add_constraint('company', 'company_company_dscrp_accnt_id_fkey',
                    'FOREIGN KEY (company_dscrp_accnt_id) REFERENCES accnt(accnt_id)', 'public'),
  xt.add_constraint('company', 'company_company_gainloss_accnt_id_fkey',
                    'FOREIGN KEY (company_gainloss_accnt_id) REFERENCES accnt(accnt_id)', 'public'),
  xt.add_constraint('company', 'company_company_unrlzgainloss_accnt_id_fkey',
                    'FOREIGN KEY (company_unrlzgainloss_accnt_id) REFERENCES accnt(accnt_id)', 'public'),
  xt.add_constraint('company', 'company_company_yearend_accnt_id_fkey',
                    'FOREIGN KEY (company_yearend_accnt_id) REFERENCES accnt(accnt_id)', 'public');

ALTER TABLE public.company ENABLE TRIGGER ALL;

COMMENT ON TABLE company IS 'Company information';
