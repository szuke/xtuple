SELECT xt.create_table('cohist', 'public');

ALTER TABLE public.cohist DISABLE TRIGGER ALL;

SELECT
  xt.add_column('cohist', 'cohist_id',               'SERIAL', 'NOT NULL', 'public'),
  xt.add_column('cohist', 'cohist_cust_id',         'INTEGER', NULL, 'public'),
  xt.add_column('cohist', 'cohist_itemsite_id',     'INTEGER', NULL, 'public'),
  xt.add_column('cohist', 'cohist_shipdate',           'DATE', NULL, 'public'),
  xt.add_column('cohist', 'cohist_shipvia',            'TEXT', NULL, 'public'),
  xt.add_column('cohist', 'cohist_ordernumber',        'TEXT', NULL, 'public'),
  xt.add_column('cohist', 'cohist_orderdate',          'DATE', NULL, 'public'),
  xt.add_column('cohist', 'cohist_invcnumber',         'TEXT', NULL, 'public'),
  xt.add_column('cohist', 'cohist_invcdate',           'DATE', NULL, 'public'),
  xt.add_column('cohist', 'cohist_qtyshipped','NUMERIC(18,6)', NULL, 'public'),
  xt.add_column('cohist', 'cohist_unitprice', 'NUMERIC(16,4)', NULL, 'public'),
  xt.add_column('cohist', 'cohist_shipto_id',       'INTEGER', NULL, 'public'),
  xt.add_column('cohist', 'cohist_salesrep_id',     'INTEGER', NULL, 'public'),
  xt.add_column('cohist', 'cohist_duedate',            'DATE', NULL, 'public'),
  xt.add_column('cohist', 'cohist_imported',        'BOOLEAN', 'DEFAULT false', 'public'),
  xt.add_column('cohist', 'cohist_billtoname',         'TEXT', NULL, 'public'),
  xt.add_column('cohist', 'cohist_billtoaddress1',     'TEXT', NULL, 'public'),
  xt.add_column('cohist', 'cohist_billtoaddress2',     'TEXT', NULL, 'public'),
  xt.add_column('cohist', 'cohist_billtoaddress3',     'TEXT', NULL, 'public'),
  xt.add_column('cohist', 'cohist_billtocity',         'TEXT', NULL, 'public'),
  xt.add_column('cohist', 'cohist_billtostate',        'TEXT', NULL, 'public'),
  xt.add_column('cohist', 'cohist_billtozip',          'TEXT', NULL, 'public'),
  xt.add_column('cohist', 'cohist_shiptoname',         'TEXT', NULL, 'public'),
  xt.add_column('cohist', 'cohist_shiptoaddress1',     'TEXT', NULL, 'public'),
  xt.add_column('cohist', 'cohist_shiptoaddress2',     'TEXT', NULL, 'public'),
  xt.add_column('cohist', 'cohist_shiptoaddress3',     'TEXT', NULL, 'public'),
  xt.add_column('cohist', 'cohist_shiptocity',         'TEXT', NULL, 'public'),
  xt.add_column('cohist', 'cohist_shiptostate',        'TEXT', NULL, 'public'),
  xt.add_column('cohist', 'cohist_shiptozip',          'TEXT', NULL, 'public'),
  xt.add_column('cohist', 'cohist_commission','NUMERIC(16,4)', NULL, 'public'),
  xt.add_column('cohist', 'cohist_commissionpaid',  'BOOLEAN', NULL, 'public'),
  xt.add_column('cohist', 'cohist_unitcost',  'NUMERIC(18,6)', NULL, 'public'),
  xt.add_column('cohist', 'cohist_misc_type',  'CHARACTER(1)', NULL, 'public'),
  xt.add_column('cohist', 'cohist_misc_descrip',       'TEXT', NULL, 'public'),
  xt.add_column('cohist', 'cohist_misc_id',         'INTEGER', NULL, 'public'),
  xt.add_column('cohist', 'cohist_doctype',            'TEXT', NULL, 'public'),
  xt.add_column('cohist', 'cohist_promisedate',        'DATE', NULL, 'public'),
  xt.add_column('cohist', 'cohist_ponumber',           'TEXT', NULL, 'public'),
  xt.add_column('cohist', 'cohist_curr_id',         'INTEGER', 'DEFAULT basecurrid()', 'public'),
  xt.add_column('cohist', 'cohist_sequence',        'INTEGER', NULL, 'public'),
  xt.add_column('cohist', 'cohist_taxtype_id',      'INTEGER', NULL, 'public'),
  xt.add_column('cohist', 'cohist_taxzone_id',      'INTEGER', NULL, 'public'),
  xt.add_column('cohist', 'cohist_cohead_ccpay_id', 'INTEGER', NULL, 'public'),
  xt.add_column('cohist', 'cohist_saletype_id',     'INTEGER', NULL, 'public'),
  xt.add_column('cohist', 'cohist_shipzone_id',     'INTEGER', NULL, 'public'),
  xt.add_column('cohist', 'cohist_listprice', 'NUMERIC(16,4)', NULL, 'public'),
  xt.add_column('cohist', 'cohist_billtocountry',      'TEXT', NULL, 'public'),
  xt.add_column('cohist', 'cohist_shiptocountry',      'TEXT', NULL, 'public'),
  xt.add_column('cohist', 'cohist_coitem_id',       'INTEGER', NULL, 'public'),
  xt.add_column('cohist', 'cohist_invchead_id',     'INTEGER', NULL, 'public'),
  xt.add_column('cohist', 'cohist_invcitem_id',     'INTEGER', NULL, 'public');

