SELECT xt.create_table('bankrecitem', 'public');

ALTER TABLE public.bankrecitem DISABLE TRIGGER ALL;

SELECT
  xt.add_column('bankrecitem', 'bankrecitem_id',          'SERIAL', 'NOT NULL',      'public'),
  xt.add_column('bankrecitem', 'bankrecitem_bankrec_id', 'INTEGER', 'NOT NULL',      'public'),
  xt.add_column('bankrecitem', 'bankrecitem_source',        'TEXT', 'NOT NULL',      'public'),
  xt.add_column('bankrecitem', 'bankrecitem_source_id',  'INTEGER', 'NOT NULL',      'public'),
  xt.add_column('bankrecitem', 'bankrecitem_cleared',    'BOOLEAN', 'DEFAULT false', 'public'),
  xt.add_column('bankrecitem', 'bankrecitem_curr_rate',  'NUMERIC', NULL,            'public'),
  xt.add_column('bankrecitem', 'bankrecitem_amount',     'NUMERIC', NULL,            'public'),
  xt.add_column('bankrecitem', 'bankrecitem_effdate',       'DATE', NULL,            'public');

-- #28170 Create foreign key between bankrec tables.
-- First clean out possible orphaned records

DELETE FROM bankrecitem WHERE bankrecitem_id IN 
(SELECT bankrecitem_id
  FROM bankrecitem LEFT JOIN bankrec ON bankrec_id = bankrecitem_bankrec_id
  WHERE bankrec_id IS NULL);


select xt.add_constraint('bankrecitem', 'bankrecitem_pkey',
                         'PRIMARY KEY (bankrecitem_id)', 'public'),
       xt.add_constraint('bankrecitem', 'bankrecitem_bankrec_id_fkey', 
       'FOREIGN KEY (bankrecitem_bankrec_id) REFERENCES public.bankrec (bankrec_id)
        ON UPDATE NO ACTION ON DELETE CASCADE;', 'public');

ALTER TABLE public.bankrecitem ENABLE TRIGGER ALL;


COMMENT ON TABLE bankrecitem IS 'Posted Bank Reconciliation Line Item information';
