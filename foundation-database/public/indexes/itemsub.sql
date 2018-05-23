select xt.add_index('itemsub', 'itemsub_parent_item_id', 'itemsub_parent_item_id_key', 'btree', 'public');
select xt.add_index('itemsub', 'itemsub_sub_item_id', 'itemsub_sub_item_id_key', 'btree', 'public');
