SELECT xt.create_table('invhist', 'public');

ALTER TABLE public.invhist DISABLE TRIGGER ALL;

DROP VIEW IF EXISTS xm.inventory_history CASCADE;

SELECT
  xt.add_column('invhist', 'invhist_ordhead_id', 'INTEGER', 'NULL', 'public'),
  xt.add_column('invhist', 'invhist_orditem_id', 'INTEGER', 'NULL', 'public'),
  xt.add_column('invhist', 'invhist_value_before', 'NUMERIC', 'NOT NULL', 'public'),
  xt.add_column('invhist', 'invhist_value_after', 'NUMERIC', 'NOT NULL', 'public');

ALTER TABLE public.invhist ENABLE TRIGGER ALL;

COMMENT ON COLUMN invhist.invhist_ordhead_id IS 'Order head ID i.e. cohead_id, rahead_id, invchead_id, etc. NULL for non-order transactions i.e. AD.';
COMMENT ON COLUMN invhist.invhist_orditem_id IS 'Order item ID i.e. coitem_id, raitem_id, invcitem_id, etc. NULL for non-order transactions i.e. AD.';
