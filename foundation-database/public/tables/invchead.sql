SELECT xt.create_table('invchead', 'public');

ALTER TABLE public.invchead DISABLE TRIGGER ALL;

SELECT
  xt.add_column('invchead', 'invchead_id',         'SERIAL', 'NOT NULL', 'public'),
  xt.add_column('invchead', 'invchead_cust_id',   'INTEGER', 'NOT NULL', 'public'),
  xt.add_column('invchead', 'invchead_shipto_id', 'INTEGER', NULL,       'public'),
  xt.add_column('invchead', 'invchead_ordernumber',  'TEXT', NULL,       'public'),
  xt.add_column('invchead', 'invchead_orderdate',    'DATE', NULL,       'public'),
  xt.add_column('invchead', 'invchead_posted',    'BOOLEAN', 'NOT NULL', 'public'),
  xt.add_column('invchead', 'invchead_printed',   'BOOLEAN', 'NOT NULL', 'public'),
  xt.add_column('invchead', 'invchead_invcnumber',   'TEXT', 'NOT NULL', 'public'),
  xt.add_column('invchead', 'invchead_invcdate',     'DATE', 'NOT NULL', 'public'),
  xt.add_column('invchead', 'invchead_shipdate',     'DATE', NULL,       'public'),
  xt.add_column('invchead', 'invchead_ponumber',     'TEXT', NULL,       'public'),
  xt.add_column('invchead', 'invchead_shipvia',      'TEXT', NULL,       'public'),
  xt.add_column('invchead', 'invchead_fob',          'TEXT', NULL,       'public'),
  xt.add_column('invchead', 'invchead_billto_name',  'TEXT', NULL,       'public'),
  xt.add_column('invchead', 'invchead_billto_address1', 'TEXT', NULL, 'public'),
  xt.add_column('invchead', 'invchead_billto_address2', 'TEXT', NULL, 'public'),
  xt.add_column('invchead', 'invchead_billto_address3', 'TEXT', NULL, 'public'),
  xt.add_column('invchead', 'invchead_billto_city',     'TEXT', NULL, 'public'),
  xt.add_column('invchead', 'invchead_billto_state',    'TEXT', NULL, 'public'),
  xt.add_column('invchead', 'invchead_billto_zipcode',  'TEXT', NULL, 'public'),
  xt.add_column('invchead', 'invchead_billto_phone',    'TEXT', NULL, 'public'),
  xt.add_column('invchead', 'invchead_shipto_name',     'TEXT', NULL, 'public'),
  xt.add_column('invchead', 'invchead_shipto_address1', 'TEXT', NULL, 'public'),
  xt.add_column('invchead', 'invchead_shipto_address2', 'TEXT', NULL, 'public'),
  xt.add_column('invchead', 'invchead_shipto_address3', 'TEXT', NULL, 'public'),
  xt.add_column('invchead', 'invchead_shipto_city',     'TEXT', NULL, 'public'),
  xt.add_column('invchead', 'invchead_shipto_state',    'TEXT', NULL, 'public'),
  xt.add_column('invchead', 'invchead_shipto_zipcode',  'TEXT', NULL, 'public'),
  xt.add_column('invchead', 'invchead_shipto_phone',    'TEXT', NULL, 'public'),
  xt.add_column('invchead', 'invchead_salesrep_id',  'INTEGER', NULL, 'public'),
  xt.add_column('invchead', 'invchead_commission',  'NUMERIC(20,10)', 'NOT NULL', 'public'),
  xt.add_column('invchead', 'invchead_terms_id',     'INTEGER', NULL, 'public'),
  xt.add_column('invchead', 'invchead_freight',     'NUMERIC(16,2)', 'NOT NULL', 'public'),
  xt.add_column('invchead', 'invchead_misc_amount', 'NUMERIC(16,2)', 'NOT NULL', 'public'),
  xt.add_column('invchead', 'invchead_misc_descrip',     'TEXT', NULL, 'public'),
  xt.add_column('invchead', 'invchead_misc_accnt_id', 'INTEGER', NULL, 'public'),
  xt.add_column('invchead', 'invchead_payment', 'NUMERIC(16,2)', NULL, 'public'),
  xt.add_column('invchead', 'invchead_paymentref',       'TEXT', NULL, 'public'),
  xt.add_column('invchead', 'invchead_notes',            'TEXT', NULL, 'public'),
  xt.add_column('invchead', 'invchead_billto_country',   'TEXT', NULL, 'public'),
  xt.add_column('invchead', 'invchead_shipto_country',   'TEXT', NULL, 'public'),
  xt.add_column('invchead', 'invchead_prj_id',        'INTEGER', NULL, 'public'),
  xt.add_column('invchead', 'invchead_curr_id',       'INTEGER', 'DEFAULT basecurrid()', 'public'),
  xt.add_column('invchead', 'invchead_gldistdate',       'DATE', NULL, 'public'),
  xt.add_column('invchead', 'invchead_recurring',     'BOOLEAN', 'DEFAULT false NOT NULL', 'public'),
  xt.add_column('invchead', 'invchead_recurring_interval',    'INTEGER', NULL, 'public'),
  xt.add_column('invchead', 'invchead_recurring_type',           'TEXT', NULL, 'public'),
  xt.add_column('invchead', 'invchead_recurring_until',          'DATE', NULL, 'public'),
  xt.add_column('invchead', 'invchead_recurring_invchead_id', 'INTEGER', NULL, 'public'),
  xt.add_column('invchead', 'invchead_shipchrg_id', 'INTEGER', NULL,            'public'),
  xt.add_column('invchead', 'invchead_taxzone_id',  'INTEGER', NULL,            'public'),
  xt.add_column('invchead', 'invchead_void',        'BOOLEAN', 'DEFAULT false', 'public'),
  xt.add_column('invchead', 'invchead_saletype_id', 'INTEGER', NULL,            'public'),
  xt.add_column('invchead', 'invchead_shipzone_id', 'INTEGER', NULL,            'public'),
  xt.add_column('invchead', 'invchead_created', 'TIMESTAMP WITH TIME ZONE', NULL, 'public'),
  xt.add_column('invchead', 'invchead_lastupdated',  'TIMESTAMP WITH TIME ZONE', NULL, 'public');

