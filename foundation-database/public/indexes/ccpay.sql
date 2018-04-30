select xt.add_index('ccpay', 'ccpay_ccard_id', 'ccpay_ccard_id_idx', 'btree', 'public');
select xt.add_index('ccpay', 'ccpay_cust_id', 'ccpay_cust_id_idx', 'btree', 'public');
select xt.add_index('ccpay', 'ccpay_order_number', 'ccpay_order_number_idx', 'btree', 'public');
