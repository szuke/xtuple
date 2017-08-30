SELECT xt.create_table('cashrcptmisc', 'public');

ALTER TABLE public.cashrcptmisc DISABLE TRIGGER ALL;

SELECT
  xt.add_column('cashrcptmisc', 'cashrcptmisc_id',            'SERIAL', 'NOT NULL', 'public'),
  xt.add_column('cashrcptmisc', 'cashrcptmisc_cashrcpt_id',  'INTEGER', 'NOT NULL', 'public'),
  xt.add_column('cashrcptmisc', 'cashrcptmisc_accnt_id',     'INTEGER', 'NOT NULL', 'public'),
  xt.add_column('cashrcptmisc', 'cashrcptmisc_amount', 'NUMERIC(20,2)', 'NOT NULL', 'public'),
  xt.add_column('cashrcptmisc', 'cashrcptmisc_notes',           'TEXT', NULL,       'public'),
  xt.add_column('cashrcptmisc', 'cashrcptmisc_cust_id',      'INTEGER', NULL,       'public'),
  xt.add_column('cashrcptmisc', 'cashrcptmisc_tax_id',       'INTEGER', NULL,       'public');

SELECT
  xt.add_constraint('cashrcptmisc', 'cashrcptmisc_pkey',
                    'PRIMARY KEY (cashrcptmisc_id)', 'public'),
  xt.add_constraint('cashrcptmisc', 'cashrcptmisc_accnt_accnt_id_fkey',
                    'FOREIGN KEY (cashrcptmisc_accnt_id) REFERENCES accnt(accnt_id)', 'public'),
  xt.add_constraint('cashrcptmisc', 'cashrcptmisc_cashrcpt_cashrcpt_id_fkey',
                    'FOREIGN KEY (cashrcptmisc_cashrcpt_id) REFERENCES cashrcpt(cashrcpt_id)', 'public'),
  xt.add_constraint('cashrcptmisc', 'cashrcptmisc_tax_id_fkey',
                    'FOREIGN KEY (cashrcptmisc_tax_id) REFERENCES tax (tax_id)
                     MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION', 'public');

ALTER TABLE cashrcptmisc ALTER COLUMN cashrcptmisc_accnt_id DROP NOT NULL;

ALTER TABLE public.cashrcptmisc ENABLE TRIGGER ALL;

COMMENT ON TABLE cashrcptmisc IS 'Cash Receipt Miscellaneous Application information';
