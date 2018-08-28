SELECT xt.create_table('asohist', 'public');

ALTER TABLE public.asohist DISABLE TRIGGER ALL;

SELECT
  xt.add_column('asohist', 'asohist_id',                'SERIAL', NULL, 'public'),
  xt.add_column('asohist', 'asohist_cust_id',          'INTEGER', NULL, 'public'),
  xt.add_column('asohist', 'asohist_itemsite_id',      'INTEGER', NULL, 'public'),
  xt.add_column('asohist', 'asohist_shipdate',            'DATE', NULL, 'public'),
  xt.add_column('asohist', 'asohist_invcdate',            'DATE', NULL, 'public'),
  xt.add_column('asohist', 'asohist_duedate',             'DATE', NULL, 'public'),
  xt.add_column('asohist', 'asohist_promisedate',         'DATE', NULL, 'public'),
  xt.add_column('asohist', 'asohist_ordernumber',         'TEXT', NULL, 'public'),
  xt.add_column('asohist', 'asohist_invcnumber',          'TEXT', NULL, 'public'),
  xt.add_column('asohist', 'asohist_qtyshipped', 'NUMERIC(18,6)', NULL, 'public'),
  xt.add_column('asohist', 'asohist_unitprice',  'NUMERIC(16,4)', NULL, 'public'),
  xt.add_column('asohist', 'asohist_unitcost',   'NUMERIC(16,6)', NULL, 'public'),
  xt.add_column('asohist', 'asohist_billtoname',          'TEXT', NULL, 'public'),
  xt.add_column('asohist', 'asohist_billtoaddress1',      'TEXT', NULL, 'public'),
  xt.add_column('asohist', 'asohist_billtoaddress2',      'TEXT', NULL, 'public'),
  xt.add_column('asohist', 'asohist_billtoaddress3',      'TEXT', NULL, 'public'),
  xt.add_column('asohist', 'asohist_billtocity',          'TEXT', NULL, 'public'),
  xt.add_column('asohist', 'asohist_billtostate',         'TEXT', NULL, 'public'),
  xt.add_column('asohist', 'asohist_billtozip',           'TEXT', NULL, 'public'),
  xt.add_column('asohist', 'asohist_shiptoname',          'TEXT', NULL, 'public'),
  xt.add_column('asohist', 'asohist_shiptoaddress1',      'TEXT', NULL, 'public'),
  xt.add_column('asohist', 'asohist_shiptoaddress2',      'TEXT', NULL, 'public'),
  xt.add_column('asohist', 'asohist_shiptoaddress3',      'TEXT', NULL, 'public'),
  xt.add_column('asohist', 'asohist_shiptocity',          'TEXT', NULL, 'public'),
  xt.add_column('asohist', 'asohist_shiptostate',         'TEXT', NULL, 'public'),
  xt.add_column('asohist', 'asohist_shiptozip',           'TEXT', NULL, 'public'),
  xt.add_column('asohist', 'asohist_shipto_id',        'INTEGER', NULL, 'public'),
  xt.add_column('asohist', 'asohist_shipvia',             'TEXT', NULL, 'public'),
  xt.add_column('asohist', 'asohist_salesrep_id',      'INTEGER', NULL, 'public'),
  xt.add_column('asohist', 'asohist_misc_type',   'CHARACTER(1)', NULL, 'public'),
  xt.add_column('asohist', 'asohist_misc_descrip',        'TEXT', NULL, 'public'),
  xt.add_column('asohist', 'asohist_misc_id',          'INTEGER', NULL, 'public'),
  xt.add_column('asohist', 'asohist_commission', 'NUMERIC(16,4)', NULL, 'public'),
  xt.add_column('asohist', 'asohist_commissionpaid',   'BOOLEAN', NULL, 'public'),
  xt.add_column('asohist', 'asohist_doctype',             'TEXT', NULL, 'public'),
  xt.add_column('asohist', 'asohist_orderdate',           'DATE', NULL, 'public'),
  xt.add_column('asohist', 'asohist_imported',         'BOOLEAN', NULL, 'public'),
  xt.add_column('asohist', 'asohist_ponumber',            'TEXT', NULL, 'public'),
  xt.add_column('asohist', 'asohist_curr_id',          'INTEGER', 'DEFAULT basecurrid()', 'public'),
  xt.add_column('asohist', 'asohist_taxtype_id',       'INTEGER', NULL, 'public'),
  xt.add_column('asohist', 'asohist_taxzone_id',       'INTEGER', NULL, 'public'),
  xt.add_column('asohist', 'asohist_billtocountry',       'TEXT', NULL, 'public'),
  xt.add_column('asohist', 'asohist_shiptocountry',       'TEXT', NULL, 'public');

SELECT
  xt.add_constraint('asohist', 'asohist_pkey', 'PRIMARY KEY (asohist_id)', 'public'),
  xt.add_constraint('asohist', 'asohist_asohist_taxtype_id_fkey',
                    'FOREIGN KEY (asohist_taxtype_id) REFERENCES taxtype(taxtype_id)', 'public'),
  xt.add_constraint('asohist', 'asohist_asohist_taxzone_id_fkey',
                    'FOREIGN KEY (asohist_taxzone_id) REFERENCES taxzone(taxzone_id)', 'public'),
  xt.add_constraint('asohist', 'asohist_to_curr_symbol',
                    'FOREIGN KEY (asohist_curr_id) REFERENCES curr_symbol(curr_id)', 'public');

ALTER TABLE public.asohist ENABLE TRIGGER ALL;

COMMENT ON TABLE asohist IS 'Archived Sales history';