SELECT
  xt.add_constraint('cohist', 'cohist_pkey', 'PRIMARY KEY (cohist_id)', 'public'),
  xt.add_constraint('cohist', 'cohist_cohist_cohead_ccpay_id_fkey', 'FOREIGN KEY (cohist_cohead_ccpay_id) REFERENCES ccpay(ccpay_id)', 'public'),
  xt.add_constraint('cohist', 'cohist_cohist_cust_id_fkey', 'FOREIGN KEY (cohist_cust_id) REFERENCES custinfo(cust_id)', 'public'),
  xt.add_constraint('cohist', 'cohist_cohist_salesrep_id_fkey', 'FOREIGN KEY (cohist_salesrep_id) REFERENCES salesrep(salesrep_id)', 'public'),
  xt.add_constraint('cohist', 'cohist_cohist_taxtype_id_fkey', 'FOREIGN KEY (cohist_taxtype_id) REFERENCES taxtype(taxtype_id)', 'public'),
  xt.add_constraint('cohist', 'cohist_cohist_taxzone_id_fkey', 'FOREIGN KEY (cohist_taxzone_id) REFERENCES taxzone(taxzone_id)', 'public'),
  xt.add_constraint('cohist', 'cohist_to_curr_symbol', 'FOREIGN KEY (cohist_curr_id) REFERENCES curr_symbol(curr_id)', 'public'),
  xt.add_constraint('cohist', 'cohist_cohist_coitem_id_fkey', 'FOREIGN KEY (cohist_coitem_id) REFERENCES public.coitem (coitem_id) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION', 'public'),
  xt.add_constraint('cohist', 'cohist_cohist_invchead_id_fkey', 'FOREIGN KEY (cohist_invchead_id) REFERENCES public.invchead (invchead_id) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION', 'public'),
  xt.add_constraint('cohist', 'cohist_cohist_invcitem_id_fkey', 'FOREIGN KEY (cohist_invcitem_id) REFERENCES public.invcitem (invcitem_id) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION', 'public');

ALTER TABLE public.cohist ENABLE TRIGGER ALL;

COMMENT ON TABLE cohist IS 'Sales Order history';

COMMENT ON COLUMN cohist.cohist_cohead_ccpay_id IS 'Credit card payments made at sales order time (as opposed to invoice time) need special treatment. This field allows checking for this case.';
COMMENT ON COLUMN cohist.cohist_saletype_id IS 'Associated sale type for sales history.';
COMMENT ON COLUMN cohist.cohist_shipzone_id IS 'Associated shipping zone for sales history.';
COMMENT ON COLUMN public.cohist.cohist_listprice IS 'List price of Item.';
COMMENT ON COLUMN public.cohist.cohist_coitem_id   IS 'Sales Order line ID that generated this history record, if applicable.';
COMMENT ON COLUMN public.cohist.cohist_invchead_id IS 'Invoice ID that generated this history record, if applicable.';
COMMENT ON COLUMN public.cohist.cohist_invcitem_id IS 'Invoice line ID that generated this history record, if applicable.';
