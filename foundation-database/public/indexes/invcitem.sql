SELECT
  xt.add_index('invcitem', 'invcitem_invchead_id',                   'invcitem_invcitem_invchead_id_idx', 'btree', 'public'),
  xt.add_index('invcitem', 'invcitem_item_id, invcitem_warehous_id', 'invcitem_invcitem_itemsite_id_idx', 'btree', 'public'),
  xt.add_index('invcitem', 'invcitem_coitem_id',                     'invcitem_invcitem_coitem_id_idx',   'btree', 'public');
