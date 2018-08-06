SELECT xt.create_table('cashrcptitem', 'public');

ALTER TABLE public.cashrcptitem DISABLE TRIGGER ALL;

SELECT
  xt.add_column('cashrcptitem', 'cashrcptitem_id',              'SERIAL', 'NOT NULL', 'public'),
  xt.add_column('cashrcptitem', 'cashrcptitem_cashrcpt_id',    'INTEGER', 'NOT NULL', 'public'),
  xt.add_column('cashrcptitem', 'cashrcptitem_aropen_id',      'INTEGER', 'NOT NULL', 'public'),
  xt.add_column('cashrcptitem', 'cashrcptitem_amount',   'NUMERIC(20,2)', 'NOT NULL', 'public'),
  xt.add_column('cashrcptitem', 'cashrcptitem_discount', 'NUMERIC(20,2)', 'DEFAULT 0.00 NOT NULL', 'public'),
  xt.add_column('cashrcptitem', 'cashrcptitem_applied',        'BOOLEAN', 'DEFAULT true', 'public'),
  xt.add_column('cashrcptitem', 'cashrcptitem_cust_id',        'INTEGER', NULL,       'public');

SELECT
  xt.add_constraint('cashrcptitem', 'cashrcptitem_pkey',
                    'PRIMARY KEY (cashrcptitem_id)', 'public'),
  xt.add_constraint('cashrcptitem', 'cashrcptitem_aropen_aropen_id_fkey',
                    'FOREIGN KEY (cashrcptitem_aropen_id) REFERENCES aropen(aropen_id)', 'public'),
  xt.add_constraint('cashrcptitem', 'cashrcptitem_cashrcpt_cashrcpt_id_fkey',
                    'FOREIGN KEY (cashrcptitem_cashrcpt_id) REFERENCES cashrcpt(cashrcpt_id)', 'public'),
  xt.add_constraint('cashrcptitem', 'cashrcptitem_cust_id_fkey',
                    'FOREIGN KEY (cashrcptitem_cust_id) REFERENCES custinfo(cust_id)', 'public');

UPDATE cashrcptitem
   SET cashrcptitem_cust_id = cashrcpt_cust_id
  FROM cashrcpt
 WHERE cashrcpt_id = cashrcptitem_cashrcpt_id
   AND cashrcpt_cust_id IS NOT NULL
   AND cashrcptitem_cust_id IS NULL;

ALTER TABLE public.cashrcptitem ENABLE TRIGGER ALL;

COMMENT ON TABLE cashrcptitem IS 'Temporary table for storing information about applications of Cash Receipts before Cash Receipts are posted';
