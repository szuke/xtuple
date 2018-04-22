UPDATE cntct
   SET cntct_created = (SELECT MIN(comment_date)
                          FROM comment
                         WHERE comment_source='T'
                           AND comment_source_id=cntct_id)
 WHERE cntct_created IS NULL;
