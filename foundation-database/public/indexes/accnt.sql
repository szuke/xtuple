-- xt.add_index() does not create unique indexes!
DO $$
BEGIN
  IF NOT EXISTS(SELECT 1
                  FROM pg_indexes
                 WHERE schemaname = 'public'
                   AND tablename  = 'accnt'
                   AND indexname  = 'accnt_unique_idx') THEN
    CREATE UNIQUE INDEX accnt_unique_idx ON accnt USING btree (accnt_number, accnt_profit, accnt_sub, accnt_company);
  END IF;
END $$;
