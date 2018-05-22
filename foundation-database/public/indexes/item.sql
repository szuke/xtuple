select xt.add_index('item', 'item_classcode_id', 'item_classcode_id', 'btree', 'public');
select xt.add_index('item', 'item_prodcat_id', 'item_prodcat_id_idx', 'btree', 'public');
select xt.add_index('item', 'item_upccode', 'item_upccode_idx', 'btree', 'public');
