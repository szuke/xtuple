SELECT xt.create_table('whsinfo', 'public');

ALTER TABLE public.whsinfo DISABLE TRIGGER ALL;

SELECT
  xt.add_column('whsinfo', 'warehous_id',                'SERIAL', 'NOT NULL', 'public'),
  xt.add_column('whsinfo', 'warehous_code',                'TEXT', 'NOT NULL', 'public'),
  xt.add_column('whsinfo', 'warehous_descrip',             'TEXT', NULL, 'public'),
  xt.add_column('whsinfo', 'warehous_fob',                 'TEXT', NULL, 'public'),
  xt.add_column('whsinfo', 'warehous_active',           'BOOLEAN', NULL, 'public'),
  xt.add_column('whsinfo', 'warehous_counttag_prefix',     'TEXT', NULL, 'public'),
  xt.add_column('whsinfo', 'warehous_counttag_number',  'INTEGER', NULL, 'public'),
  xt.add_column('whsinfo', 'warehous_bol_prefix',          'TEXT', NULL, 'public'),
  xt.add_column('whsinfo', 'warehous_bol_number',       'INTEGER', NULL, 'public'),
  xt.add_column('whsinfo', 'warehous_shipping',         'BOOLEAN', NULL, 'public'),
  xt.add_column('whsinfo', 'warehous_useslips',         'BOOLEAN', NULL, 'public'),
  xt.add_column('whsinfo', 'warehous_usezones',         'BOOLEAN', NULL, 'public'),
  xt.add_column('whsinfo', 'warehous_aislesize',        'INTEGER', NULL, 'public'),
  xt.add_column('whsinfo', 'warehous_aislealpha',       'BOOLEAN', NULL, 'public'),
  xt.add_column('whsinfo', 'warehous_racksize',         'INTEGER', NULL, 'public'),
  xt.add_column('whsinfo', 'warehous_rackalpha',        'BOOLEAN', NULL, 'public'),
  xt.add_column('whsinfo', 'warehous_binsize',          'INTEGER', NULL, 'public'),
  xt.add_column('whsinfo', 'warehous_binalpha',         'BOOLEAN', NULL, 'public'),
  xt.add_column('whsinfo', 'warehous_locationsize',     'INTEGER', NULL, 'public'),
  xt.add_column('whsinfo', 'warehous_locationalpha',    'BOOLEAN', NULL, 'public'),
  xt.add_column('whsinfo', 'warehous_enforcearbl',      'BOOLEAN', NULL, 'public'),
  xt.add_column('whsinfo', 'warehous_default_accnt_id', 'INTEGER', NULL, 'public'),
  xt.add_column('whsinfo', 'warehous_shipping_commission', 'NUMERIC(8,4)', 'DEFAULT 0.00', 'public'),
  xt.add_column('whsinfo', 'warehous_cntct_id',         'INTEGER', NULL, 'public'),
  xt.add_column('whsinfo', 'warehous_addr_id',          'INTEGER', NULL, 'public'),
  xt.add_column('whsinfo', 'warehous_transit',          'BOOLEAN', 'DEFAULT false NOT NULL', 'public'),
  xt.add_column('whsinfo', 'warehous_shipform_id',      'INTEGER', NULL, 'public'),
  xt.add_column('whsinfo', 'warehous_shipvia_id',       'INTEGER', NULL, 'public'),
  xt.add_column('whsinfo', 'warehous_shipcomments',        'TEXT', NULL, 'public'),
  xt.add_column('whsinfo', 'warehous_costcat_id',       'INTEGER', NULL, 'public'),
  xt.add_column('whsinfo', 'warehous_sitetype_id',      'INTEGER', NULL, 'public'),
  xt.add_column('whsinfo', 'warehous_taxzone_id',       'INTEGER', NULL, 'public'),
  xt.add_column('whsinfo', 'warehous_sequence',         'INTEGER', 'DEFAULT 0 NOT NULL', 'public'),
  xt.add_column('whsinfo', 'warehous_picklist_shipform_id', 'INTEGER', NULL, 'public'),
  xt.add_column('whsinfo', 'warehous_created',     'TIMESTAMP WITH TIME ZONE', NULL, 'public'),
  xt.add_column('whsinfo', 'warehous_lastupdated', 'TIMESTAMP WITH TIME ZONE', NULL, 'public');

SELECT
  xt.add_constraint('whsinfo', 'warehous_pkey', 'PRIMARY KEY (warehous_id)', 'public'),
  xt.add_constraint('whsinfo', 'whsinfo_warehous_code_key',
                    'UNIQUE (warehous_code)', 'public'),
  xt.add_constraint('whsinfo', 'whsinfo_check',
                    'CHECK (((warehous_transit AND (warehous_costcat_id IS NOT NULL)) OR NOT warehous_transit))', 'public'),
  xt.add_constraint('whsinfo', 'whsinfo_warehous_code_check',
                    $$CHECK (warehous_code <> '')$$, 'public'),
  xt.add_constraint('whsinfo', 'whsinfo_warehous_accnt_id_fkey',
                   'FOREIGN KEY (warehous_default_accnt_id) REFERENCES accnt(accnt_id)', 'public'),
  xt.add_constraint('whsinfo', 'whsinfo_warehous_addr_id_fkey',
                   'FOREIGN KEY (warehous_addr_id) REFERENCES addr(addr_id)', 'public'),
  xt.add_constraint('whsinfo', 'whsinfo_warehous_cntct_id_fkey',
                   'FOREIGN KEY (warehous_cntct_id) REFERENCES cntct(cntct_id)', 'public'),
  xt.add_constraint('whsinfo', 'whsinfo_warehous_costcat_id_fkey',
                   'FOREIGN KEY (warehous_costcat_id) REFERENCES costcat(costcat_id)', 'public'),
  xt.add_constraint('whsinfo', 'whsinfo_warehous_shipform_id_fkey',
                   'FOREIGN KEY (warehous_shipform_id) REFERENCES shipform(shipform_id)', 'public'),
  xt.add_constraint('whsinfo', 'whsinfo_warehous_shipvia_id_fkey',
                   'FOREIGN KEY (warehous_shipvia_id) REFERENCES shipvia(shipvia_id)', 'public'),
  xt.add_constraint('whsinfo', 'whsinfo_warehous_sitetype_id_fkey',
                   'FOREIGN KEY (warehous_sitetype_id) REFERENCES sitetype(sitetype_id)', 'public'),
  xt.add_constraint('whsinfo', 'whsinfo_warehous_taxzone_id_fkey',
                   'FOREIGN KEY (warehous_taxzone_id) REFERENCES taxzone(taxzone_id)', 'public'),
  xt.add_constraint('whsinfo','whsinfo_warehous_picklist_shipform_id_fkey',
                    'FOREIGN KEY (warehous_picklist_shipform_id)
                     REFERENCES shipform (shipform_id) MATCH SIMPLE
                     ON UPDATE NO ACTION ON DELETE NO ACTION', 'public');

ALTER TABLE public.whsinfo ENABLE TRIGGER ALL;

COMMENT ON TABLE whsinfo IS 'Warehouse information';
