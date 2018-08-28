CREATE OR REPLACE FUNCTION deleteCntct(pCntctId INTEGER, pCascade BOOLEAN) RETURNS BOOLEAN AS $$
-- Copyright (c) 1999-2017 by OpenMFG LLC, d/b/a xTuple. 
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  _fk RECORD;
  _seq INTEGER;
  _col TEXT;
  _qry TEXT;

BEGIN
  FOR _fk IN
    SELECT pg_namespace.nspname AS schema, child.relname AS table, conkey, conrelid
    FROM pg_constraint
    JOIN pg_class child ON conrelid=child.oid
    JOIN pg_namespace ON child.relnamespace=pg_namespace.oid
    JOIN pg_class parent ON confrelid=parent.oid
   WHERE parent.relname='cntct'
     AND child.relname NOT IN ('cntctaddr', 'cntctdata', 'cntcteml',
                               'cohead',    'pohead',    'quhead',   'tohead',
                               'cntctsel',  'cntctmrgd', 'mrghist',  'trgthist')
  LOOP
    IF (ARRAY_UPPER(_fk.conkey, 1) > 1) THEN
      RAISE EXCEPTION 'Cannot check dependencies when the contact is one of multiple foreign key columns (%.%) [xtuple: deleteCntct, -1, %, %]',
      _fk.schema, _fk.table, _fk.schema, _fk.table;
    END IF;

    _seq := _fk.conkey[1];

    SELECT attname INTO _col
      FROM pg_attribute
      JOIN pg_class ON attrelid=pg_class.oid
     WHERE pg_class.oid=_fk.conrelid
       AND attnum=_seq;

    IF pCascade THEN
      EXECUTE format('DELETE FROM %I.%I
                       WHERE %I=%L;', _fk.schema, _fk.table, _col, pCntctId);
    ELSE
      EXECUTE format('UPDATE %I.%I
                         SET %I=NULL
                       WHERE %I=%L;', _fk.schema, _fk.table, _col, _col, pCntctId);
    END IF;

  END LOOP;

  DELETE FROM cntct
   WHERE cntct_id=pCntctId;

  RETURN true;

END;
$$ LANGUAGE plpgsql;
