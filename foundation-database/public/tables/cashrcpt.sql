SELECT xt.create_table('cashrcpt', 'public');

ALTER TABLE public.cashrcpt DISABLE TRIGGER ALL;

DROP VIEW IF EXISTS api.cashreceipt;
DROP VIEW IF EXISTS api.cashreceiptapply;
DROP VIEW IF EXISTS api.cashreceiptapplymisc;
DROP VIEW IF EXISTS xm.cash_receipt;
DROP VIEW IF EXISTS xm.cash_receipt_list_item;
DROP VIEW IF EXISTS xt.cashrcptitem_pending cascade;

SELECT
  xt.add_column('cashrcpt', 'cashrcpt_id',                 'SERIAL', 'NOT NULL', 'public'),
  xt.add_column('cashrcpt', 'cashrcpt_cust_id',           'INTEGER', 'NOT NULL', 'public'),
  xt.add_column('cashrcpt', 'cashrcpt_amount',      'NUMERIC(20,2)', 'NOT NULL', 'public'),
  xt.add_column('cashrcpt', 'cashrcpt_fundstype',            'TEXT', 'NOT NULL', 'public'),
  xt.add_column('cashrcpt', 'cashrcpt_docnumber',            'TEXT', NULL,       'public'),
  xt.add_column('cashrcpt', 'cashrcpt_bankaccnt_id',      'INTEGER', 'NOT NULL', 'public'),
  xt.add_column('cashrcpt', 'cashrcpt_notes',                'TEXT', NULL,       'public'),
  xt.add_column('cashrcpt', 'cashrcpt_distdate',             'DATE', $$DEFAULT ('now'::text)::date$$, 'public'),
  xt.add_column('cashrcpt', 'cashrcpt_salescat_id',       'INTEGER', 'DEFAULT -1', 'public'),
  xt.add_column('cashrcpt', 'cashrcpt_curr_id',           'INTEGER', 'DEFAULT basecurrid()', 'public'),
  xt.add_column('cashrcpt', 'cashrcpt_usecustdeposit',    'BOOLEAN', 'DEFAULT false NOT NULL', 'public'),
  xt.add_column('cashrcpt', 'cashrcpt_void',              'BOOLEAN', 'DEFAULT false NOT NULL', 'public'),
  xt.add_column('cashrcpt', 'cashrcpt_number',               'TEXT', 'NOT NULL', 'public'),
  xt.add_column('cashrcpt', 'cashrcpt_docdate',              'DATE', NULL,       'public'),
  xt.add_column('cashrcpt', 'cashrcpt_posted',            'BOOLEAN', 'DEFAULT false NOT NULL', 'public'),
  xt.add_column('cashrcpt', 'cashrcpt_posteddate',           'DATE', NULL,       'public'),
  xt.add_column('cashrcpt', 'cashrcpt_postedby',             'TEXT', NULL,       'public'),
  xt.add_column('cashrcpt', 'cashrcpt_applydate',            'DATE', NULL,       'public'),
  xt.add_column('cashrcpt', 'cashrcpt_discount',    'NUMERIC(20,2)', 'DEFAULT 0.00 NOT NULL', 'public'),
  xt.add_column('cashrcpt', 'cashrcpt_curr_rate',         'NUMERIC', 'NOT NULL', 'public'),
  xt.add_column('cashrcpt', 'cashrcpt_alt_curr_rate',     'NUMERIC', NULL,       'public'),
  xt.add_column('cashrcpt', 'cashrcpt_custgrp_id',        'INTEGER', NULL,       'public'),
  xt.add_column('cashrcpt', 'cashrcpt_prj_id',            'INTEGER', 'REFERENCES prj (prj_id)', 'public'),
  xt.add_column('cashrcpt', 'cashrcpt_ccpay_id',          'INTEGER', NULL,       'public');

ALTER TABLE cashrcpt ALTER COLUMN cashrcpt_cust_id DROP NOT NULL;

SELECT
  xt.add_constraint('cashrcpt', 'cashrcpt_pkey', 'PRIMARY KEY (cashrcpt_id)', 'public'),
  xt.add_constraint('cashrcpt', 'cashrcpt_cashrcpt_number_key',
                   'UNIQUE (cashrcpt_number)', 'public'),
  xt.add_constraint('cashrcpt', 'cashrcpt_cashrcpt_number_check',
                    $$CHECK cashrcpt_number <> ''$$, 'public'),
  xt.add_constraint('cashrcpt','cashrcpt_cust_id_check',
                    'CHECK((cashrcpt_custgrp_id IS NULL AND cashrcpt_cust_id IS NOT NULL) OR (cashrcpt_custgrp_id IS NOT NULL AND cashrcpt_cust_id IS NULL))', 'public'),
  xt.add_constraint('cashrcpt', 'fk_cashrcpt_custgrp_id',
                    'FOREIGN KEY (cashrcpt_custgrp_id) REFERENCES custgrp(custgrp_id)', 'public'),
  xt.add_constraint('cashrcpt', 'cashrcpt_cashrcpt_ccpay_id_fkey',
                    'FOREIGN KEY (cashrcpt_ccpay_id) REFERENCES ccpay(ccpay_id)', 'public');

ALTER TABLE public.cashrcpt ENABLE TRIGGER ALL;

COMMENT ON TABLE cashrcpt IS 'Temporary table for storing Cash Receipt information before Cash Receipts are posted';
