SELECT xt.create_table('incdt', 'public');

ALTER TABLE public.incdt DISABLE TRIGGER ALL;

SELECT
  xt.add_column('incdt', 'incdt_id',                  'SERIAL', 'NOT NULL', 'public'),
  xt.add_column('incdt', 'incdt_number',             'INTEGER', 'NOT NULL', 'public'),
  xt.add_column('incdt', 'incdt_crmacct_id',         'INTEGER', NULL,       'public'),
  xt.add_column('incdt', 'incdt_cntct_id',           'INTEGER', NULL,       'public'),
  xt.add_column('incdt', 'incdt_summary',               'TEXT', NULL,       'public'),
  xt.add_column('incdt', 'incdt_descrip',               'TEXT', NULL,       'public'),
  xt.add_column('incdt', 'incdt_item_id',            'INTEGER', NULL,       'public'),
  xt.add_column('incdt', 'incdt_timestamp', 'TIMESTAMP WITHOUT TIME ZONE', 'DEFAULT now() NOT NULL', 'public'),
  xt.add_column('incdt', 'incdt_status',        'CHARACTER(1)', $$DEFAULT 'N' NOT NULL$$, 'public'),
  xt.add_column('incdt', 'incdt_assigned_username',     'TEXT', NULL,       'public'),
  xt.add_column('incdt', 'incdt_incdtcat_id',        'INTEGER', NULL,       'public'),
  xt.add_column('incdt', 'incdt_incdtseverity_id',   'INTEGER', NULL,       'public'),
  xt.add_column('incdt', 'incdt_incdtpriority_id',   'INTEGER', NULL,       'public'),
  xt.add_column('incdt', 'incdt_incdtresolution_id', 'INTEGER', NULL,       'public'),
  xt.add_column('incdt', 'incdt_lotserial',             'TEXT', NULL,       'public'),
  xt.add_column('incdt', 'incdt_ls_id',              'INTEGER', NULL,       'public'),
  xt.add_column('incdt', 'incdt_aropen_id',          'INTEGER', NULL,       'public'),
  xt.add_column('incdt', 'incdt_owner_username',        'TEXT', NULL,       'public'),
  xt.add_column('incdt', 'incdt_recurring_incdt_id', 'INTEGER', NULL,       'public'),
  xt.add_column('incdt', 'incdt_updated',   'TIMESTAMP WITHOUT TIME ZONE', 'DEFAULT now() NOT NULL', 'public'),
  xt.add_column('incdt', 'incdt_prj_id',             'INTEGER', NULL,       'public'),
  xt.add_column('incdt', 'incdt_public',             'BOOLEAN', NULL,       'public'),
  xt.add_column('incdt', 'incdt_created',     'TIMESTAMP WITH TIME ZONE', NULL, 'public'),
  xt.add_column('incdt', 'incdt_lastupdated', 'TIMESTAMP WITH TIME ZONE', NULL, 'public');

SELECT
  xt.add_constraint('incdt', 'incdt_pkey', 'PRIMARY KEY (incdt_id)', 'public'),
  xt.add_constraint('incdt', 'incdt_incdt_number_key',
                    'UNIQUE (incdt_number)', 'public'),
  xt.add_constraint('incdt', 'incdt_incdt_aropen_id_fkey',
                    'FOREIGN KEY (incdt_aropen_id) REFERENCES aropen(aropen_id)', 'public'),
  xt.add_constraint('incdt', 'incdt_incdt_cntct_id_fkey',
                    'FOREIGN KEY (incdt_cntct_id) REFERENCES cntct(cntct_id)', 'public'),
  xt.add_constraint('incdt', 'incdt_incdt_crmacct_id_fkey',
                    'FOREIGN KEY (incdt_crmacct_id) REFERENCES crmacct(crmacct_id)', 'public'),
  xt.add_constraint('incdt', 'incdt_incdt_incdtcat_id_fkey',
                    'FOREIGN KEY (incdt_incdtcat_id) REFERENCES incdtcat(incdtcat_id)', 'public'),
  xt.add_constraint('incdt', 'incdt_incdt_incdtpriority_id_fkey',
                    'FOREIGN KEY (incdt_incdtpriority_id) REFERENCES incdtpriority(incdtpriority_id)', 'public'),
  xt.add_constraint('incdt', 'incdt_incdt_incdtresolution_id_fkey',
                    'FOREIGN KEY (incdt_incdtresolution_id) REFERENCES incdtresolution(incdtresolution_id)', 'public'),
  xt.add_constraint('incdt', 'incdt_incdt_incdtseverity_id_fkey',
                    'FOREIGN KEY (incdt_incdtseverity_id) REFERENCES incdtseverity(incdtseverity_id)', 'public'),
  xt.add_constraint('incdt', 'incdt_incdt_item_id_fkey',
                    'FOREIGN KEY (incdt_item_id) REFERENCES item(item_id)', 'public'),
  xt.add_constraint('incdt', 'incdt_incdt_prj_id_fkey',
                    'FOREIGN KEY (incdt_prj_id) REFERENCES prj(prj_id)', 'public'),
  xt.add_constraint('incdt', 'incdt_incdt_recurring_incdt_id_fkey',
                    'FOREIGN KEY (incdt_recurring_incdt_id) REFERENCES incdt(incdt_id)', 'public');

ALTER TABLE public.incdt ENABLE TRIGGER ALL;

COMMENT ON TABLE incdt IS 'Incident table';

COMMENT ON COLUMN incdt.incdt_lotserial IS 'incdt_lotserial is deprecated';
COMMENT ON COLUMN incdt.incdt_recurring_incdt_id IS 'The first incdt record in the series if this is a recurring Incident. If the incdt_recurring_incdt_id is the same as the incdt_id, this record is the first in the series.';
