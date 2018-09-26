CREATE OR REPLACE FUNCTION updateStdCost(pItemcostid INTEGER,
                                         pNewcost NUMERIC,
                                         pOldcost NUMERIC,
                                         pDocNumber TEXT,
                                         pNotes TEXT) RETURNS BOOLEAN AS $$
-- Copyright (c) 1999-2018 by OpenMFG LLC, d/b/a xTuple.
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
    _itemcostid	INTEGER;
    _r		RECORD;
    _newcost	NUMERIC;
    _oldcost	NUMERIC;
    _invhistId  INTEGER;

BEGIN
  IF (pNewcost IS NULL) THEN
    _newcost := 0;
  ELSE
    _newcost := pNewcost;
  END IF;
  IF (pOldcost IS NULL) THEN
    _oldcost := 0;
  ELSE
    _oldcost := pOldcost;
  END IF;

  UPDATE itemcost
  SET itemcost_stdcost=_newcost,
      itemcost_posted=CURRENT_DATE
  WHERE (itemcost_id=pItemcostid);

--  Distribute to G/L, debit Inventory Asset, credit Inventory Cost Variance
  FOR _r IN SELECT itemsite_id, itemsite_item_id, itemsite_qtyonhand AS totalQty,
                   costcat_invcost_accnt_id, costcat_asset_accnt_id,
                   itemsite_costmethod, itemsite_value, uom_name
            FROM itemcost, itemsite, costcat, item, uom
            WHERE ( (itemsite_item_id=itemcost_item_id)
             AND (itemsite_costcat_id=costcat_id)
             AND (itemsite_item_id=item_id)
             AND (item_inv_uom_id=uom_id)
             AND (itemsite_costmethod = 'S')
             AND (itemsite_qtyonhand <> 0.0)
             AND (itemcost_id=pItemcostid) ) LOOP
--    IF (_newcost <> _oldcost) THEN
--      RAISE NOTICE 'itemcost_id = %, Qty = %, Old Cost = %, New Cost = %', pItemcostid, _r.totalQty, _oldcost, _newcost;
--    END IF;
    PERFORM insertGLTransaction( 'P/D', '', pDocNumber, pNotes,
                                 _r.costcat_invcost_accnt_id, _r.costcat_asset_accnt_id, _r.itemsite_id,
                                 ((_newcost - _oldcost) * _r.totalQty),
                                 CURRENT_DATE );
--  Update Itemsite Value if not Average Cost
--      RAISE NOTICE 'itemsite_id = %, Qty = %, New Cost = %', _r.itemsite_id, _r.totalQty, _newcost;
    UPDATE itemsite SET itemsite_value=(_r.totalQty * stdCost(itemsite_item_id))
    WHERE (itemsite_id=_r.itemsite_id);

--  Add an InvHist record for reconciliation purposes only if value changes > cost threshold (zero qty. movement)
    IF (ABS(_r.itemsite_value - round(_r.totalQty * stdCost(_r.itemsite_item_id),2)) > 0) THEN
      INSERT INTO invhist
      ( invhist_itemsite_id, invhist_transdate, invhist_transtype, invhist_invqty, invhist_invuom,
        invhist_qoh_before, invhist_qoh_after, invhist_unitcost,
        invhist_comments, invhist_costmethod, invhist_value_before,
        invhist_value_after, invhist_series)
      SELECT _r.itemsite_id, CURRENT_TIMESTAMP, 'SC', 0.0, _r.uom_name,
             _r.totalQty, _r.totalQty, _r.totalQty * stdCost(_r.itemsite_item_id) - _r.itemsite_value,
             pNotes, 'S', _r.itemsite_value,
             round(_r.totalQty * stdCost(_r.itemsite_item_id), 2), NEXTVAL('itemloc_series_seq')
      RETURNING invhist_id INTO _invhistId;

      IF (fetchMetricBool('EnableAsOfQOH')) THEN
        PERFORM postIntoInvBalance(_invhistId);
      END IF;
    END IF;

  END LOOP;

  IF (_newcost = 0) THEN
    DELETE FROM itemcost
    WHERE (itemcost_id=pItemcostid);
  END IF;

  RETURN TRUE;

END;
$$ LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION updateStdCost(INTEGER, TEXT, BOOLEAN, NUMERIC) RETURNS INTEGER AS $$
-- Copyright (c) 1999-2018 by OpenMFG LLC, d/b/a xTuple.
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
    pItemid	ALIAS FOR $1;
    pCostType	ALIAS FOR $2;
    pLevel	ALIAS FOR $3;
    pCost	ALIAS FOR $4;
    _newCost	NUMERIC;
    _oldCost	NUMERIC := 0;
    _itemcostid	INTEGER;
    _updateRet	BOOLEAN;
    _itemNumber TEXT;

BEGIN
    IF (pCost IS NULL) THEN
	_newCost = 0;
    ELSE
	_newCost = pCost;
    END IF;

    SELECT itemcost_id, itemcost_stdCost, item_number
	INTO _itemcostid, _oldCost, _itemNumber
    FROM itemcost, costelem, item
    WHERE ((itemcost_costelem_id=costelem_id)
      AND  (itemcost_item_id=item_id)
      AND  (item_id=pItemid)
      AND  (itemcost_lowlevel=pLevel)
      AND  (costelem_type=pCosttype));
--    RAISE NOTICE 'updateStdCost(%, %, %, %) has itemcost_id % and stdcost %',
--    				pItemid, pCostType, plevel, _newCost, _itemcostid, _oldCost;

    IF (NOT FOUND) AND (_newCost > 0) THEN
	SELECT NEXTVAL('itemcost_itemcost_id_seq') INTO _itemcostid;
--	RAISE NOTICE 'updateStdCost() inserting itemcost_id %', _itemcostid;
	INSERT INTO itemcost
	    (itemcost_id, itemcost_item_id, itemcost_costelem_id,
	     itemcost_lowlevel, itemcost_stdcost, itemcost_posted,
	     itemcost_actcost, itemcost_updated)
	SELECT
	      _itemcostid, pItemid, costelem_id,
	      pLevel, _newCost, CURRENT_DATE,
	      0, CURRENT_DATE
	FROM costelem
	WHERE (costelem_type=pCosttype);
    END IF;

    IF (_itemcostid IS NOT NULL) THEN
	SELECT updateStdCost(_itemcostid, _newCost, _oldCost, 'Post Cost',
               ('Set Standard Cost - ' || pCosttype || ' for item ' || _itemNumber)) INTO _updateRet;
	IF (_updateRet) THEN
	    RETURN _itemcostid;
	END IF;
    END IF;

    RETURN -1;
END;
$$ LANGUAGE plpgsql;
