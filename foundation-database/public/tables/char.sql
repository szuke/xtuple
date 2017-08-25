SELECT xt.create_table('char', 'public');

ALTER TABLE public."char" DISABLE TRIGGER ALL;

SELECT
  xt.add_column('char', 'char_id',              'SERIAL', 'NOT NULL', 'public'),
  xt.add_column('char', 'char_name',              'TEXT', 'NOT NULL', 'public'),
  xt.add_column('char', 'char_items',          'BOOLEAN', NULL, 'public'),
  xt.add_column('char', 'char_options',        'BOOLEAN', NULL, 'public'),
  xt.add_column('char', 'char_attributes',     'BOOLEAN', NULL, 'public'),
  xt.add_column('char', 'char_lotserial',      'BOOLEAN', NULL, 'public'),
  xt.add_column('char', 'char_notes',             'TEXT', NULL, 'public'),
  xt.add_column('char', 'char_customers',      'BOOLEAN', NULL, 'public'),
  xt.add_column('char', 'char_crmaccounts',    'BOOLEAN', NULL, 'public'),
  xt.add_column('char', 'char_addresses',      'BOOLEAN', NULL, 'public'),
  xt.add_column('char', 'char_contacts',       'BOOLEAN', NULL, 'public'),
  xt.add_column('char', 'char_opportunity',    'BOOLEAN', NULL, 'public'),
  xt.add_column('char', 'char_employees',      'BOOLEAN', 'DEFAULT false', 'public'),
  xt.add_column('char', 'char_mask',              'TEXT', NULL, 'public'),
  xt.add_column('char', 'char_validator',         'TEXT', NULL, 'public'),
  xt.add_column('char', 'char_incidents',      'BOOLEAN', 'DEFAULT false', 'public'),
  xt.add_column('char', 'char_type',           'INTEGER', 'DEFAULT 0 NOT NULL', 'public'),
  xt.add_column('char', 'char_order',          'INTEGER', 'DEFAULT 0 NOT NULL', 'public'),
  xt.add_column('char', 'char_search',         'BOOLEAN', 'DEFAULT true NOT NULL', 'public'),
  xt.add_column('char', 'char_quotes',         'BOOLEAN', 'DEFAULT false', 'public'),
  xt.add_column('char', 'char_salesorders',    'BOOLEAN', 'DEFAULT false', 'public'),
  xt.add_column('char', 'char_invoices',       'BOOLEAN', 'DEFAULT false', 'public'),
  xt.add_column('char', 'char_vendors',        'BOOLEAN', 'DEFAULT false', 'public'),
  xt.add_column('char', 'char_purchaseorders', 'BOOLEAN', 'DEFAULT false', 'public'),
  xt.add_column('char', 'char_vouchers',       'BOOLEAN', 'DEFAULT false', 'public'),
  xt.add_column('char', 'char_projects',       'BOOLEAN', 'DEFAULT false', 'public'),
  xt.add_column('char', 'char_tasks',          'BOOLEAN', 'DEFAULT false', 'public'),
  xt.add_column('char', 'char_unique',         'BOOLEAN', 'DEFAULT false', 'public'),
  xt.add_column('char', 'char_group',             'TEXT', '',              'public');

SELECT
  xt.add_constraint('char', 'char_pkey', 'PRIMARY KEY (char_id)', 'public'),
  xt.add_constraint('char', 'char_char_name_check', $$CHECK (char_name <> '')$$, 'public'),
  xt.add_constraint('char', 'char_char_name_key', 'UNIQUE (char_name)', 'public');

ALTER TABLE public."char" ENABLE TRIGGER ALL;

COMMENT ON TABLE "char" IS 'Characteristic information';

COMMENT ON COLUMN public."char".char_addresses IS 'DEPRECATED - this column has been replaced by a row in the charuse table with target_type ADDR';
COMMENT ON COLUMN public."char".char_contacts IS 'DEPRECATED - this column has been replaced by a row in the charuse table with target_type CNTCT';
COMMENT ON COLUMN public."char".char_crmaccounts IS 'DEPRECATED - this column has been replaced by a row in the charuse table with target_type CRMA';
COMMENT ON COLUMN public."char".char_customers IS 'DEPRECATED - this column has been replaced by rows in the charuse table with target_types C and CT';
COMMENT ON COLUMN public."char".char_employees IS 'DEPRECATED - this column has been replaced by a row in the charuse table with target_type EMP';
COMMENT ON COLUMN public."char".char_incidents IS 'DEPRECATED - this column has been replaced by a row in the charuse table with target_type INCDT';
COMMENT ON COLUMN public."char".char_invoices IS 'DEPRECATED - this column has been replaced by a row in the charuse table with target_type INV';
COMMENT ON COLUMN public."char".char_items IS 'DEPRECATED - this column has been replaced by a row in the charuse table with target_type I';
COMMENT ON COLUMN public."char".char_lotserial IS 'DEPRECATED - this column has been replaced by rows in the charuse table with target_types LS and LSR';
COMMENT ON COLUMN public."char".char_opportunity IS 'DEPRECATED - this column has been replaced by a row in the charuse table with target_type OPP';
COMMENT ON COLUMN public."char".char_projects IS 'DEPRECATED - this column has been replaced by a row in the charuse table with target_type PROJ';
COMMENT ON COLUMN public."char".char_purchaseorders IS 'DEPRECATED - this column has been replaced by a row in the charuse table with target_type PO';
COMMENT ON COLUMN public."char".char_quotes IS 'DEPRECATED - this column has been replaced by a row in the charuse table with target_type QU';
COMMENT ON COLUMN public."char".char_salesorders IS 'DEPRECATED - this column has been replaced by a row in the charuse table with target_type SO';
COMMENT ON COLUMN public."char".char_tasks IS 'DEPRECATED - this column has been replaced by a row in the charuse table with target_type TASK';
COMMENT ON COLUMN public."char".char_vendors IS 'DEPRECATED - this column has been replaced by a row in the charuse table with target_type V';
COMMENT ON COLUMN public."char".char_vouchers IS 'DEPRECATED - this column has been replaced by a row in the charuse table with target_type VCH';

COMMENT ON COLUMN public."char".char_unique IS 'Setting to ensure only one usage of the characteristic per object';
COMMENT ON COLUMN public."char".char_group IS 'Characteristic grouping to sort lists of characteristics into like groups';
