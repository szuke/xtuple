CREATE OR REPLACE FUNCTION returnWoMaterial(pWomatlid INTEGER,
                                            pQty NUMERIC,
                                            pGlDistTS TIMESTAMP WITH TIME ZONE) RETURNS INTEGER AS $$
-- Copyright (c) 1999-2017 by OpenMFG LLC, d/b/a xTuple. 
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  _itemlocSeries INTEGER;

BEGIN

  SELECT NEXTVAL('itemloc_series_seq') INTO _itemlocSeries;
  RETURN returnWoMaterial(pWomatlid, pQty, _itemlocSeries, pGlDistTS);

END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS returnWoMaterial(INTEGER, INTEGER, TIMESTAMP WITH TIME ZONE, INTEGER);
DROP FUNCTION IF EXISTS returnWoMaterial(INTEGER, INTEGER, TIMESTAMP WITH TIME ZONE, INTEGER, BOOLEAN);

CREATE OR REPLACE FUNCTION returnWoMaterial(pWomatlid INTEGER,
                                            pItemlocSeries INTEGER,
                                            pGlDistTS TIMESTAMP WITH TIME ZONE,
                                            pInvhistId INTEGER)
RETURNS INTEGER AS $$
-- Copyright (c) 1999-2017 by OpenMFG LLC, d/b/a xTuple. 
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  _woNumber TEXT;
  _invhistid INTEGER;
  _itemlocSeries INTEGER := COALESCE(pItemlocSeries, NEXTVAL('itemloc_series_seq'));
  _invqty NUMERIC;
  _womatlqty NUMERIC;
  _cost NUMERIC := 0;
  _rows INTEGER;
  
BEGIN
  IF (_itemlocSeries = 0) THEN
    _itemlocSeries := NEXTVAL('itemloc_series_seq');
  END IF;

  SELECT invhist_invqty, invhist_invqty * invhist_unitcost INTO _invqty, _cost
  FROM invhist
  WHERE (invhist_id=pInvhistId);

  GET DIAGNOSTICS _rows = ROW_COUNT;
  
  IF (_rows = 0) THEN
    RAISE EXCEPTION 'No transaction found for invhist_id % [xtuple: returnWoMaterial, -2, %]', pInvhistId, pInvhistId;
  END IF;
  
  SELECT itemuomtouom(itemsite_item_id, NULL, womatl_uom_id, _invqty)
    INTO _womatlqty
    FROM womatl, itemsite
    WHERE((womatl_itemsite_id=itemsite_id)
     AND (womatl_id=pWomatlid));

  GET DIAGNOSTICS _rows = ROW_COUNT;
  
  IF (_rows = 0) THEN
    _womatlqty := _invqty;
  END IF;

  IF ( SELECT (
         CASE WHEN (womatl_qtyreq >= 0) THEN
           womatl_qtyiss < _womatlqty
         ELSE
           womatl_qtyiss > _womatlqty
         END )
       FROM womatl
       WHERE ( womatl_id=pWomatlid ) ) THEN
    RETURN 0;
  END IF;

  SELECT formatWoNumber(womatl_wo_id) INTO _woNumber
  FROM womatl
  WHERE (womatl_id=pWomatlid);

  -- Post the transaction
  SELECT postInvTrans( ci.itemsite_id, 'IM', (_invqty * -1), 
                       'W/O', 'WO', _woNumber, '',
                       ('Return ' || item_number || ' from Work Order'),
                       getPrjAccntId(wo_prj_id, pc.costcat_wip_accnt_id), cc.costcat_asset_accnt_id, _itemlocSeries, pGlDistTS,
                       -- Cost will be ignored by Standard Cost items sites
                       _cost, pInvhistId,
                       NULL, FALSE, wo_id, womatl_id) INTO _invhistid
    FROM womatl, wo,
         itemsite AS ci, costcat AS cc,
         itemsite AS pi, costcat AS pc,
         item
   WHERE((womatl_itemsite_id=ci.itemsite_id)
     AND (ci.itemsite_costcat_id=cc.costcat_id)
     AND (womatl_wo_id=wo_id)
     AND (wo_itemsite_id=pi.itemsite_id)
     AND (pi.itemsite_costcat_id=pc.costcat_id)
     AND (ci.itemsite_item_id=item_id)
     AND (womatl_id=pWomatlid) );

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Could not post inventory transaction: missing cost category or itemsite for 
      womatl_id % [xtuple: returnWoMaterial, -3, %]', pWomatlid, pWomatlid;
  END IF;

