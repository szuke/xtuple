SELECT xt.create_table('ccbank', 'public');

ALTER TABLE public.ccbank DISABLE TRIGGER ALL;

SELECT
  xt.add_column('ccbank', 'ccbank_id',            'SERIAL', 'NOT NULL', 'public'),
  xt.add_column('ccbank', 'ccbank_ccard_type',      'TEXT', 'NOT NULL', 'public'),
  xt.add_column('ccbank', 'ccbank_bankaccnt_id', 'INTEGER', NULL,       'public');

ALTER TABLE ccbank DROP CONSTRAINT IF EXISTS ccbank_ccbank_ccard_type_check;

SELECT
  xt.add_constraint('ccbank', 'ccbank_pkey', 'PRIMARY KEY (ccbank_id)', 'public'),
  xt.add_constraint('ccbank', 'ccbank_ccbank_ccard_type_key',
                    'UNIQUE (ccbank_ccard_type)', 'public'),
  xt.add_constraint('ccbank', 'ccbank_ccbank_ccard_type_fkey',
                    'FOREIGN KEY (ccbank_ccard_type) REFERENCES fundstype(fundstype_code)', 'public'),
  xt.add_constraint('ccbank', 'ccbank_ccbank_bankaccnt_id_fkey',
                    'FOREIGN KEY (ccbank_bankaccnt_id) REFERENCES bankaccnt(bankaccnt_id)', 'public');

ALTER TABLE public.ccbank ENABLE TRIGGER ALL;
