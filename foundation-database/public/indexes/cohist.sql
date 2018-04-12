select xt.add_index('cohist', 'cohist_cust_id', 'cohist_cust_id', 'btree', 'public');
select xt.add_index('cohist', 'cohist_invcnumber', 'cohist_invcnumber', 'btree', 'public');
select xt.add_index('cohist', 'cohist_itemsite_id', 'cohist_itemsite_id', 'btree', 'public');
select xt.add_index('cohist', 'cohist_shipdate', 'cohist_shipdate', 'btree', 'public');
select xt.add_index('cohist', 'cohist_shipto_id', 'cohist_shipto_id', 'btree', 'public');
