DROP FUNCTION IF EXISTS postCost(INTEGER);

CREATE OR REPLACE FUNCTION postCost(pItemcostid INTEGER) RETURNS BOOLEAN AS $$
-- Copyright (c) 1999-2018 by OpenMFG LLC, d/b/a xTuple.
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  _p RECORD;

BEGIN

  SELECT round(currToBase(itemcost_curr_id, itemcost_actcost, CURRENT_DATE),6) AS newcost,
         itemcost_curr_id, CURRENT_DATE AS effective,
         item_number,
         itemcost_stdcost AS oldcost,
         costelem_type AS costelem     INTO _p
  FROM itemcost
  JOIN item ON (itemcost_item_id=item_id)
  JOIN costelem ON (itemcost_costelem_id=costelem_id)
  WHERE itemcost_id=pItemcostid;

  IF (_p.newcost IS NULL) THEN
      RAISE EXCEPTION 'There is no valid Exchange Rate for this currency. (%, %)',
                  _p.itemcost_curr_id, _p.effective;
      RETURN FALSE;
  END IF;

  RETURN updateStdCost(pItemcostid, _p.newcost, _p.oldcost, 'Post Cost',
               format('Post Actual Cost to Standard for item %s, cost element %s'
                       , _p.item_number, _p.costelem));

END;
$$ LANGUAGE plpgsql;
