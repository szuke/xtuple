CREATE OR REPLACE FUNCTION isInventoryItemsite(pItemsiteId INTEGER)
RETURNS BOOLEAN AS $$
-- Copyright (c) 1999-2017 by OpenMFG LLC, d/b/a xTuple. 
-- See www.xtuple.com/CPAL for the full text of the software license.
-- pInvhistid is the original transaction to be returned, reversed, etc.
DECLARE
  _r RECORD;

BEGIN

  SELECT item_number, warehous_code,
    itemsite_controlmethod != 'N' AND (item_type NOT IN ('R', 'F')) AS inventory INTO _r
  FROM itemsite 
    JOIN item ON itemsite_item_id=item_id
    JOIN whsinfo ON itemsite_warehous_id = warehous_id
  WHERE itemsite_id=pItemsiteId;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Could not find itemsite information for itemsite_id % '
      '[xtuple: isInventoryItemsite, -1, %]', pItemsiteId, pItemsiteId;
  END IF;

  RETURN _r.inventory;

END;
$$ LANGUAGE plpgsql;
