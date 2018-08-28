DROP FUNCTION IF EXISTS numOfDatabaseUsers();

CREATE OR REPLACE FUNCTION numOfDatabaseUsers(pAppName TEXT DEFAULT NULL) RETURNS INTEGER AS $$
-- Copyright (c) 1999-2018 by OpenMFG LLC, d/b/a xTuple.
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  _count INTEGER;
BEGIN
  SELECT count(DISTINCT pg_locks.pid)
    INTO _count
    FROM pg_locks    
    LEFT JOIN pg_stat_activity ON pg_stat_activity.pid = pg_locks.pid
   WHERE pg_locks.objsubid = 2
     AND pg_stat_activity.datname = current_database()
     AND CASE WHEN (trim(coalesce(pAppName, '')) = '') THEN true ELSE application_name = pAppName END;

  IF (_count IS NULL) THEN
    _count := 0;
  END IF;

  RETURN _count;
END;
$$ LANGUAGE plpgsql;
