select xt.add_index('shipitem', 'shipitem_orderitem_id', 'shipitem_orderitem_id_idx', 'btree', 'public');
select xt.add_index('shipitem', 'shipitem_invcitem_id', 'shipitem_invcitem_id_idx', 'btree', 'public');
select xt.add_index('shipitem', 'shipitem_shiphead_id', 'shipitem_shiphead_id_idx', 'btree', 'public');
