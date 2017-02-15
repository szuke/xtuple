SELECT xt.add_column('cohist', 'cohist_listprice',     'NUMERIC(16,4)', NULL, 'public');
SELECT xt.add_column('cohist', 'cohist_billtocountry', 'TEXT',          NULL, 'public');
SELECT xt.add_column('cohist', 'cohist_shiptocountry', 'TEXT',          NULL, 'public');
SELECT xt.add_column('cohist', 'cohist_coitem_id',     'INTEGER',       NULL, 'public');
SELECT xt.add_column('cohist', 'cohist_invchead_id',   'INTEGER',       NULL, 'public');
SELECT xt.add_column('cohist', 'cohist_invcitem_id',   'INTEGER',       NULL, 'public');

COMMENT ON COLUMN public.cohist.cohist_listprice   IS 'List price of Item.';
COMMENT ON COLUMN public.cohist.cohist_coitem_id   IS 'Sales Order line ID that generated this history record.';
COMMENT ON COLUMN public.cohist.cohist_invchead_id IS 'Invoice ID that generated this history record.';
COMMENT ON COLUMN public.cohist.cohist_invcitem_id IS 'Invoice line ID that generated this history record.';

SELECT xt.add_constraint('cohist',
                         'cohist_cohist_coitem_id_fkey',
                         'FOREIGN KEY (cohist_coitem_id) REFERENCES public.coitem (coitem_id)
                          MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION',
                         'public');

SELECT xt.add_constraint('cohist',
                         'cohist_cohist_invchead_id_fkey',
                         'FOREIGN KEY (cohist_invchead_id) REFERENCES public.invchead (invchead_id)
                          MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION',
                         'public');

SELECT xt.add_constraint('cohist',
                         'cohist_cohist_invcitem_id_fkey',
                         'FOREIGN KEY (cohist_invcitem_id) REFERENCES public.invcitem (invcitem_id)
                          MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION',
                         'public');
