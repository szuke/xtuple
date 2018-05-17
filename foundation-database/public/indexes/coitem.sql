select xt.add_index('coitem', 'coitem_cohead_id', 'coitem_cohead_id_key', 'btree', 'public');
select xt.add_index('coitem', 'coitem_itemsite_id', 'coitem_itemsite_id', 'btree', 'public');
select xt.add_index('coitem', 'coitem_linenumber', 'coitem_linenumber_key', 'btree', 'public');
select xt.add_index('coitem', 'coitem_status', 'coitem_status_key', 'btree', 'public');
