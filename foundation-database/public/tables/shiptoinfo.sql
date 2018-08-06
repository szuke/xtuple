SELECT xt.create_table('shiptoinfo', 'public');

ALTER TABLE public.shiptoinfo DISABLE TRIGGER ALL;

SELECT
  xt.add_column('shiptoinfo', 'shipto_id',                     'SERIAL', 'NOT NULL', 'public'),
  xt.add_column('shiptoinfo', 'shipto_cust_id',               'INTEGER', 'NOT NULL', 'public'),
  xt.add_column('shiptoinfo', 'shipto_name',                     'TEXT', NULL, 'public'),
  xt.add_column('shiptoinfo', 'shipto_salesrep_id',           'INTEGER', NULL, 'public'),
  xt.add_column('shiptoinfo', 'shipto_comments',                 'TEXT', NULL, 'public'),
  xt.add_column('shiptoinfo', 'shipto_shipcomments',             'TEXT', NULL, 'public'),
  xt.add_column('shiptoinfo', 'shipto_shipzone_id',           'INTEGER', NULL, 'public'),
  xt.add_column('shiptoinfo', 'shipto_shipvia',                  'TEXT', NULL, 'public'),
  xt.add_column('shiptoinfo', 'shipto_commission',      'NUMERIC(10,4)', 'NOT NULL', 'public'),
  xt.add_column('shiptoinfo', 'shipto_shipform_id',           'INTEGER', NULL, 'public'),
  xt.add_column('shiptoinfo', 'shipto_shipchrg_id',           'INTEGER', NULL, 'public'),
  xt.add_column('shiptoinfo', 'shipto_active',                'BOOLEAN', 'NOT NULL', 'public'),
  xt.add_column('shiptoinfo', 'shipto_default',               'BOOLEAN', NULL, 'public'),
  xt.add_column('shiptoinfo', 'shipto_num',                      'TEXT', NULL, 'public'),
  xt.add_column('shiptoinfo', 'shipto_ediprofile_id',         'INTEGER', NULL, 'public'),
  xt.add_column('shiptoinfo', 'shipto_cntct_id',              'INTEGER', NULL, 'public'),
  xt.add_column('shiptoinfo', 'shipto_addr_id',               'INTEGER', NULL, 'public'),
  xt.add_column('shiptoinfo', 'shipto_taxzone_id',            'INTEGER', NULL, 'public'),
  xt.add_column('shiptoinfo', 'shipto_preferred_warehous_id', 'INTEGER', 'DEFAULT -1 NOT NULL', 'public'),
  xt.add_column('shiptoinfo', 'shipto_created',      'TIMESTAMP WITH TIME ZONE', NULL, 'public'),
  xt.add_column('shiptoinfo', 'shipto_lastupdated',  'TIMESTAMP WITH TIME ZONE', NULL, 'public');

SELECT
  xt.add_constraint('shiptoinfo', 'shipto_pkey', 'PRIMARY KEY (shipto_id)', 'public'),
  xt.add_constraint('shiptoinfo', 'shipto_num_cust_unique',
                    'UNIQUE (shipto_cust_id, shipto_num)', 'public'),
  xt.add_constraint('shiptoinfo', 'shiptoinfo_shipto_addr_id_fkey',
                    'FOREIGN KEY (shipto_addr_id) REFERENCES addr(addr_id)', 'public'),
  xt.add_constraint('shiptoinfo', 'shiptoinfo_shipto_cntct_id_fkey',
                    'FOREIGN KEY (shipto_cntct_id) REFERENCES cntct(cntct_id)', 'public'),
  xt.add_constraint('shiptoinfo', 'shiptoinfo_shipto_cust_id_fkey',
                    'FOREIGN KEY (shipto_cust_id) REFERENCES custinfo(cust_id)', 'public'),
  xt.add_constraint('shiptoinfo', 'shiptoinfo_shipto_salesrep_fkey',
                    'FOREIGN KEY (shipto_salesrep_id) REFERENCES salesrep(salesrep_id)
                     ON UPDATE RESTRICT ON DELETE RESTRICT', 'public'),
  xt.add_constraint('shiptoinfo', 'shiptoinfo_shipto_salesrep_id_fkey',
                    'FOREIGN KEY (shipto_salesrep_id) REFERENCES salesrep(salesrep_id)', 'public'),
  xt.add_constraint('shiptoinfo', 'shiptoinfo_shipto_shipform_fkey',
                    'FOREIGN KEY (shipto_shipform_id) REFERENCES shipform(shipform_id)
                     ON UPDATE RESTRICT ON DELETE RESTRICT', 'public'),
  xt.add_constraint('shiptoinfo', 'shiptoinfo_shipto_shipform_id_fkey',
                    'FOREIGN KEY (shipto_shipform_id) REFERENCES shipform(shipform_id)', 'public'),
  xt.add_constraint('shiptoinfo', 'shiptoinfo_shipto_shipzone_id_fkey',
                    'FOREIGN KEY (shipto_shipzone_id) REFERENCES shipzone(shipzone_id)', 'public'),
  xt.add_constraint('shiptoinfo', 'shiptoinfo_shipto_taxzone_id_fkey',
                    'FOREIGN KEY (shipto_taxzone_id) REFERENCES taxzone(taxzone_id)', 'public');

ALTER TABLE public.shiptoinfo ENABLE TRIGGER ALL;

COMMENT ON TABLE shiptoinfo IS 'Ship-To information';

COMMENT ON COLUMN shiptoinfo.shipto_ediprofile_id IS 'Deprecated column - DO NOT USE';
