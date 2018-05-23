select xt.add_index('bomitem', 'bomitem_item_id', 'bomitem_bomitem_item_id_idx', 'btree', 'public');
select xt.add_index('bomitem', 'bomitem_effective', 'bomitem_effective_key', 'btree', 'public');
select xt.add_index('bomitem', 'bomitem_expires', 'bomitem_expires_key', 'btree', 'public');
select xt.add_index('bomitem', 'bomitem_parent_item_id', 'bomitem_parent_item_id', 'btree', 'public');