--  Create linkage to the transaction created
  INSERT INTO womatlpost (womatlpost_womatl_id,womatlpost_invhist_id)
              VALUES (pWomatlid,_invhistid);

--  Decrease the parent W/O's WIP value by the value of the returned components
  UPDATE wo
  SET wo_wipvalue = (wo_wipvalue - (CASE WHEN(itemsite_costmethod IN ('A','J'))
                                              THEN _cost
                                         WHEN(itemsite_costmethod='S')
                                              THEN stdcost(itemsite_item_id) * _invqty
                                         ELSE 0.0 END )),
      wo_postedvalue = (wo_postedvalue - (CASE WHEN(itemsite_costmethod IN ('A','J'))
                                                    THEN _cost
                                               WHEN(itemsite_costmethod='S')
                                                    THEN stdcost(itemsite_item_id) * _invqty
                                               ELSE 0.0 END ))
  FROM womatl, itemsite
  WHERE ( (wo_id=womatl_wo_id)
   AND (womatl_itemsite_id=itemsite_id)
   AND (womatl_id=pWomatlid) );

  UPDATE womatl
  SET womatl_qtyiss = (womatl_qtyiss - _womatlqty),
      womatl_lastreturn = CURRENT_DATE
  WHERE (womatl_id=pWomatlid);

  RETURN _itemlocSeries;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION returnwomaterial(integer, integer, timestamp with time zone, integer) IS 'Returns material by reversing a specific historical transaction';


DROP FUNCTION IF EXISTS returnWoMaterial(INTEGER, NUMERIC, INTEGER, TIMESTAMP WITH TIME ZONE);
DROP FUNCTION IF EXISTS returnWoMaterial(INTEGER, NUMERIC, INTEGER, TIMESTAMP WITH TIME ZONE, BOOLEAN);
DROP FUNCTION IF EXISTS returnWoMaterial(INTEGER, NUMERIC, INTEGER, TIMESTAMP WITH TIME ZONE, BOOLEAN, BOOLEAN);

CREATE OR REPLACE FUNCTION returnWoMaterial(pWomatlid INTEGER,
                                            pQty NUMERIC,
                                            pItemlocSeries INTEGER,
                                            pGlDistTS TIMESTAMP WITH TIME ZONE,
                                            pReqStdCost BOOLEAN DEFAULT FALSE,
                                            pPreDistributed BOOLEAN DEFAULT FALSE,
                                            pPostDistDetail BOOLEAN DEFAULT TRUE) RETURNS INTEGER AS $$
-- Copyright (c) 1999-2017 by OpenMFG LLC, d/b/a xTuple. 
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  _woNumber TEXT;
  _invhistid INTEGER;
  _itemlocSeries INTEGER := COALESCE(pItemlocSeries, NEXTVAL('itemloc_series_seq'));
  _qty NUMERIC;
  _cost NUMERIC := 0;
  _hasControlledItem BOOLEAN := FALSE;