SELECT
  xt.add_constraint('invchead', 'invchead_pkey', 'PRIMARY KEY (invchead_id)', 'public'),
  xt.add_constraint('invchead', 'invchead_invchead_invcnumber_check',
                    $$CHECK (invchead_invcnumber <> ''::text)$$, 'public'),
  xt.add_constraint('invchead', 'invchead_invcnumber_unique',
                    'UNIQUE (invchead_invcnumber)', 'public'),
  xt.add_constraint('invchead', 'invchead_invchead_saletype_id_fkey',
                    'FOREIGN KEY (invchead_saletype_id) REFERENCES saletype(saletype_id)', 'public'),
  xt.add_constraint('invchead', 'invchead_invchead_shipzone_id_fkey',
                    'FOREIGN KEY (invchead_shipzone_id) REFERENCES shipzone(shipzone_id)', 'public'),
  xt.add_constraint('invchead', 'invchead_invchead_taxzone_id_fkey',
                    'FOREIGN KEY (invchead_taxzone_id) REFERENCES taxzone(taxzone_id)', 'public'),
  xt.add_constraint('invchead', 'invchead_to_curr_symbol',
                    'FOREIGN KEY (invchead_curr_id) REFERENCES curr_symbol(curr_id)', 'public');

ALTER TABLE public.invchead ENABLE TRIGGER ALL;

COMMENT ON TABLE invchead IS 'Invoice header information';

COMMENT ON COLUMN invchead.invchead_recurring IS 'Deprecated.';
COMMENT ON COLUMN invchead.invchead_recurring_interval IS 'Deprecated.';
COMMENT ON COLUMN invchead.invchead_recurring_type IS 'Deprecated.';
COMMENT ON COLUMN invchead.invchead_recurring_until IS 'Deprecated.';
COMMENT ON COLUMN invchead.invchead_saletype_id IS 'Associated sale type for invoice.';
COMMENT ON COLUMN invchead.invchead_shipzone_id IS 'Associated shipping zone for invoice.';
