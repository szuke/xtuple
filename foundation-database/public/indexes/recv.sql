--CREATE INDEX recv_itemsite_id_index ON recv USING btree (recv_itemsite_id);
select xt.add_index('recv', 'recv_itemsite_id', 'recv_itemsite_id_idx', 'btree', 'public');
select xt.add_index('recv', 'recv_order_type, recv_orderitem_id', 'recv_ordertypeid_idx', 'btree', 'public');