BEGIN
  IF (pPreDistributed AND COALESCE(pItemlocSeries, 0) = 0) THEN 
    RAISE EXCEPTION 'pItemlocSeries is Required when pPreDistributed [xtuple: returnWoMaterial, -5]';
  -- TODO - find why/how passing 0 instead of null for pItemlocSeries
  ELSIF (_itemlocSeries = 0) THEN
    _itemlocSeries := NEXTVAL('itemloc_series_seq');
  END IF;

  -- Check that the womatl has eligible qty to return
  IF ( SELECT (
         CASE WHEN (womatl_qtyreq >= 0) THEN
           womatl_qtyiss < pQty
         ELSE
           womatl_qtyiss > pQty
         END )
       FROM womatl
       WHERE ( womatl_id=pWomatlid ) ) THEN
    -- Can't raise exception because of existing functions that don't pre-filter qty for womatl for a WO
    RAISE WARNING 'No qty to return for womatl_id %', pWomatlid;
    RETURN 0;
  END IF;

  SELECT itemuomtouom(itemsite_item_id, womatl_uom_id, NULL, pQty)
    INTO _qty
    FROM womatl, itemsite
   WHERE((womatl_itemsite_id=itemsite_id)
     AND (womatl_id=pWomatlid));
  IF (NOT FOUND) THEN
    _qty := pQty;
  END IF;

  SELECT formatWoNumber(womatl_wo_id) INTO _woNumber
  FROM womatl
  WHERE (womatl_id=pWomatlid);

  -- Get the cost average
  IF (pReqStdCost) THEN
    SELECT stdcost(itemsite_item_id) * _qty INTO _cost
    FROM womatl, itemsite
    WHERE((womatl_itemsite_id=itemsite_id)
      AND (womatl_id=pWomatlid));
  ELSE
    SELECT SUM(invhist_value_before - invhist_value_after) / SUM(invhist_qoh_before - invhist_qoh_after)  * _qty INTO _cost
    FROM invhist, womatlpost, womatl 
    WHERE((womatlpost_womatl_id=womatl_id) 
     AND (womatlpost_invhist_id=invhist_id) 
     AND (invhist_qoh_before > invhist_qoh_after)
     AND (womatl_id=pWomatlId));
  END IF;

  _cost := COALESCE(_cost, 0); -- make sure it's not a null value

  -- Post the transaction
  SELECT postInvTrans( ci.itemsite_id, 'IM', (_qty * -1), 
                       'W/O', 'WO', _woNumber, '',
                       ('Return ' || item_number || ' from Work Order'),
                       getPrjAccntId(wo_prj_id, pc.costcat_wip_accnt_id), cc.costcat_asset_accnt_id, _itemlocSeries, pGlDistTS,
                       -- Cost will be ignored by Standard Cost items sites
                       _cost, NULL, NULL, pPreDistributed,
                       wo_id, womatl_id),
        isControlledItemsite(ci.itemsite_id) AS controlled INTO _invhistid, _hasControlledItem
    FROM womatl, wo,
         itemsite AS ci, costcat AS cc,
         itemsite AS pi, costcat AS pc,
         item
   WHERE((womatl_itemsite_id=ci.itemsite_id)
     AND (ci.itemsite_costcat_id=cc.costcat_id)
     AND (womatl_wo_id=wo_id)
     AND (wo_itemsite_id=pi.itemsite_id)
     AND (pi.itemsite_costcat_id=pc.costcat_id)
     AND (ci.itemsite_item_id=item_id)
     AND (womatl_id=pWomatlid) );

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Could not post inventory transaction: missing cost category or itemsite for 
      womatl_id % [xtuple: returnWoMaterial, -3, %]', pWomatlid, pWomatlid;
  END IF;

--  Create linkage to the transaction created
  IF (_invhistid != -1) THEN
    INSERT INTO womatlpost (womatlpost_womatl_id,womatlpost_invhist_id)
    VALUES (pWomatlid,_invhistid);
  END IF;

--  Decrease the parent W/O's WIP value by the value of the returned components
  UPDATE wo
  SET wo_wipvalue = (wo_wipvalue - (CASE WHEN(itemsite_costmethod IN ('A','J'))
                                              THEN _cost
                                         WHEN(itemsite_costmethod='S')
                                              THEN stdcost(itemsite_item_id) * _qty
                                         ELSE 0.0 END )),
      wo_postedvalue = (wo_postedvalue - (CASE WHEN(itemsite_costmethod IN ('A','J'))
                                                    THEN _cost
                                               WHEN(itemsite_costmethod='S')
                                                    THEN stdcost(itemsite_item_id) * _qty
                                               ELSE 0.0 END ))
  FROM womatl, itemsite
  WHERE ( (wo_id=womatl_wo_id)
   AND (womatl_itemsite_id=itemsite_id)
   AND (womatl_id=pWomatlid) );

  UPDATE womatl
  SET womatl_qtyiss = (womatl_qtyiss - pQty),
      womatl_lastreturn = CURRENT_DATE
  WHERE (womatl_id=pWomatlid);

  -- Post distribution detail regardless of loc/control methods because postItemlocSeries is required.
  -- If it is a controlled item and the results were 0 something is wrong.
  IF (pPreDistributed AND pPostDistDetail) THEN 
    IF (postDistDetail(_itemlocSeries) <= 0 AND _hasControlledItem) THEN
      RAISE EXCEPTION 'Posting Distribution Detail Returned 0 Results, [xtuple: returnWoMaterial, -6]';
    END IF;
  END IF;

  RETURN _itemlocSeries;

END;
$$ LANGUAGE plpgsql;

