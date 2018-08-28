SELECT xt.create_table('ipsass', 'public');

ALTER TABLE public.ipsass DISABLE TRIGGER ALL;

SELECT
  xt.add_column('ipsass', 'ipsass_id',             'SERIAL', 'NOT NULL',   'public'),
  xt.add_column('ipsass', 'ipsass_ipshead_id',    'INTEGER', 'NOT NULL',   'public'),
  xt.add_column('ipsass', 'ipsass_cust_id',       'INTEGER', NULL,         'public'),
  xt.add_column('ipsass', 'ipsass_custtype_id',   'INTEGER', NULL,         'public'),
  xt.add_column('ipsass', 'ipsass_custtype_pattern', 'TEXT', NULL,         'public'),
  xt.add_column('ipsass', 'ipsass_shipto_id',     'INTEGER', 'DEFAULT -1', 'public'),
  xt.add_column('ipsass', 'ipsass_shipto_pattern',   'TEXT', NULL,         'public'),
  xt.add_column('ipsass', 'ipsass_shipzone_id',   'INTEGER', NULL,         'public'),
  xt.add_column('ipsass', 'ipsass_saletype_id',   'INTEGER', NULL,         'public');

ALTER TABLE ipsass DROP CONSTRAINT IF EXISTS ipsass_ipsass_ipshead_id_key;

SELECT
  xt.add_constraint('ipsass', 'ipsass_pkey', 'PRIMARY KEY (ipsass_id)', 'public'),
  xt.add_constraint('ipsass', 'ipsass_ipsass_ipshead_id_key',
                    'UNIQUE (ipsass_ipshead_id, ipsass_cust_id,
                             ipsass_custtype_id, ipsass_custtype_pattern,
                             ipsass_shipto_id, ipsass_shipto_pattern,
                             ipsass_shipzone_id, ipsass_saletype_id)', 'public'),
  xt.add_constraint('ipsass', 'ipsass_ipsass_ipshead_id_fkey',
                    'FOREIGN KEY (ipsass_ipshead_id) REFERENCES ipshead(ipshead_id)', 'public'),
  xt.add_constraint('ipsass', 'ipsass_ipsass_shipzone_id_fkey',
                    'FOREIGN KEY (ipsass_shipzone_id) REFERENCES shipzone (shipzone_id)
                     ON UPDATE NO ACTION ON DELETE CASCADE', 'public'),
  xt.add_constraint('ipsass', 'ipsass_ipsass_saletype_id_fkey',
                    'FOREIGN KEY (ipsass_saletype_id) REFERENCES saletype (saletype_id)
                     ON UPDATE NO ACTION ON DELETE CASCADE', 'public');

ALTER TABLE public.ipsass ENABLE TRIGGER ALL;

COMMENT ON TABLE ipsass IS 'Pricing Schedule assignment information';
