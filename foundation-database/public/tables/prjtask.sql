SELECT xt.create_table('prjtask', 'public');

ALTER TABLE public.prjtask DISABLE TRIGGER ALL;

SELECT
  xt.add_column('prjtask', 'prjtask_id',                  'SERIAL', 'NOT NULL', 'public'),
  xt.add_column('prjtask', 'prjtask_number',                'TEXT', 'NOT NULL', 'public'),
  xt.add_column('prjtask', 'prjtask_name',                  'TEXT', 'NOT NULL', 'public'),
  xt.add_column('prjtask', 'prjtask_descrip',               'TEXT', NULL,       'public'),
  xt.add_column('prjtask', 'prjtask_prj_id',             'INTEGER', 'NOT NULL', 'public'),
  xt.add_column('prjtask', 'prjtask_anyuser',            'BOOLEAN', NULL,       'public'),
  xt.add_column('prjtask', 'prjtask_status',        'CHARACTER(1)', 'NOT NULL', 'public'),
  xt.add_column('prjtask', 'prjtask_hours_budget', 'NUMERIC(18,6)', 'NOT NULL', 'public'),
  xt.add_column('prjtask', 'prjtask_hours_actual', 'NUMERIC(18,6)', 'NOT NULL', 'public'),
  xt.add_column('prjtask', 'prjtask_exp_budget',   'NUMERIC(16,4)', 'NOT NULL', 'public'),
  xt.add_column('prjtask', 'prjtask_exp_actual',   'NUMERIC(16,4)', 'NOT NULL', 'public'),
  xt.add_column('prjtask', 'prjtask_owner_username',        'TEXT', NULL,       'public'),
  xt.add_column('prjtask', 'prjtask_start_date',            'DATE', NULL,       'public'),
  xt.add_column('prjtask', 'prjtask_due_date',              'DATE', NULL,       'public'),
  xt.add_column('prjtask', 'prjtask_assigned_date',         'DATE', NULL,       'public'),
  xt.add_column('prjtask', 'prjtask_completed_date',        'DATE', NULL,       'public'),
  xt.add_column('prjtask', 'prjtask_username',              'TEXT', NULL,       'public'),
  xt.add_column('prjtask', 'prjtask_pct_complete',       'NUMERIC', NULL,       'public'),
  xt.add_column('prjtask', 'prjtask_created',      'TIMESTAMP WITH TIME ZONE', NULL, 'public'),
  xt.add_column('prjtask', 'prjtask_lastupdated',  'TIMESTAMP WITH TIME ZONE', NULL, 'public'),
  xt.add_column('prjtask', 'prjtask_priority_id',  'INTEGER', 'REFERENCES incdtpriority (incdtpriority_id)', 'public');

SELECT
  xt.add_constraint('prjtask', 'prjtask_pkey', 'PRIMARY KEY (prjtask_id)', 'public'),
  xt.add_constraint('prjtask', 'prjtask_prjtask_prj_id_key',
                    'UNIQUE (prjtask_prj_id, prjtask_number)', 'public'),
  xt.add_constraint('prjtask', 'prjtask_prjtask_status_check',
                    $$CHECK (prjtask_status IN ('P', 'O', 'C'))$$, 'public'),
  xt.add_constraint('prjtask', 'prjtask_prjtask_prj_id_fkey',
                    'FOREIGN KEY (prjtask_prj_id) REFERENCES prj(prj_id)', 'public');

ALTER TABLE public.prjtask ENABLE TRIGGER ALL;

COMMENT ON TABLE prjtask IS 'Project Task information';

COMMENT ON COLUMN prjtask.prjtask_priority_id   IS 'Project Task Priority';
COMMENT ON COLUMN prjtask.prjtask_pct_complete  IS 'Project Task Percent Complete';
