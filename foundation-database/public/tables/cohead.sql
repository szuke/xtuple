SELECT xt.create_table('cohead', 'public');

ALTER TABLE public.cohead DISABLE TRIGGER ALL;

SELECT
  xt.add_column('cohead', 'cohead_id',                    'SERIAL', 'NOT NULL', 'public'),
  xt.add_column('cohead', 'cohead_number',                  'TEXT', 'NOT NULL', 'public'),
  xt.add_column('cohead', 'cohead_cust_id',              'INTEGER', 'NOT NULL', 'public'),
  xt.add_column('cohead', 'cohead_custponumber',            'TEXT', NULL, 'public'),
  xt.add_column('cohead', 'cohead_orderdate',               'DATE', NULL, 'public'),
  xt.add_column('cohead', 'cohead_warehous_id',          'INTEGER', NULL, 'public'),
  xt.add_column('cohead', 'cohead_shipto_id',            'INTEGER', NULL, 'public'),
  xt.add_column('cohead', 'cohead_shiptoname',              'TEXT', NULL, 'public'),
  xt.add_column('cohead', 'cohead_shiptoaddress1',          'TEXT', NULL, 'public'),
  xt.add_column('cohead', 'cohead_shiptoaddress2',          'TEXT', NULL, 'public'),
  xt.add_column('cohead', 'cohead_shiptoaddress3',          'TEXT', NULL, 'public'),
  xt.add_column('cohead', 'cohead_shiptoaddress4',          'TEXT', NULL, 'public'),
  xt.add_column('cohead', 'cohead_shiptoaddress5',          'TEXT', NULL, 'public'),
  xt.add_column('cohead', 'cohead_salesrep_id',          'INTEGER', 'NOT NULL', 'public'),
  xt.add_column('cohead', 'cohead_terms_id',             'INTEGER', 'NOT NULL', 'public'),
  xt.add_column('cohead', 'cohead_fob',                     'TEXT', NULL, 'public'),
  xt.add_column('cohead', 'cohead_shipvia',                 'TEXT', NULL, 'public'),
  xt.add_column('cohead', 'cohead_shiptocity',              'TEXT', NULL, 'public'),
  xt.add_column('cohead', 'cohead_shiptostate',             'TEXT', NULL, 'public'),
  xt.add_column('cohead', 'cohead_shiptozipcode',           'TEXT', NULL, 'public'),
  xt.add_column('cohead', 'cohead_freight',        'NUMERIC(16,4)', 'NOT NULL', 'public'),
  xt.add_column('cohead', 'cohead_misc',           'NUMERIC(16,4)', 'DEFAULT 0 NOT NULL', 'public'),
  xt.add_column('cohead', 'cohead_imported',             'BOOLEAN', 'DEFAULT false', 'public'),
  xt.add_column('cohead', 'cohead_ordercomments',           'TEXT', NULL, 'public'),
  xt.add_column('cohead', 'cohead_shipcomments',            'TEXT', NULL, 'public'),
  xt.add_column('cohead', 'cohead_shiptophone',             'TEXT', NULL, 'public'),
  xt.add_column('cohead', 'cohead_shipchrg_id',          'INTEGER', NULL, 'public'),
  xt.add_column('cohead', 'cohead_shipform_id',          'INTEGER', NULL, 'public'),
  xt.add_column('cohead', 'cohead_billtoname',              'TEXT', NULL, 'public'),
  xt.add_column('cohead', 'cohead_billtoaddress1',          'TEXT', NULL, 'public'),
  xt.add_column('cohead', 'cohead_billtoaddress2',          'TEXT', NULL, 'public'),
  xt.add_column('cohead', 'cohead_billtoaddress3',          'TEXT', NULL, 'public'),
  xt.add_column('cohead', 'cohead_billtocity',              'TEXT', NULL, 'public'),
  xt.add_column('cohead', 'cohead_billtostate',             'TEXT', NULL, 'public'),
  xt.add_column('cohead', 'cohead_billtozipcode',           'TEXT', NULL, 'public'),
  xt.add_column('cohead', 'cohead_misc_accnt_id',        'INTEGER', NULL, 'public'),
  xt.add_column('cohead', 'cohead_misc_descrip',            'TEXT', NULL, 'public'),
  xt.add_column('cohead', 'cohead_commission',     'NUMERIC(16,4)', NULL, 'public'),
  xt.add_column('cohead', 'cohead_miscdate',                'DATE', NULL, 'public'),
  xt.add_column('cohead', 'cohead_holdtype',        'CHARACTER(1)', NULL, 'public'),
  xt.add_column('cohead', 'cohead_packdate',                'DATE', NULL, 'public'),
  xt.add_column('cohead', 'cohead_prj_id',               'INTEGER', NULL, 'public'),
  xt.add_column('cohead', 'cohead_wasquote',             'BOOLEAN', 'DEFAULT false NOT NULL', 'public'),
  xt.add_column('cohead', 'cohead_lastupdated', 'TIMESTAMP WITHOUT TIME ZONE', $$DEFAULT ('now'::text)::timestamp(6) with time zone NOT NULL$$, 'public'),
  xt.add_column('cohead', 'cohead_shipcomplete',         'BOOLEAN', 'DEFAULT false NOT NULL', 'public'),
  xt.add_column('cohead', 'cohead_created',     'TIMESTAMP WITHOUT TIME ZONE', $$DEFAULT ('now'::text)::timestamp(6) with time zone$$, 'public'),
  xt.add_column('cohead', 'cohead_creator',                 'TEXT', 'DEFAULT geteffectivextuser()', 'public'),
  xt.add_column('cohead', 'cohead_quote_number',            'TEXT', NULL, 'public'),
  xt.add_column('cohead', 'cohead_billtocountry',           'TEXT', NULL, 'public'),
  xt.add_column('cohead', 'cohead_shiptocountry',           'TEXT', NULL, 'public'),
  xt.add_column('cohead', 'cohead_curr_id',              'INTEGER', 'DEFAULT basecurrid()', 'public'),
  xt.add_column('cohead', 'cohead_calcfreight',          'BOOLEAN', 'DEFAULT false NOT NULL', 'public'),
  xt.add_column('cohead', 'cohead_shipto_cntct_id',      'INTEGER', NULL, 'public'),
  xt.add_column('cohead', 'cohead_shipto_cntct_honorific',  'TEXT', NULL, 'public'),
  xt.add_column('cohead', 'cohead_shipto_cntct_first_name', 'TEXT', NULL, 'public'),
  xt.add_column('cohead', 'cohead_shipto_cntct_middle',     'TEXT', NULL, 'public'),
  xt.add_column('cohead', 'cohead_shipto_cntct_last_name',  'TEXT', NULL, 'public'),
  xt.add_column('cohead', 'cohead_shipto_cntct_suffix',     'TEXT', NULL, 'public'),
  xt.add_column('cohead', 'cohead_shipto_cntct_phone',      'TEXT', NULL, 'public'),
  xt.add_column('cohead', 'cohead_shipto_cntct_title',      'TEXT', NULL, 'public'),
  xt.add_column('cohead', 'cohead_shipto_cntct_fax',        'TEXT', NULL, 'public'),
  xt.add_column('cohead', 'cohead_shipto_cntct_email',      'TEXT', NULL, 'public'),
  xt.add_column('cohead', 'cohead_billto_cntct_id',      'INTEGER', NULL, 'public'),
  xt.add_column('cohead', 'cohead_billto_cntct_honorific',  'TEXT', NULL, 'public'),
  xt.add_column('cohead', 'cohead_billto_cntct_first_name', 'TEXT', NULL, 'public'),
  xt.add_column('cohead', 'cohead_billto_cntct_middle',     'TEXT', NULL, 'public'),
  xt.add_column('cohead', 'cohead_billto_cntct_last_name',  'TEXT', NULL, 'public'),
  xt.add_column('cohead', 'cohead_billto_cntct_suffix',     'TEXT', NULL, 'public'),
  xt.add_column('cohead', 'cohead_billto_cntct_phone',      'TEXT', NULL, 'public'),
  xt.add_column('cohead', 'cohead_billto_cntct_title',      'TEXT', NULL, 'public'),
  xt.add_column('cohead', 'cohead_billto_cntct_fax',        'TEXT', NULL, 'public'),
  xt.add_column('cohead', 'cohead_billto_cntct_email',      'TEXT', NULL, 'public'),
  xt.add_column('cohead', 'cohead_taxzone_id',           'INTEGER', NULL, 'public'),
  xt.add_column('cohead', 'cohead_taxtype_id',           'INTEGER', NULL, 'public'),
  xt.add_column('cohead', 'cohead_ophead_id',            'INTEGER', NULL, 'public'),
  xt.add_column('cohead', 'cohead_status',          'CHARACTER(1)', $$DEFAULT 'O' NOT NULL$$, 'public'),
  xt.add_column('cohead', 'cohead_saletype_id',          'INTEGER', NULL, 'public'),
  xt.add_column('cohead', 'cohead_shipzone_id',          'INTEGER', NULL, 'public');

