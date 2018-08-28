SELECT xt.create_table('pohead', 'public');

ALTER TABLE public.pohead DISABLE TRIGGER ALL;

SELECT
  xt.add_column('pohead', 'pohead_id',                    'SERIAL', 'NOT NULL', 'public'),
  xt.add_column('pohead', 'pohead_status',          'CHARACTER(1)', NULL, 'public'),
  xt.add_column('pohead', 'pohead_number',                  'TEXT', 'NOT NULL', 'public'),
  xt.add_column('pohead', 'pohead_orderdate',               'DATE', NULL, 'public'),
  xt.add_column('pohead', 'pohead_vend_id',              'INTEGER', NULL, 'public'),
  xt.add_column('pohead', 'pohead_fob',                     'TEXT', NULL, 'public'),
  xt.add_column('pohead', 'pohead_shipvia',                 'TEXT', NULL, 'public'),
  xt.add_column('pohead', 'pohead_comments',                'TEXT', NULL, 'public'),
  xt.add_column('pohead', 'pohead_freight',        'NUMERIC(16,2)', 'DEFAULT 0', 'public'),
  xt.add_column('pohead', 'pohead_printed',              'BOOLEAN', 'DEFAULT false', 'public'),
  xt.add_column('pohead', 'pohead_terms_id',             'INTEGER', NULL, 'public'),
  xt.add_column('pohead', 'pohead_warehous_id',          'INTEGER', NULL, 'public'),
  xt.add_column('pohead', 'pohead_vendaddr_id',          'INTEGER', NULL, 'public'),
  xt.add_column('pohead', 'pohead_agent_username',          'TEXT', NULL, 'public'),
  xt.add_column('pohead', 'pohead_curr_id',              'INTEGER', 'DEFAULT basecurrid()', 'public'),
  xt.add_column('pohead', 'pohead_saved',                'BOOLEAN', 'DEFAULT true NOT NULL', 'public'),
  xt.add_column('pohead', 'pohead_taxzone_id',           'INTEGER', NULL, 'public'),
  xt.add_column('pohead', 'pohead_taxtype_id',           'INTEGER', NULL, 'public'),
  xt.add_column('pohead', 'pohead_dropship',             'BOOLEAN', 'DEFAULT false', 'public'),
  xt.add_column('pohead', 'pohead_vend_cntct_id',        'INTEGER', NULL, 'public'),
  xt.add_column('pohead', 'pohead_vend_cntct_honorific',    'TEXT', NULL, 'public'),
  xt.add_column('pohead', 'pohead_vend_cntct_first_name',   'TEXT', NULL, 'public'),
  xt.add_column('pohead', 'pohead_vend_cntct_middle',       'TEXT', NULL, 'public'),
  xt.add_column('pohead', 'pohead_vend_cntct_last_name',    'TEXT', NULL, 'public'),
  xt.add_column('pohead', 'pohead_vend_cntct_suffix',       'TEXT', NULL, 'public'),
  xt.add_column('pohead', 'pohead_vend_cntct_phone',        'TEXT', NULL, 'public'),
  xt.add_column('pohead', 'pohead_vend_cntct_title',        'TEXT', NULL, 'public'),
  xt.add_column('pohead', 'pohead_vend_cntct_fax',          'TEXT', NULL, 'public'),
  xt.add_column('pohead', 'pohead_vend_cntct_email',        'TEXT', NULL, 'public'),
  xt.add_column('pohead', 'pohead_vendaddress1',            'TEXT', NULL, 'public'),
  xt.add_column('pohead', 'pohead_vendaddress2',            'TEXT', NULL, 'public'),
  xt.add_column('pohead', 'pohead_vendaddress3',            'TEXT', NULL, 'public'),
  xt.add_column('pohead', 'pohead_vendcity',                'TEXT', NULL, 'public'),
  xt.add_column('pohead', 'pohead_vendstate',               'TEXT', NULL, 'public'),
  xt.add_column('pohead', 'pohead_vendzipcode',             'TEXT', NULL, 'public'),
  xt.add_column('pohead', 'pohead_vendcountry',             'TEXT', NULL, 'public'),
  xt.add_column('pohead', 'pohead_shipto_cntct_id',      'INTEGER', NULL, 'public'),
  xt.add_column('pohead', 'pohead_shipto_cntct_honorific',  'TEXT', NULL, 'public'),
  xt.add_column('pohead', 'pohead_shipto_cntct_first_name', 'TEXT', NULL, 'public'),
  xt.add_column('pohead', 'pohead_shipto_cntct_middle',     'TEXT', NULL, 'public'),
  xt.add_column('pohead', 'pohead_shipto_cntct_last_name',  'TEXT', NULL, 'public'),
  xt.add_column('pohead', 'pohead_shipto_cntct_suffix',     'TEXT', NULL, 'public'),
  xt.add_column('pohead', 'pohead_shipto_cntct_phone',      'TEXT', NULL, 'public'),
  xt.add_column('pohead', 'pohead_shipto_cntct_title',      'TEXT', NULL, 'public'),
  xt.add_column('pohead', 'pohead_shipto_cntct_fax',        'TEXT', NULL, 'public'),
  xt.add_column('pohead', 'pohead_shipto_cntct_email',      'TEXT', NULL, 'public'),
  xt.add_column('pohead', 'pohead_shiptoaddress_id',     'INTEGER', NULL, 'public'),
  xt.add_column('pohead', 'pohead_shiptoaddress1',          'TEXT', NULL, 'public'),
  xt.add_column('pohead', 'pohead_shiptoaddress2',          'TEXT', NULL, 'public'),
  xt.add_column('pohead', 'pohead_shiptoaddress3',          'TEXT', NULL, 'public'),
  xt.add_column('pohead', 'pohead_shiptocity',              'TEXT', NULL, 'public'),
  xt.add_column('pohead', 'pohead_shiptostate',             'TEXT', NULL, 'public'),
  xt.add_column('pohead', 'pohead_shiptozipcode',           'TEXT', NULL, 'public'),
  xt.add_column('pohead', 'pohead_shiptocountry',           'TEXT', NULL, 'public'),
  xt.add_column('pohead', 'pohead_cohead_id',            'INTEGER', NULL, 'public'),
  xt.add_column('pohead', 'pohead_released',                'DATE', NULL, 'public'),
  xt.add_column('pohead', 'pohead_shiptoname',              'TEXT', NULL, 'public'),
  xt.add_column('pohead', 'pohead_potype_id',            'INTEGER', NULL, 'public'),
  xt.add_column('pohead', 'pohead_created',     'TIMESTAMP WITH TIME ZONE', NULL, 'public'),
  xt.add_column('pohead', 'pohead_lastupdated', 'TIMESTAMP WITH TIME ZONE', NULL, 'public');

