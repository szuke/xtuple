
CREATE OR REPLACE FUNCTION isControlledItemsite(pItemsiteId INTEGER) RETURNS BOOLEAN AS $$
-- Copyright (c) 1999-2017 by OpenMFG LLC, d/b/a xTuple. 
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  _controlled BOOLEAN := false;

BEGIN
  SELECT isInventoryItemsite(pItemsiteId)
  	AND (itemsite_loccntrl OR itemsite_controlmethod IN ('L', 'S')) INTO _controlled
  FROM itemsite
  WHERE itemsite_id = pItemsiteId;

  IF NOT FOUND THEN
    RETURN false; -- RAISE EXCEPTION instead?
  ELSE
    RETURN _controlled;
  END IF;
END;
$$ LANGUAGE plpgsql;

