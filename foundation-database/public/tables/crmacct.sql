SELECT xt.create_table('crmacct', 'public');

ALTER TABLE public.crmacct DISABLE TRIGGER ALL;

SELECT
  xt.add_column('crmacct', 'crmacct_id',             'SERIAL', 'NOT NULL',     'public'),
  xt.add_column('crmacct', 'crmacct_number',           'TEXT', 'NOT NULL',     'public'),
  xt.add_column('crmacct', 'crmacct_name',             'TEXT', NULL,           'public'),
  xt.add_column('crmacct', 'crmacct_active',        'BOOLEAN', 'DEFAULT true', 'public'),
  xt.add_column('crmacct', 'crmacct_type',     'CHARACTER(1)', NULL,      'public'),
  xt.add_column('crmacct', 'crmacct_cust_id',       'INTEGER', NULL,      'public'),
  xt.add_column('crmacct', 'crmacct_competitor_id', 'INTEGER', NULL,      'public'),
  xt.add_column('crmacct', 'crmacct_partner_id',    'INTEGER', NULL,      'public'),
  xt.add_column('crmacct', 'crmacct_prospect_id',   'INTEGER', NULL,      'public'),
  xt.add_column('crmacct', 'crmacct_vend_id',       'INTEGER', NULL,      'public'),
  xt.add_column('crmacct', 'crmacct_cntct_id_1',    'INTEGER', NULL,      'public'),
  xt.add_column('crmacct', 'crmacct_cntct_id_2',    'INTEGER', NULL,      'public'),
  xt.add_column('crmacct', 'crmacct_parent_id',     'INTEGER', NULL,      'public'),
  xt.add_column('crmacct', 'crmacct_notes',            'TEXT', NULL,      'public'),
  xt.add_column('crmacct', 'crmacct_taxauth_id',    'INTEGER', NULL,      'public'),
  xt.add_column('crmacct', 'crmacct_owner_username',   'TEXT', NULL,      'public'),
  xt.add_column('crmacct', 'crmacct_emp_id',        'INTEGER', NULL,      'public'),
  xt.add_column('crmacct', 'crmacct_salesrep_id',   'INTEGER', NULL,      'public'),
  xt.add_column('crmacct', 'crmacct_usr_username',     'TEXT', NULL,      'public'),
  xt.add_column('crmacct', 'crmacct_created',     'TIMESTAMP WITH TIME ZONE', NULL, 'public'),
  xt.add_column('crmacct', 'crmacct_lastupdated', 'TIMESTAMP WITH TIME ZONE', NULL, 'public');

SELECT
  xt.add_constraint('crmacct', 'crmacct_pkey', 'PRIMARY KEY (crmacct_id)', 'public'),
  xt.add_constraint('crmacct', 'crmacct_crmacct_number_key', 'UNIQUE (crmacct_number)', 'public'),
  xt.add_constraint('crmacct', 'crmacct_crmacct_number_check',
                    $$CHECK (crmacct_number <> '')$$, 'public'),
  xt.add_constraint('crmacct', 'crmacct_crmacct_type_check',
                    $$CHECK (crmacct_type IN ('I', 'O'))$$, 'public'),
  xt.add_constraint('crmacct', 'crmacct_crmacct_usr_username_check',
                    $$CHECK (btrim(crmacct_usr_username) <> '')$$, 'public'),
  xt.add_constraint('crmacct', 'crmacct_owner_username_check',
                    $$CHECK (btrim(crmacct_owner_username) <> '')$$, 'public'),
  xt.add_constraint('crmacct', 'crmacct_crmacct_cntct_id_1_fkey',
                    'FOREIGN KEY (crmacct_cntct_id_1) REFERENCES cntct(cntct_id)', 'public'),
  xt.add_constraint('crmacct', 'crmacct_crmacct_cntct_id_2_fkey',
                    'FOREIGN KEY (crmacct_cntct_id_2) REFERENCES cntct(cntct_id)', 'public'),
  xt.add_constraint('crmacct', 'crmacct_crmacct_cust_id_fkey',
                    'FOREIGN KEY (crmacct_cust_id) REFERENCES custinfo(cust_id)', 'public'),
  xt.add_constraint('crmacct', 'crmacct_crmacct_emp_id_fkey',
                    'FOREIGN KEY (crmacct_emp_id) REFERENCES emp(emp_id)', 'public'),
  xt.add_constraint('crmacct', 'crmacct_crmacct_parent_id_fkey',
                    'FOREIGN KEY (crmacct_parent_id) REFERENCES crmacct(crmacct_id)', 'public'),
  xt.add_constraint('crmacct', 'crmacct_crmacct_prospect_id_fkey',
                    'FOREIGN KEY (crmacct_prospect_id) REFERENCES prospect(prospect_id)', 'public'),
  xt.add_constraint('crmacct', 'crmacct_crmacct_salesrep_id_fkey',
                    'FOREIGN KEY (crmacct_salesrep_id) REFERENCES salesrep(salesrep_id)', 'public'),
  xt.add_constraint('crmacct', 'crmacct_crmacct_taxauth_id_fkey',
                    'FOREIGN KEY (crmacct_taxauth_id) REFERENCES taxauth(taxauth_id)', 'public'),
  xt.add_constraint('crmacct', 'crmacct_crmacct_vend_id_fkey',
                    'FOREIGN KEY (crmacct_vend_id) REFERENCES vendinfo(vend_id)', 'public');

