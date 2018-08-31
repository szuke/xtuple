SELECT xt.create_table('emp', 'public');

ALTER TABLE public.emp DISABLE TRIGGER ALL;

SELECT
  xt.add_column('emp', 'emp_id',            'SERIAL', 'NOT NULL',              'public'),
  xt.add_column('emp', 'emp_code',            'TEXT', 'NOT NULL',              'public'),
  xt.add_column('emp', 'emp_number',          'TEXT', 'NOT NULL',              'public'),
  xt.add_column('emp', 'emp_active',       'BOOLEAN', 'DEFAULT true NOT NULL', 'public'),
  xt.add_column('emp', 'emp_cntct_id',     'INTEGER', NULL,                    'public'),
  xt.add_column('emp', 'emp_warehous_id',  'INTEGER', NULL,                    'public'),
  xt.add_column('emp', 'emp_mgr_emp_id',   'INTEGER', NULL,                    'public'),
  xt.add_column('emp', 'emp_wage_type',       'TEXT', 'NOT NULL',              'public'),
  xt.add_column('emp', 'emp_wage',         'NUMERIC', NULL,                    'public'),
  xt.add_column('emp', 'emp_wage_curr_id', 'INTEGER', 'DEFAULT basecurrid()',  'public'),
  xt.add_column('emp', 'emp_wage_period',     'TEXT', 'NOT NULL',              'public'),
  xt.add_column('emp', 'emp_dept_id',      'INTEGER', NULL,                    'public'),
  xt.add_column('emp', 'emp_shift_id',     'INTEGER', NULL,                    'public'),
  xt.add_column('emp', 'emp_notes',           'TEXT', NULL,                    'public'),
  xt.add_column('emp', 'emp_image_id',     'INTEGER', NULL,                    'public'),
  xt.add_column('emp', 'emp_username',        'TEXT', NULL,                    'public'),
  xt.add_column('emp', 'emp_extrate',      'NUMERIC', NULL,                    'public'),
  xt.add_column('emp', 'emp_extrate_period',  'TEXT', 'NOT NULL',              'public'),
  xt.add_column('emp', 'emp_startdate',       'DATE', $$DEFAULT ('now'::text)::date$$, 'public'),
  xt.add_column('emp', 'emp_name',            'TEXT', 'NOT NULL',              'public'),
  xt.add_column('emp', 'emp_created',      'TIMESTAMP WITH TIME ZONE', NULL,   'public'),
  xt.add_column('emp', 'emp_lastupdated',  'TIMESTAMP WITH TIME ZONE', NULL,   'public');

SELECT
  xt.add_constraint('emp', 'emp_pkey', 'PRIMARY KEY (emp_id)', 'public'),
  xt.add_constraint('emp', 'emp_check',
                    $$CHECK ((emp_wage_type IN ('', 'H', 'S') AND COALESCE(emp_wage, 0.0) = 0.0)
                        OR (emp_wage_type <> '' AND emp_wage IS NOT NULL))$$,    'public'),
  xt.add_constraint('emp', 'emp_emp_code_check',   $$CHECK (emp_code <> '')$$,   'public'),
  xt.add_constraint('emp', 'emp_emp_number_check', $$CHECK (emp_number <> '')$$, 'public'),
  xt.add_constraint('emp', 'emp_emp_wage_period_check',
                    $$CHECK (emp_wage_period IN ('', 'H', 'D', 'W', 'BW', 'M', 'Y'))$$, 'public'),
  xt.add_constraint('emp', 'emp_emp_code_key', 'UNIQUE (emp_code)', 'public'),
  xt.add_constraint('emp', 'emp_emp_number_key', 'UNIQUE (emp_number)', 'public'),
  xt.add_constraint('emp', 'emp_emp_cntct_id_fkey',
                    'FOREIGN KEY (emp_cntct_id) REFERENCES cntct(cntct_id)', 'public'),
  xt.add_constraint('emp', 'emp_emp_dept_id_fkey',
                    'FOREIGN KEY (emp_dept_id) REFERENCES dept(dept_id)', 'public'),
  xt.add_constraint('emp', 'emp_emp_mgr_emp_id_fkey',
                    'FOREIGN KEY (emp_mgr_emp_id) REFERENCES emp(emp_id)', 'public'),
  xt.add_constraint('emp', 'emp_emp_shift_id_fkey',
                    'FOREIGN KEY (emp_shift_id) REFERENCES shift(shift_id)', 'public'),
  xt.add_constraint('emp', 'emp_emp_wage_curr_id_fkey',
                    'FOREIGN KEY (emp_wage_curr_id) REFERENCES curr_symbol(curr_id)', 'public'),
  xt.add_constraint('emp', 'emp_emp_warehous_id_fkey',
                    'FOREIGN KEY (emp_warehous_id) REFERENCES whsinfo(warehous_id)', 'public');

ALTER TABLE public.emp DROP CONSTRAINT IF EXISTS emp_emp_image_id_fkey;

ALTER TABLE public.emp ENABLE TRIGGER ALL;

COMMENT ON TABLE emp IS 'Employee table describing the basic properties of an employee. Employees need not be system users.';

COMMENT ON COLUMN emp.emp_code IS 'Short, human-readable name for employee. This value is kept synchronized with usr_username and salesrep_number, and so is unique across all three tables emp, usr, and salesrep.';
COMMENT ON COLUMN emp.emp_number IS 'Official employee number. This might be used for ID badges, payroll accounting, or other purposes.';
COMMENT ON COLUMN emp.emp_mgr_emp_id IS $$Internal ID of this employee's manager/supervisor.$$;
COMMENT ON COLUMN emp.emp_wage_type IS $$The nature of the wage or employment agreement. 'H' indicates this employee is paid on an hourly basis (or some other period) while 'S' indicates this employee is salaried.$$;
COMMENT ON COLUMN emp.emp_wage_period IS $$The periodicity of wage payment: 'H' for hourly, 'D' for daily, 'W' for weekly, 'BW' for biweekly, 'M' for monthly, 'Y' for yearly.$$;
COMMENT ON COLUMN emp.emp_username IS 'DEPRECATED - the relationship between Employee and User is now maintained through the crmacct table.';
COMMENT ON COLUMN emp.emp_extrate_period IS $$The periodicity of external rate payment: 'H' for hourly, 'D' for daily, 'W' for weekly, 'BW' for biweekly, 'M' for monthly, 'Y' for yearly.$$;
