CREATE OR REPLACE FUNCTION deleteCheck(INTEGER) RETURNS INTEGER AS $$
-- Copyright (c) 1999-2018 by OpenMFG LLC, d/b/a xTuple.
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  pCheckid ALIAS FOR $1;

BEGIN
  IF (SELECT (NOT checkhead_void) OR checkhead_posted OR checkhead_replaced
              OR checkhead_deleted
              OR (checkhead_ach_batch IS NOT NULL AND checkhead_printed AND NOT checkhead_void)
      FROM checkhead
      WHERE (checkhead_id=pCheckid) ) THEN
    RAISE EXCEPTION 'Cannot delete this Payment because either it has not been voided, it has already been posted or replaced [xtuple: deleteCheck, -1]';
  END IF;

  UPDATE checkhead
  SET checkhead_deleted=TRUE
  WHERE (checkhead_id=pCheckid);

  RETURN 1;

END;
$$ LANGUAGE 'plpgsql';
