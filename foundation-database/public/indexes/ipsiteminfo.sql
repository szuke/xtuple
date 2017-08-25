select xt.add_index('ipsiteminfo', 'ipsitem_item_id', 'ipsitem_item_id_idx', 'btree', 'public');
select xt.add_index('ipsiteminfo', 'ipsitem_prodcat_id', 'ipsitem_prodcat_id_idx', 'btree', 'public');