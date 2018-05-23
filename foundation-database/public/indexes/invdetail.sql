select xt.add_index('invdetail', 'invdetail_invcitem_id', 'invdetail_invdetail_invcitem_id_idx', 'btree', 'public');
select xt.add_index('invdetail', 'invdetail_invhist_id', 'invdetail_invhist_id', 'btree', 'public');