SELECT
  xt.add_constraint('cohead', 'cohead_pkey',  'PRIMARY KEY (cohead_id)', 'public'),
  xt.add_constraint('cohead', 'cohead_cohead_number_key', 'UNIQUE (cohead_number)', 'public'),
  xt.add_constraint('cohead', 'cohead_check',
                    'CHECK (cohead_misc = (0)::numeric OR (cohead_misc <> (0)::numeric AND cohead_misc_accnt_id IS NOT NULL)),', 'public'),
  xt.add_constraint('cohead', 'cohead_cohead_number_check',
                    'CHECK (cohead_number <> ''::text)', 'public'),
  xt.add_constraint('cohead', 'cohead_cohead_billto_cntct_id_fkey',
                   'FOREIGN KEY (cohead_billto_cntct_id) REFERENCES cntct(cntct_id)', 'public'),
  xt.add_constraint('cohead', 'cohead_cohead_cust_id_fkey',
                   'FOREIGN KEY (cohead_cust_id) REFERENCES custinfo(cust_id)', 'public'),
  xt.add_constraint('cohead', 'cohead_cohead_misc_accnt_id_fkey',
                   'FOREIGN KEY (cohead_misc_accnt_id) REFERENCES accnt(accnt_id)', 'public'),
  xt.add_constraint('cohead', 'cohead_cohead_ophead_id_fkey',
                   'FOREIGN KEY (cohead_ophead_id) REFERENCES ophead(ophead_id)', 'public'),
  xt.add_constraint('cohead', 'cohead_cohead_prj_id_fkey',
                   'FOREIGN KEY (cohead_prj_id) REFERENCES prj(prj_id)', 'public'),
  xt.add_constraint('cohead', 'cohead_cohead_salesrep_id_fkey',
                   'FOREIGN KEY (cohead_salesrep_id) REFERENCES salesrep(salesrep_id)', 'public'),
  xt.add_constraint('cohead', 'cohead_cohead_saletype_id_fkey',
                   'FOREIGN KEY (cohead_saletype_id) REFERENCES saletype(saletype_id)', 'public'),
  xt.add_constraint('cohead', 'cohead_cohead_shipform_id_fkey',
                   'FOREIGN KEY (cohead_shipform_id) REFERENCES shipform(shipform_id)', 'public'),
  xt.add_constraint('cohead', 'cohead_cohead_shipto_cntct_id_fkey',
                   'FOREIGN KEY (cohead_shipto_cntct_id) REFERENCES cntct(cntct_id)', 'public'),
  xt.add_constraint('cohead', 'cohead_cohead_shipto_id_fkey',
                   'FOREIGN KEY (cohead_shipto_id) REFERENCES shiptoinfo(shipto_id)', 'public'),
  xt.add_constraint('cohead', 'cohead_cohead_shipzone_id_fkey',
                   'FOREIGN KEY (cohead_shipzone_id) REFERENCES shipzone(shipzone_id)', 'public'),
  xt.add_constraint('cohead', 'cohead_cohead_taxtype_id_fkey',
                   'FOREIGN KEY (cohead_taxtype_id) REFERENCES taxtype(taxtype_id)', 'public'),
  xt.add_constraint('cohead', 'cohead_cohead_taxzone_id_fkey',
                   'FOREIGN KEY (cohead_taxzone_id) REFERENCES taxzone(taxzone_id)', 'public'),
  xt.add_constraint('cohead', 'cohead_cohead_terms_id_fkey',
                   'FOREIGN KEY (cohead_terms_id) REFERENCES terms(terms_id)', 'public'),
  xt.add_constraint('cohead', 'cohead_cohead_warehous_id_fkey',
                   'FOREIGN KEY (cohead_warehous_id) REFERENCES whsinfo(warehous_id)', 'public'),
  xt.add_constraint('cohead', 'cohead_to_curr_symbol',
                   'FOREIGN KEY (cohead_curr_id) REFERENCES curr_symbol(curr_id)', 'public');

DO $$
BEGIN
  IF NOT EXISTS(SELECT 1
                  FROM information_schema.columns
                 WHERE table_name  = 'cohead'
                   AND column_name = 'cohead_type') THEN
    RAISE NOTICE 'cohead_type has already been removed';

  ELSIF EXISTS(SELECT 1 FROM cohead
                WHERE cohead_type IS NOT NULL) THEN
    RAISE NOTICE 'cohead_type is populated and could not be removed';

  ELSE
    ALTER TABLE public.cohead DROP COLUMN IF EXISTS cohead_type;
    RAISE NOTICE 'cohead_type has been removed';
  END IF;

  RETURN;
END;
$$ language plpgsql;

ALTER TABLE public.cohead ENABLE TRIGGER ALL;

COMMENT ON TABLE cohead IS 'Sales Order header information';

COMMENT ON COLUMN cohead.cohead_saletype_id IS 'Associated sale type for sales order.';
COMMENT ON COLUMN cohead.cohead_shipzone_id IS 'Associated shipping zone for sales order.';
