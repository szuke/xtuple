select xt.add_index('comment', 'comment_date', 'comment_date_idx', 'btree', 'public'),
       xt.add_index('comment', 'comment_source, comment_source_id', 'comment_comment_source_idx', 'btree', 'public'),
       xt.add_index('comment', 'comment_source_id', 'comment_source_id_idx', 'btree', 'public'),
       xt.add_index('comment', 'comment_user COLLATE pg_catalog."default"', 'comment_user_idx', 'btree', 'public');
