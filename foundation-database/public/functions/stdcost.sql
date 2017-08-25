CREATE OR REPLACE FUNCTION stdCost(INTEGER) RETURNS NUMERIC STABLE AS $$
-- Copyright (c) 1999-2014 by OpenMFG LLC, d/b/a xTuple. 
-- See www.xtuple.com/CPAL for the full text of the software license.
BEGIN
  RETURN stdCost($1, NULL);
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION stdCost(INTEGER, INTEGER) RETURNS NUMERIC STABLE AS $$
-- Copyright (c) 1999-2014 by OpenMFG LLC, d/b/a xTuple. 
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  pItemid ALIAS FOR $1;
  pBomitemid ALIAS FOR $2;
  _cost NUMERIC;

BEGIN

  IF (EXISTS(SELECT 1 FROM bomitemcost WHERE bomitemcost_bomitem_id=pBomitemid)) THEN
    SELECT SUM(bomitemcost_stdcost) INTO _cost
    FROM bomitemcost
    WHERE bomitemcost_bomitem_id=pBomitemid;
  ELSE
    SELECT SUM(itemcost_stdcost) INTO _cost
    FROM itemcost
    WHERE itemcost_item_id=pItemid;
  END IF;

  IF (_cost IS NULL) THEN
    RETURN 0;
  ELSE
    RETURN _cost;
  END IF;

END;
$$ LANGUAGE 'plpgsql';
