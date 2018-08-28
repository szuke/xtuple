SELECT xt.create_table('salesrep', 'public');

ALTER TABLE public.salesrep DISABLE TRIGGER ALL;

SELECT
  xt.add_column('salesrep', 'salesrep_id',               'SERIAL', 'NOT NULL', 'public'),
  xt.add_column('salesrep', 'salesrep_active',          'BOOLEAN', NULL, 'public'),
  xt.add_column('salesrep', 'salesrep_number',             'TEXT', 'NOT NULL', 'public'),
  xt.add_column('salesrep', 'salesrep_name',               'TEXT', NULL, 'public'),
  xt.add_column('salesrep', 'salesrep_commission', 'NUMERIC(8,4)', NULL, 'public'),
  xt.add_column('salesrep', 'salesrep_method',     'CHARACTER(1)', NULL, 'public'),
  xt.add_column('salesrep', 'salesrep_emp_id',          'INTEGER', NULL, 'public'),
  xt.add_column('salesrep', 'salesrep_created',     'TIMESTAMP WITH TIME ZONE', NULL, 'public'),
  xt.add_column('salesrep', 'salesrep_lastupdated', 'TIMESTAMP WITH TIME ZONE', NULL, 'public');

SELECT
  xt.add_constraint('salesrep', 'salesrep_pkey', 'PRIMARY KEY (salesrep_id)', 'public'),
  xt.add_constraint('salesrep', 'salesrep_salesrep_number_check',
                    $$CHECK (salesrep_number <> '')$$,                        'public'),
  xt.add_constraint('salesrep', 'salesrep_salesrep_number_key',
                    'UNIQUE (salesrep_number)',                               'public'),
  xt.add_constraint('salesrep', 'salesrep_salesrep_emp_id_fkey',
                    'FOREIGN KEY (salesrep_emp_id) REFERENCES emp(emp_id)',   'public');

ALTER TABLE public.salesrep ENABLE TRIGGER ALL;

COMMENT ON TABLE salesrep IS 'Sales Representative information';

COMMENT ON COLUMN salesrep.salesrep_emp_id IS 'DEPRECATED - the relationship between Sales Rep and Employee is now maintained through the crmacct table.';
