select xt.add_index('poitem', 'poitem_itemsite_id', 'poitem_itemsite_id_key', 'btree', 'public');
select xt.add_index('poitem', 'poitem_itemsite_id, poitem_status, poitem_duedate', 'poitem_itemsite_status_duedate_key', 'btree', 'public');
select xt.add_index('poitem', 'poitem_pohead_id', 'poitem_pohead_id_key', 'btree', 'public');
select xt.add_index('poitem', 'poitem_status', 'poitem_status_key', 'btree', 'public');
