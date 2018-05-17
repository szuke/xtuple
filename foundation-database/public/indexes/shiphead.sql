select xt.add_index('shiphead', 'shiphead_order_id', 'shiphead_order_id_idx', 'btree', 'public');
select xt.add_index('shiphead', 'shiphead_shipped', 'shiphead_shipped_idx', 'btree', 'public');