ALTER TABLE public.crmacct ENABLE TRIGGER ALL;

COMMENT ON TABLE crmacct IS 'CRM Accounts are umbrella records that tie together people and organizations with whom we have business relationships.';

COMMENT ON COLUMN crmacct.crmacct_id IS 'Internal ID of this CRM Account.';
COMMENT ON COLUMN crmacct.crmacct_number IS 'Abbreviated human-readable identifier for this CRM Account.';
COMMENT ON COLUMN crmacct.crmacct_name IS 'Long name of this CRM Account.';
COMMENT ON COLUMN crmacct.crmacct_active IS 'This CRM Account is available for new activity.';
COMMENT ON COLUMN crmacct.crmacct_type IS 'This indicates whether the CRM Account represents an organization or an individual person.';
COMMENT ON COLUMN crmacct.crmacct_cust_id IS 'If this is not null, this CRM Account is a Customer.';
COMMENT ON COLUMN crmacct.crmacct_competitor_id IS 'For now, > 0 indicates this CRM Account is a competitor. Eventually this may become a foreign key to a table of competitors.';
COMMENT ON COLUMN crmacct.crmacct_partner_id IS 'For now, > 0 indicates this CRM Account is a partner. Eventually this may become a foreign key to a table of partners.';
COMMENT ON COLUMN crmacct.crmacct_prospect_id IS 'If this is not null, this CRM Account is a Prospect.';
COMMENT ON COLUMN crmacct.crmacct_vend_id IS 'If this is not null, this CRM Account is a Vendor.';
COMMENT ON COLUMN crmacct.crmacct_cntct_id_1 IS 'The primary contact for the CRM Account.';
COMMENT ON COLUMN crmacct.crmacct_cntct_id_2 IS 'The secondary contact for the CRM Account.';
COMMENT ON COLUMN crmacct.crmacct_parent_id IS 'The internal ID of an (optional) parent CRM Account. For example, if the current CRM Account is a subsidiary of another company, the crmacct_parent_id points to the CRM Account representing that parent company.';
COMMENT ON COLUMN crmacct.crmacct_notes IS 'Free-form comments pertaining to the CRM Account.';
COMMENT ON COLUMN crmacct.crmacct_taxauth_id IS 'If this is not null, this CRM Account is a Tax Authority.';
COMMENT ON COLUMN crmacct.crmacct_owner_username IS 'The application User responsible for this CRM Account.';
COMMENT ON COLUMN crmacct.crmacct_emp_id IS 'If this is not null, this CRM Account is an Employee.';
COMMENT ON COLUMN crmacct.crmacct_salesrep_id IS 'If this is not null, this CRM Account is a Sales Rep.';
COMMENT ON COLUMN crmacct.crmacct_usr_username IS 'If this is not null, this CRM Account is an application User.';
