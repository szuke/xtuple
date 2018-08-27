CREATE OR REPLACE FUNCTION formatDocumentTarget(pSourceType TEXT, pSourceId INTEGER)
  RETURNS TEXT AS $$
-- Copyright (c) 1999-2018 by OpenMFG LLC, d/b/a xTuple.
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  _srctable TEXT;
  _srcnumber TEXT;
  _srckey TEXT;
  _desc TEXT;
  _number TEXT;
BEGIN
  IF (pSourceType IS NULL OR pSourceId IS NULL) THEN
    RAISE EXCEPTION 'You must supply a Source Type and Id [xtuple: formatDocumentTarget, -1]';
  END IF;

  SELECT source_table, source_number_field, source_key_field, source_descrip
   INTO  _srctable, _srcnumber, _srckey, _desc
   FROM  source
  WHERE  source_name = pSourceType;

  IF (NOT FOUND) THEN
    RAISE EXCEPTION 'An invalid Source Type was input [xtuple: formatDocumentTarget, -2]';
  END IF;

  BEGIN
    EXECUTE format('SELECT %s FROM %I WHERE %I = %s', _srcnumber, _srctable, _srckey, pSourceId) INTO STRICT _number;
  EXCEPTION
    WHEN undefined_table THEN
      RETURN CONCAT(_desc, ' ' , pSourceId);
    WHEN OTHERS THEN RAISE EXCEPTION '% %', SQLSTATE, SQLERRM;
  END;

  RETURN CONCAT(_desc, ' ', _number);

END;
$$ LANGUAGE plpgsql;
