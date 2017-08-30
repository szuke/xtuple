SELECT xt.create_table('prj', 'public');

ALTER TABLE public.prj DISABLE TRIGGER ALL;

SELECT
  xt.add_column('prj', 'prj_id',                'SERIAL', 'NOT NULL', 'public'),
  xt.add_column('prj', 'prj_number',              'TEXT', 'NOT NULL', 'public'),
  xt.add_column('prj', 'prj_name',                'TEXT', 'NOT NULL', 'public'),
  xt.add_column('prj', 'prj_descrip',             'TEXT', NULL, 'public'),
  xt.add_column('prj', 'prj_status',      'CHARACTER(1)', 'NOT NULL', 'public'),
  xt.add_column('prj', 'prj_so',               'BOOLEAN', NULL, 'public'),
  xt.add_column('prj', 'prj_wo',               'BOOLEAN', NULL, 'public'),
  xt.add_column('prj', 'prj_po',               'BOOLEAN', NULL, 'public'),
  xt.add_column('prj', 'prj_owner_username',      'TEXT', NULL, 'public'),
  xt.add_column('prj', 'prj_start_date',          'DATE', NULL, 'public'),
  xt.add_column('prj', 'prj_due_date',            'DATE', NULL, 'public'),
  xt.add_column('prj', 'prj_assigned_date',       'DATE', NULL, 'public'),
  xt.add_column('prj', 'prj_completed_date',      'DATE', NULL, 'public'),
  xt.add_column('prj', 'prj_username',            'TEXT', NULL, 'public'),
  xt.add_column('prj', 'prj_recurring_prj_id', 'INTEGER', NULL, 'public'),
  xt.add_column('prj', 'prj_crmacct_id',       'INTEGER', NULL, 'public'),
  xt.add_column('prj', 'prj_cntct_id',         'INTEGER', NULL, 'public'),
  xt.add_column('prj', 'prj_prjtype_id',       'INTEGER', NULL, 'public'),
  xt.add_column('prj', 'prj_created',     'TIMESTAMP WITH TIME ZONE', NULL, 'public'),
  xt.add_column('prj', 'prj_lastupdated', 'TIMESTAMP WITH TIME ZONE', NULL, 'public'),
  xt.add_column('prj', 'prj_dept_id',      'INTEGER', 'REFERENCES dept (dept_id)', 'public'),
  xt.add_column('prj', 'prj_priority_id',  'INTEGER', 'REFERENCES incdtpriority (incdtpriority_id)', 'public'),
  xt.add_column('prj', 'prj_pct_complete', 'NUMERIC', null, 'public');

SELECT
  xt.add_constraint('prj', 'prj_pkey', 'PRIMARY KEY (prj_id)', 'public'),
  xt.add_constraint('prj', 'prj_prj_number_key', 'UNIQUE (prj_number)', 'public'),
  xt.add_constraint('prj', 'prj_prj_number_check',
                    $$CHECK (prj_number <> '')$$, 'public'),
  xt.add_constraint('prj', 'prj_prj_status_check',
                    $$CHECK (prj_status IN ('P', 'O', 'C'))$$, 'public'),
  xt.add_constraint('prj', 'prj_prj_cntct_id_fkey',
                    'FOREIGN KEY (prj_cntct_id) REFERENCES cntct(cntct_id)', 'public'),
  xt.add_constraint('prj', 'prj_prj_crmacct_id_fkey',
                    'FOREIGN KEY (prj_crmacct_id) REFERENCES crmacct(crmacct_id)', 'public'),
  xt.add_constraint('prj', 'prj_prj_prjtype_id_fkey',
                    'FOREIGN KEY (prj_prjtype_id) REFERENCES prjtype(prjtype_id)', 'public'),
  xt.add_constraint('prj', 'prj_prj_recurring_prj_id_fkey',
                    'FOREIGN KEY (prj_recurring_prj_id) REFERENCES prj(prj_id)', 'public');

ALTER TABLE public.prj ENABLE TRIGGER ALL;

COMMENT ON TABLE prj IS 'Project information';

COMMENT ON COLUMN prj.prj_recurring_prj_id IS 'The first prj record in the series if this is a recurring Project. If the prj_recurring_prj_id is the same as the prj_id, this record is the first in the series.';
COMMENT ON COLUMN prj.prj_dept_id      IS 'Project Department';
COMMENT ON COLUMN prj.prj_priority_id  IS 'Project Priority';
COMMENT ON COLUMN prj.prj_pct_complete IS 'Project Percent Complete';
