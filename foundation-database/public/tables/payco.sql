SELECT xt.create_table('payco', 'public');

ALTER TABLE public.payco DISABLE TRIGGER ALL;

SELECT
  xt.add_column('payco', 'payco_id',            'SERIAL', 'PRIMARY KEY', 'public'),
  xt.add_column('payco', 'payco_ccpay_id',     'INTEGER', 'NOT NULL', 'public'),
  xt.add_column('payco', 'payco_cohead_id',    'INTEGER', 'NOT NULL', 'public'),
  xt.add_column('payco', 'payco_amount', 'NUMERIC(20,2)', 'DEFAULT 0.00 NOT NULL', 'public'),
  xt.add_column('payco', 'payco_curr_id',      'INTEGER', 'DEFAULT basecurrid()', 'public');

SELECT
  xt.add_constraint('payco','payco_unique_ccpay_id_cohead_id',
                    'UNIQUE(payco_ccpay_id, payco_cohead_id)', 'public'),
  xt.add_constraint('payco', 'payco_payco_ccpay_id_fkey',
                    'FOREIGN KEY (payco_ccpay_id) REFERENCES ccpay(ccpay_id)', 'public'),
  xt.add_constraint('payco', 'payco_payco_cohead_id_fkey',
                    'FOREIGN KEY (payco_cohead_id) REFERENCES cohead(cohead_id)', 'public');

ALTER TABLE public.payco ENABLE TRIGGER ALL;

COMMENT ON TABLE payco IS 'Credit Card payment to sales order join table';

COMMENT ON COLUMN payco.payco_id IS 'payco table primary key.';
