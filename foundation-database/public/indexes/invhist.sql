select xt.add_index('invhist', 'invhist_hasdetail', 'invhist_hasdetail', 'btree', 'public');
select xt.add_index('invhist', 'invhist_ordnumber', 'invhist_invhist_ordnumber_idx', 'btree', 'public');
select xt.add_index('invhist', 'invhist_itemsite_id', 'invhist_itemsite_id', 'btree', 'public');
select xt.add_index('invhist', 'invhist_series', 'invhist_series', 'btree', 'public');
select xt.add_index('invhist', 'invhist_transdate', 'invhist_transdate', 'btree', 'public');
select xt.add_index('invhist', 'invhist_transtype', 'invhist_transtype', 'btree', 'public');