SELECT
  xt.add_constraint('pohead', 'pohead_pkey', 'PRIMARY KEY (pohead_id)', 'public'),
  xt.add_constraint('pohead', 'pohead_pohead_number_key',
                    'UNIQUE (pohead_number)', 'public'),
  xt.add_constraint('pohead', 'pohead_pohead_number_check',
                    $$CHECK (pohead_number <> '')$$, 'public'),
  xt.add_constraint('pohead', 'pohead_pohead_status_check',
                    $$CHECK (pohead_status IN ('U', 'O', 'C'))$$, 'public'),
  xt.add_constraint('pohead', 'pohead_pohead_cohead_id_fkey',
                   'FOREIGN KEY (pohead_cohead_id) REFERENCES cohead(cohead_id) ON DELETE SET NULL', 'public'),
  xt.add_constraint('pohead', 'pohead_pohead_shipto_cntct_id_fkey',
                   'FOREIGN KEY (pohead_shipto_cntct_id) REFERENCES cntct(cntct_id)', 'public'),
  xt.add_constraint('pohead', 'pohead_pohead_shiptoddress_id_fkey',
                   'FOREIGN KEY (pohead_shiptoaddress_id) REFERENCES addr(addr_id)', 'public'),
  xt.add_constraint('pohead', 'pohead_pohead_taxtype_id_fkey',
                   'FOREIGN KEY (pohead_taxtype_id) REFERENCES taxtype(taxtype_id)', 'public'),
  xt.add_constraint('pohead', 'pohead_pohead_taxzone_id_fkey',
                   'FOREIGN KEY (pohead_taxzone_id) REFERENCES taxzone(taxzone_id)', 'public'),
  xt.add_constraint('pohead', 'pohead_pohead_terms_id_fkey',
                   'FOREIGN KEY (pohead_terms_id) REFERENCES terms(terms_id)', 'public'),
  xt.add_constraint('pohead', 'pohead_pohead_vend_cntct_id_fkey',
                   'FOREIGN KEY (pohead_vend_cntct_id) REFERENCES cntct(cntct_id)', 'public'),
  xt.add_constraint('pohead', 'pohead_pohead_vend_id_fkey',
                   'FOREIGN KEY (pohead_vend_id) REFERENCES vendinfo(vend_id)', 'public'),
  xt.add_constraint('pohead', 'pohead_pohead_vendaddr_id_fkey',
                   'FOREIGN KEY (pohead_vendaddr_id) REFERENCES vendaddrinfo(vendaddr_id)', 'public'),
  xt.add_constraint('pohead', 'pohead_pohead_warehous_id_fkey',
                   'FOREIGN KEY (pohead_warehous_id) REFERENCES whsinfo(warehous_id)', 'public'),
  xt.add_constraint('pohead', 'pohead_to_curr_symbol',
                   'FOREIGN KEY (pohead_curr_id) REFERENCES curr_symbol(curr_id)', 'public'),
  xt.add_constraint('pohead', 'pohead_potype_id_fkey',
                    'FOREIGN KEY (pohead_potype_id)
                     REFERENCES public.potype (potype_id) MATCH SIMPLE
                     ON UPDATE NO ACTION ON DELETE NO ACTION', 'public');
                         
-- Migrate POTYPE table from original xt extension into public
DO $$
BEGIN
  IF EXISTS(SELECT 1
              FROM information_schema.tables 
             WHERE table_schema = 'xt'
               AND table_name = 'poheadext') THEN

    UPDATE pohead a SET pohead_potype_id = poheadext_potype_id
      FROM xt.poheadext b
     WHERE a.pohead_id=b.poheadext_id;
      
    DROP TABLE xt.poheadext;
    
  END IF;
END
$$ language plpgsql;

ALTER TABLE public.pohead ENABLE TRIGGER ALL;

COMMENT ON TABLE pohead IS 'Purchase Order header information';
