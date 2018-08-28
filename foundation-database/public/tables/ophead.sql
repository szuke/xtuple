SELECT xt.create_table('ophead', 'public');

ALTER TABLE public.ophead DISABLE TRIGGER ALL;

SELECT
  xt.add_column('ophead', 'ophead_id',                 'SERIAL', 'NOT NULL', 'public'),
  xt.add_column('ophead', 'ophead_name',                 'TEXT', 'NOT NULL', 'public'),
  xt.add_column('ophead', 'ophead_crmacct_id',        'INTEGER', NULL, 'public'),
  xt.add_column('ophead', 'ophead_owner_username',       'TEXT', NULL, 'public'),
  xt.add_column('ophead', 'ophead_opstage_id',        'INTEGER', NULL, 'public'),
  xt.add_column('ophead', 'ophead_opsource_id',       'INTEGER', NULL, 'public'),
  xt.add_column('ophead', 'ophead_optype_id',         'INTEGER', NULL, 'public'),
  xt.add_column('ophead', 'ophead_probability_prcnt', 'INTEGER', NULL, 'public'),
  xt.add_column('ophead', 'ophead_amount',      'NUMERIC(20,4)', NULL, 'public'),
  xt.add_column('ophead', 'ophead_target_date',          'DATE', NULL, 'public'),
  xt.add_column('ophead', 'ophead_actual_date',          'DATE', NULL, 'public'),
  xt.add_column('ophead', 'ophead_notes',                'TEXT', NULL, 'public'),
  xt.add_column('ophead', 'ophead_curr_id',           'INTEGER', NULL, 'public'),
  xt.add_column('ophead', 'ophead_active',            'BOOLEAN', 'DEFAULT true', 'public'),
  xt.add_column('ophead', 'ophead_cntct_id',          'INTEGER', NULL, 'public'),
  xt.add_column('ophead', 'ophead_username',             'TEXT', NULL, 'public'),
  xt.add_column('ophead', 'ophead_start_date',           'DATE', NULL, 'public'),
  xt.add_column('ophead', 'ophead_assigned_date',        'DATE', NULL, 'public'),
  xt.add_column('ophead', 'ophead_priority_id',       'INTEGER', NULL, 'public'),
  xt.add_column('ophead', 'ophead_number',               'TEXT', 'NOT NULL', 'public'),
  xt.add_column('ophead', 'ophead_created',     'TIMESTAMP WITH TIME ZONE', NULL, 'public'),
  xt.add_column('ophead', 'ophead_lastupdated', 'TIMESTAMP WITH TIME ZONE', NULL, 'public');

SELECT
  xt.add_constraint('ophead', 'ophead_pkey', 'PRIMARY KEY (ophead_id)', 'public'),
  xt.add_constraint('ophead', 'ophead_ophead_number_key',
                    'UNIQUE (ophead_number)', 'public'),
  xt.add_constraint('ophead', 'ophead_ophead_number_check',
                    $$CHECK (ophead_number <> '')$$, 'public'),
  xt.add_constraint('ophead', 'ophead_ophead_cntct_id_fkey',
                    'FOREIGN KEY (ophead_cntct_id) REFERENCES cntct(cntct_id)', 'public'),
  xt.add_constraint('ophead', 'ophead_ophead_crmacct_id_fkey',
                    'FOREIGN KEY (ophead_crmacct_id) REFERENCES crmacct(crmacct_id)', 'public'),
  xt.add_constraint('ophead', 'ophead_ophead_opsource_id_fkey',
                    'FOREIGN KEY (ophead_opsource_id) REFERENCES opsource(opsource_id)', 'public'),
  xt.add_constraint('ophead', 'ophead_ophead_opstage_id_fkey',
                    'FOREIGN KEY (ophead_opstage_id) REFERENCES opstage(opstage_id)', 'public'),
  xt.add_constraint('ophead', 'ophead_ophead_optype_id_fkey',
                    'FOREIGN KEY (ophead_optype_id) REFERENCES optype(optype_id)', 'public'),
  xt.add_constraint('ophead', 'ophead_ophead_priority_id_fkey',
                    'FOREIGN KEY (ophead_priority_id) REFERENCES incdtpriority(incdtpriority_id)', 'public');

ALTER TABLE public.ophead ENABLE TRIGGER ALL;

COMMENT ON TABLE ophead IS 'Opportunity header.';
