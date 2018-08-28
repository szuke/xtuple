CREATE OR REPLACE FUNCTION issueWoMaterial(INTEGER, NUMERIC, INTEGER, BOOLEAN) RETURNS INTEGER AS $$
-- Copyright (c) 1999-2017 by OpenMFG LLC, d/b/a xTuple. 
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  pWomatlid ALIAS FOR $1;
  pQty ALIAS FOR $2;
  pItemlocSeries ALIAS FOR $3;
  pMarkPush ALIAS FOR $4;
  _itemlocSeries INTEGER;

BEGIN
  RETURN issueWoMaterial(pWomatlid, pQty, pItemlocSeries,now());
END;
$$ LANGUAGE 'plpgsql';

DROP FUNCTION IF EXISTS issueWoMaterial(INTEGER, NUMERIC, INTEGER, BOOLEAN, TIMESTAMP WITH TIME ZONE);
CREATE OR REPLACE FUNCTION issueWoMaterial(pWomatlid INTEGER, 
                                           pQty NUMERIC, 
                                           pItemlocSeries INTEGER, 
                                           pMarkPush BOOLEAN, 
                                           pGlDistTS TIMESTAMP WITH TIME ZONE, 
                                           pPreDistributed BOOLEAN DEFAULT FALSE) RETURNS INTEGER AS $$
-- Copyright (c) 1999-2017 by OpenMFG LLC, d/b/a xTuple. 
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  _itemlocSeries INTEGER;

BEGIN
  SELECT issueWoMaterial(pWomatlid, pQty, pItemlocSeries, pGlDistTS, NULL::INTEGER, NULL::NUMERIC, pPreDistributed) INTO _itemlocSeries;

  IF (pMarkPush) THEN
    UPDATE womatl
    SET womatl_issuemethod='S'
    WHERE ((womatl_issuemethod='M')
     AND (womatl_id=pWomatlid));
  END IF;

  RETURN _itemlocSeries;

END;
$$ LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION issueWoMaterial(INTEGER, NUMERIC) RETURNS INTEGER AS $$
-- Copyright (c) 1999-2017 by OpenMFG LLC, d/b/a xTuple. 
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  pWomatlid ALIAS FOR $1;
  pQty ALIAS FOR $2;
  _itemlocSeries INTEGER;

BEGIN

  SELECT NEXTVAL('itemloc_series_seq') INTO _itemlocSeries;
  RETURN issueWoMaterial(pWomatlid, pQty, _itemlocSeries);

END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION issueWoMaterial(INTEGER, NUMERIC, INTEGER) RETURNS INTEGER AS $$
-- Copyright (c) 1999-2017 by OpenMFG LLC, d/b/a xTuple. 
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  pWomatlid ALIAS FOR $1;
  pQty ALIAS FOR $2;
  pItemlocSeries ALIAS FOR $3;
  _p RECORD;
  _invhistid INTEGER;
  _itemlocSeries INTEGER;

BEGIN
  RETURN issueWoMaterial(pWomatlid, pQty, pItemlocSeries, now());
END;
$$ LANGUAGE 'plpgsql';

DROP FUNCTION IF EXISTS issueWoMaterial(INTEGER, NUMERIC, INTEGER, TIMESTAMP WITH TIME ZONE);
CREATE OR REPLACE FUNCTION issueWoMaterial(INTEGER, NUMERIC, INTEGER, TIMESTAMP WITH TIME ZONE, NUMERIC DEFAULT NULL) RETURNS INTEGER AS $$
-- Copyright (c) 1999-2017 by OpenMFG LLC, d/b/a xTuple. 
-- See www.xtuple.com/CPAL for the full text of the software license.
BEGIN
  RETURN issueWoMaterial($1, $2, $3, $4, NULL, $5);
END;
$$ LANGUAGE 'plpgsql';

DROP FUNCTION IF EXISTS issueWoMaterial(INTEGER, NUMERIC, INTEGER, TIMESTAMP WITH TIME ZONE, INTEGER);
DROP FUNCTION IF EXISTS issueWoMaterial(INTEGER, NUMERIC, INTEGER, TIMESTAMP WITH TIME ZONE, INTEGER, NUMERIC);
CREATE OR REPLACE FUNCTION issueWoMaterial(pWomatlid INTEGER,
                                           pQty NUMERIC,
                                           pItemlocSeries INTEGER,
                                           pGlDistTS TIMESTAMP WITH TIME ZONE,
                                           pInvhistid INTEGER,
                                           pPrevQty NUMERIC DEFAULT NULL,
                                           pPreDistributed BOOLEAN DEFAULT FALSE,
                                           pPostDistDetail BOOLEAN DEFAULT TRUE)
RETURNS INTEGER AS $$
-- Copyright (c) 1999-2017 by OpenMFG LLC, d/b/a xTuple. 
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  _p RECORD;
  _invhistid INTEGER;
  _itemlocSeries INTEGER := COALESCE(pItemlocSeries, NEXTVAL('itemloc_series_seq'));

