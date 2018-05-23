select xt.add_index('itemsite', 'itemsite_active', 'itemsite_active_key', 'btree', 'public');
select xt.add_index('itemsite', 'itemsite_item_id', 'itemsite_item_id_key', 'btree', 'public');
select xt.add_index('itemsite', 'itemsite_plancode_id', 'itemsite_plancode_id_key', 'btree', 'public');
select xt.add_index('itemsite', 'itemsite_warehous_id', 'itemsite_warehous_id_key', 'btree', 'public');
