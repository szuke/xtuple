select xt.add_index('charass', 'charass_char_id, charass_target_type', 'charass_char_id_target_type_idx', 'btree', 'public');
select xt.add_index('charass', 'charass_target_type, charass_target_id', 'charass_target_idx', 'btree', 'public');
