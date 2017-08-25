SELECT xt.create_table('prospect', 'public');

ALTER TABLE public.prospect DISABLE TRIGGER ALL;

SELECT
  xt.add_column('prospect', 'prospect_id',          'INTEGER', $$DEFAULT nextval('cust_cust_id_seq'::regclass) NOT NULL$$, 'public'),
  xt.add_column('prospect', 'prospect_active',      'BOOLEAN', 'DEFAULT true NOT NULL', 'public'),
  xt.add_column('prospect', 'prospect_number',         'TEXT', 'NOT NULL', 'public'),
  xt.add_column('prospect', 'prospect_name',           'TEXT', 'NOT NULL', 'public'),
  xt.add_column('prospect', 'prospect_cntct_id',    'INTEGER', NULL, 'public'),
  xt.add_column('prospect', 'prospect_comments',       'TEXT', NULL, 'public'),
  xt.add_column('prospect', 'prospect_salesrep_id', 'INTEGER', NULL, 'public'),
  xt.add_column('prospect', 'prospect_warehous_id', 'INTEGER', NULL, 'public'),
  xt.add_column('prospect', 'prospect_taxzone_id',  'INTEGER', NULL, 'public'),
  xt.add_column('prospect', 'prospect_created',     'TIMESTAMP WITH TIME ZONE', $$DEFAULT now() NOT NULL$$, 'public'),
  xt.add_column('prospect', 'prospect_lastupdated', 'TIMESTAMP WITH TIME ZONE', NULL, 'public');

SELECT
  xt.add_constraint('prospect', 'prospect_pkey', 'PRIMARY KEY (prospect_id)', 'public'),
  xt.add_constraint('prospect', 'prospect_prospect_number_check',
                    $$CHECK (prospect_number <> '')$$, 'public'),
  xt.add_constraint('prospect', 'prospect_prospect_number_key',
                    'UNIQUE (prospect_number)', 'public'),
  xt.add_constraint('prospect', 'prospect_prospect_cntct_id_fkey',
                    'FOREIGN KEY (prospect_cntct_id) REFERENCES cntct(cntct_id)', 'public'),
  xt.add_constraint('prospect', 'prospect_prospect_salesrep_id_fkey',
                    'FOREIGN KEY (prospect_salesrep_id) REFERENCES salesrep(salesrep_id)', 'public'),
  xt.add_constraint('prospect', 'prospect_prospect_taxzone_id_fkey',
                    'FOREIGN KEY (prospect_taxzone_id) REFERENCES taxzone(taxzone_id)', 'public'),
  xt.add_constraint('prospect', 'prospect_prospect_warehous_id_fkey',
                    'FOREIGN KEY (prospect_warehous_id) REFERENCES whsinfo(warehous_id)', 'public');

ALTER TABLE public.prospect ENABLE TRIGGER ALL;


COMMENT ON TABLE prospect IS 'Prospect Information';
