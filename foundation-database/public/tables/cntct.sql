SELECT xt.create_table('cntct', 'public');

ALTER TABLE public.cntct DISABLE TRIGGER ALL;

SELECT
  xt.add_column('cntct', 'cntct_id',           'SERIAL', 'NOT NULL', 'public'),
  xt.add_column('cntct', 'cntct_crmacct_id',  'INTEGER', NULL,       'public'),
  xt.add_column('cntct', 'cntct_addr_id',     'INTEGER', NULL,       'public'),
  xt.add_column('cntct', 'cntct_first_name',     'TEXT', NULL,       'public'),
  xt.add_column('cntct', 'cntct_last_name',      'TEXT', NULL,       'public'),
  xt.add_column('cntct', 'cntct_honorific',      'TEXT', NULL,       'public'),
  xt.add_column('cntct', 'cntct_initials',       'TEXT', NULL,       'public'),
  xt.add_column('cntct', 'cntct_active',      'BOOLEAN', 'DEFAULT true', 'public'),
  xt.add_column('cntct', 'cntct_phone',          'TEXT', NULL,       'public'),
  xt.add_column('cntct', 'cntct_phone2',         'TEXT', NULL,       'public'),
  xt.add_column('cntct', 'cntct_fax',            'TEXT', NULL,       'public'),
  xt.add_column('cntct', 'cntct_email',          'TEXT', NULL,       'public'),
  xt.add_column('cntct', 'cntct_webaddr',        'TEXT', NULL,       'public'),
  xt.add_column('cntct', 'cntct_notes',          'TEXT', NULL,       'public'),
  xt.add_column('cntct', 'cntct_title',          'TEXT', NULL,       'public'),
  xt.add_column('cntct', 'cntct_number',         'TEXT', 'NOT NULL', 'public'),
  xt.add_column('cntct', 'cntct_middle',         'TEXT', NULL,       'public'),
  xt.add_column('cntct', 'cntct_suffix',         'TEXT', NULL,       'public'),
  xt.add_column('cntct', 'cntct_owner_username', 'TEXT', NULL,       'public'),
  xt.add_column('cntct', 'cntct_name',           'TEXT', NULL,       'public'),
  xt.add_column('cntct', 'cntct_created',      'TIMESTAMP WITH TIME ZONE', NULL, 'public'),
  xt.add_column('cntct', 'cntct_lastupdated',  'TIMESTAMP WITH TIME ZONE', NULL, 'public');

SELECT
  xt.add_constraint('cntct', 'cntct_pkey', 'PRIMARY KEY (cntct_id)', 'public'),
  xt.add_constraint('cntct', 'cntct_cntct_number_key', 'UNIQUE (cntct_number)', 'public'),
  xt.add_constraint('cntct', 'cntct_cntct_addr_id_fkey',
                    'FOREIGN KEY (cntct_addr_id) REFERENCES addr(addr_id)', 'public'),
  xt.add_constraint('cntct', 'cntct_cntct_crmacct_id_fkey',
                    'FOREIGN KEY (cntct_crmacct_id) REFERENCES crmacct(crmacct_id)', 'public');

ALTER TABLE public.cntct ENABLE TRIGGER ALL;

COMMENT ON TABLE cntct IS 'Contact - information on how to reach a living person';