BEGIN
  IF (pPreDistributed AND COALESCE(pItemlocSeries, 0) = 0) THEN 
    RAISE EXCEPTION 'pItemlocSeries is Required When pPreDistributed [public: issueWoMaterial, -1]';
  -- TODO - find why/how passing 0 instead of null for pItemlocSeries
  ELSIF (_itemlocSeries = 0) THEN
    _itemlocSeries := NEXTVAL('itemloc_series_seq');
  END IF;

  SELECT item_id,
         itemsite_id AS c_itemsite_id,
         wo_itemsite_id AS p_itemsite_id,
         isControlledItemsite(itemsite_id) AS controlled,
         womatl_id, womatl_wo_id, womatl_qtyreq, itemsite_item_id, womatl_uom_id, wo_prj_id,
         roundQty(item_fractional, itemuomtouom(itemsite_item_id, womatl_uom_id, NULL, pQty)) AS qty,
         formatWoNumber(wo_id) AS woNumber,
         CASE WHEN(itemsite_costmethod='J' AND item_type='P' AND poitem_id IS NOT NULL) THEN poitem_unitprice
              WHEN(itemsite_costmethod IN ('A','J')) THEN avgcost(itemsite_id)
              WHEN(itemsite_costmethod='S') THEN stdcost(itemsite_item_id)
              ELSE 0.0
         END AS cost,
         womatl_issuemethod AS issueMethod INTO _p
  FROM womatl JOIN wo ON (wo_id=womatl_wo_id)
              JOIN itemsite ON (itemsite_id=womatl_itemsite_id)
              JOIN item ON (item_id=itemsite_item_id)
              LEFT OUTER JOIN poitem ON (poitem_order_id=womatl_id AND poitem_order_type='W')
  WHERE (womatl_id=pWomatlid);

  IF (pQty < 0) THEN
    RAISE EXCEPTION 'Qty (%) to issue must be positive [xtuple, issueWoMaterial, -4, %]', pQty, pQty;
  END IF;

  SELECT postInvTrans( ci.itemsite_id, 'IM', _p.qty,
                      'W/O', 'WO', _p.woNumber, '',
                      ('Material ' || item_number || ' Issue to Work Order'),
                      getPrjAccntId(_p.wo_prj_id, pc.costcat_wip_accnt_id),
                      cc.costcat_asset_accnt_id, _itemlocSeries, pGlDistTS,
                      NULL, pInvhistid, pPrevQty, pPreDistributed, _p.womatl_wo_id, _p.womatl_id ) INTO _invhistid
  FROM itemsite AS ci, itemsite AS pi,
       costcat AS cc, costcat AS pc,
       item
  WHERE ( (ci.itemsite_costcat_id=cc.costcat_id)
   AND (pi.itemsite_costcat_id=pc.costcat_id)
   AND (ci.itemsite_id=_p.c_itemsite_id)
   AND (pi.itemsite_id=_p.p_itemsite_id)
   AND (ci.itemsite_item_id=item_id) );

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Could not post inventory transaction: missing cost category or itemsite for 
      womatl_id % [xtuple: issueWoMaterial, -2, %]', pWomatlid, pWomatlid;
  END IF;

--  Create linkage to the transaction created
  IF (_invhistid != -1) THEN
    INSERT INTO womatlpost (womatlpost_womatl_id,womatlpost_invhist_id)
                VALUES (pWomatlid,_invhistid);
  END IF;

--  Increase the parent W/O's WIP value by the value of the issued components
  UPDATE wo
  SET wo_wipvalue = (wo_wipvalue + (_p.cost * _p.qty)),
      wo_postedvalue = (wo_postedvalue + (_p.cost * _p.qty))
  WHERE (wo_id=_p.womatl_wo_id);

  UPDATE womatl
  SET womatl_qtyiss = (womatl_qtyiss + itemuomtouom(_p.itemsite_item_id, NULL, _p.womatl_uom_id, _p.qty)),
      womatl_lastissue = pGlDistTS::DATE
  WHERE (womatl_id=pWomatlid);

  UPDATE wo
  SET wo_status='I'
  WHERE ( (wo_status <> 'I')
   AND (wo_id=_p.womatl_wo_id) );

  -- Post distribution detail regardless of loc/control methods because postItemlocSeries is required.
  -- If it is a controlled item and the results were 0 something is wrong.
  IF (pPreDistributed AND pPostDistDetail) THEN
    IF (postDistDetail(_itemlocSeries) <= 0 AND _p.controlled) THEN
      RAISE EXCEPTION 'Posting Distribution Detail Returned 0 Results, [xtuple: issueWoMaterial, -3]';
    END IF;
  END IF;

  RETURN _itemlocSeries;

END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION issueWoMaterial(INTEGER, NUMERIC, BOOLEAN) RETURNS INTEGER AS $$
-- Copyright (c) 1999-2017 by OpenMFG LLC, d/b/a xTuple. 
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  pWomatlid ALIAS FOR $1;
  pQty ALIAS FOR $2;
  pMarkPush ALIAS FOR $3;
  _itemlocSeries INTEGER;

BEGIN
  RETURN issueWoMaterial(pWomatlid, pQty, pMarkPush, now());
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION issueWoMaterial(INTEGER, NUMERIC, BOOLEAN, TIMESTAMP WITH TIME ZONE) RETURNS INTEGER AS $$
-- Copyright (c) 1999-2017 by OpenMFG LLC, d/b/a xTuple. 
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  pWomatlid ALIAS FOR $1;
  pQty ALIAS FOR $2;
  pMarkPush ALIAS FOR $3;
  pGlDistTS ALIAS FOR $4;
  _itemlocSeries INTEGER;

BEGIN

  SELECT issueWoMaterial(pWomatlid, pQty, 0, pGlDistTS) INTO _itemlocSeries;
  IF (_itemlocSeries < 0) THEN
    RETURN _itemlocSeries;
  END IF;

  IF (pMarkPush) THEN
    UPDATE womatl
    SET womatl_issuemethod='S'
    WHERE ((womatl_issuemethod='M')
     AND (womatl_id=pWomatlid));
  END IF;

  RETURN _itemlocSeries;

END;
$$ LANGUAGE 'plpgsql';
