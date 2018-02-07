CREATE OR REPLACE FUNCTION addrUseCount(pAddrId INTEGER) RETURNS integer STABLE AS $$
-- Copyright (c) 1999-2017 by OpenMFG LLC, d/b/a xTuple. 
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  _fk    RECORD;
  _col   TEXT;
  _count INTEGER := 0;

BEGIN
  -- Determine where this address is used by analyzing foreign key linkages
  -- TO DO: Can this be rationalized with cntctused(int)?
  FOR _fk IN
    SELECT pg_namespace.nspname AS schemaname, con.relname AS tablename,
           conkey AS seq, conrelid AS class_id 
      FROM pg_constraint
      JOIN pg_class f   ON confrelid = f.oid
      JOIN pg_class con ON conrelid  = con.oid
      JOIN pg_namespace ON con.relnamespace = pg_namespace.oid
    WHERE f.relname = 'addr'
      AND con.relname NOT IN ('pohead') -- exception(s) where address key doesn't actually drive document information
  LOOP
    IF (ARRAY_UPPER(_fk.seq,1) > 1) THEN
      RAISE EXCEPTION 'Checks to tables where the address is one of multiple foreign key columns is not supported. Error on Table: %.% [xtuple: addrusecount, -1, %]',
        _fk.schemaname, _fk.tablename, pAddrId;
    END IF;
    
    -- Get the specific column name
    SELECT attname INTO _col
      FROM pg_attribute
      JOIN pg_class ON attrelid = pg_class.oid
     WHERE pg_class.oid = _fk.class_id
       AND attnum       = _fk.seq[1];

    EXECUTE format('SELECT COUNT(*) + %L AS count FROM %I.%I WHERE %I = %L;',
                   _count, _fk.schemaname, _fk.tablename, _col, pAddrId)
       INTO _count;
  END LOOP;

  RETURN _count;
END;
$$ LANGUAGE plpgsql;
