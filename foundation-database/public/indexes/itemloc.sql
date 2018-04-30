select xt.add_index('itemloc', 'itemloc_itemsite_id', 'itemloc_itemsite_idx', 'btree', 'public');
select xt.add_index('itemloc', 'itemloc_location_id', 'itemloc_location_idx', 'btree', 'public');
