CREATE OR REPLACE FUNCTION cntctselect(integer, boolean) RETURNS boolean AS $$
-- Copyright (c) 1999-2015 by OpenMFG LLC, d/b/a xTuple.
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  pCntctId ALIAS FOR $1;
  pTarget ALIAS FOR $2;

BEGIN
  CREATE TEMPORARY TABLE IF NOT EXISTS cntctsel
    (LIKE public.cntctsel INCLUDING ALL)
    ON COMMIT PRESERVE ROWS;

  -- If target, delete any other targets
  IF (pTarget) THEN
    DELETE FROM cntctsel WHERE cntctsel_target;
  END IF;
  
  -- Delete any previous selection of this contact
  DELETE FROM cntctsel WHERE cntctsel_cntct_id=pCntctId;

  -- Add this contact in appropriate selection state
  INSERT INTO cntctsel (cntctsel_cntct_id, cntctsel_target) VALUES (pCntctId,pTarget);

  RETURN true;
END;
$$ LANGUAGE 'plpgsql';
