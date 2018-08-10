CREATE OR REPLACE FUNCTION issueToShipping(INTEGER, NUMERIC) RETURNS INTEGER AS $$
-- Copyright (c) 1999-2018 by OpenMFG LLC, d/b/a xTuple.
-- See www.xtuple.com/CPAL for the full text of the software license.
BEGIN
  RETURN issueToShipping('SO', $1, $2, 0, CURRENT_TIMESTAMP);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION issueToShipping(INTEGER, NUMERIC, INTEGER) RETURNS INTEGER AS $$
-- Copyright (c) 1999-2018 by OpenMFG LLC, d/b/a xTuple.
-- See www.xtuple.com/CPAL for the full text of the software license.
BEGIN
  RETURN issueToShipping('SO', $1, $2, $3, CURRENT_TIMESTAMP);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION issueToShipping(TEXT, INTEGER, NUMERIC, INTEGER, TIMESTAMP WITH TIME ZONE) RETURNS INTEGER AS $$
-- Copyright (c) 1999-2018 by OpenMFG LLC, d/b/a xTuple.
-- See www.xtuple.com/CPAL for the full text of the software license.
BEGIN
  RETURN issueToShipping($1, $2, $3, $4, $5, NULL);
END;
$$ LANGUAGE plpgsql;

-- Remove old function declaration
DROP FUNCTION IF EXISTS issuetoshipping(text, integer, numeric, integer, timestamp with time zone, integer);
DROP FUNCTION IF EXISTS issuetoshipping(text, integer, numeric, integer, timestamp with time zone, integer, boolean);

CREATE OR REPLACE FUNCTION issueToShipping(pordertype TEXT,
                                           pitemid INTEGER,
                                           pQty NUMERIC,
                                           pItemlocSeries INTEGER,
                                           pTimestamp TIMESTAMP WITH TIME ZONE,
                                           pinvhistid INTEGER,
                                           pDropship BOOLEAN DEFAULT FALSE,
                                           pPreDistributed BOOLEAN DEFAULT FALSE) RETURNS INTEGER AS $$
-- Copyright (c) 1999-2018 by OpenMFG LLC, d/b/a xTuple.
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  _itemlocSeries        INTEGER := COALESCE(pItemlocSeries, NEXTVAL('itemloc_series_seq'));
  _timestamp            TIMESTAMP WITH TIME ZONE := COALESCE(pTimestamp, CURRENT_TIMESTAMP);
  _coholdtype           TEXT;
  _invhistid            INTEGER;
  _shipheadid           INTEGER;
  _shipnumber           INTEGER;
  _cntctid              INTEGER;
  _p                    RECORD;
  _m                    RECORD;
  _value                NUMERIC;
  _warehouseid          INTEGER;
  _shipitemid           INTEGER;
  _freight              NUMERIC;
  _controlled           BOOLEAN := FALSE;
  _ordheadid            INTEGER;
  _orditemid            INTEGER;

BEGIN
  IF (pPreDistributed AND COALESCE(pItemlocSeries, 0) = 0) THEN
    RAISE EXCEPTION 'pItemlocSeries is Required when pPreDistributed [xtuple: issueToShipping, -2]';
  ELSIF (_itemlocSeries = 0) THEN
    _itemlocSeries := NEXTVAL('itemloc_series_seq');
  END IF;

  IF (pordertype = 'SO') THEN

    -- Check site security
    SELECT warehous_id, isControlledItemsite(itemsite_id) AS controlled, coitem_cohead_id, coitem_id
      INTO _warehouseid, _controlled, _ordheadid, _orditemid
    FROM coitem, itemsite, site()
    WHERE coitem_id = pitemid
      AND itemsite_id = coitem_itemsite_id
      AND warehous_id = itemsite_warehous_id;

    IF (NOT FOUND) THEN
      RETURN 0;
    END IF;

    -- Check for average cost items going negative
    IF ( SELECT ( (itemsite_costmethod='A') AND
                  ((itemsite_qtyonhand - round(pQty * coitem_qty_invuomratio, 6)) < 0.0) )
         FROM coitem JOIN itemsite ON (itemsite_id=coitem_itemsite_id)
         WHERE (coitem_id=pitemid) ) THEN
      RETURN -20;
    END IF;

    -- Check auto registration
    IF ( SELECT COALESCE(itemsite_autoreg, FALSE)
         FROM coitem JOIN itemsite ON (itemsite_id=coitem_itemsite_id)
         WHERE (coitem_id=pitemid) ) THEN
      SELECT COALESCE(crmacct_cntct_id_1, -1) INTO _cntctid
      FROM coitem JOIN cohead ON (cohead_id=coitem_cohead_id)
                  JOIN crmacct ON (crmacct_cust_id=cohead_cust_id)
      WHERE (coitem_id=pitemid);
      IF (_cntctid = -1) THEN
        RETURN -15;
      END IF;
    END IF;

    -- Check Hold
    SELECT soHoldType(coitem_cohead_id) INTO _coholdtype
    FROM coitem
    WHERE (coitem_id=pitemid);

    IF (_coholdtype = 'C') THEN
      RETURN -12;
    ELSIF (_coholdtype = 'P') THEN
      RETURN -13;
    ELSIF (_coholdtype = 'R') THEN
      RETURN -14;
    ELSIF (_coholdtype = 'T') THEN
      RETURN -16;
    END IF;

    SELECT shiphead_id INTO _shipheadid
    FROM shiphead, coitem JOIN itemsite ON (itemsite_id=coitem_itemsite_id)
    WHERE ( (coitem_id=pitemid)
      AND   (shiphead_number=getOpenShipment(pordertype, coitem_cohead_id, itemsite_warehous_id)) );
    IF ((NOT FOUND) OR (pDropship)) THEN
      _shipnumber := fetchShipmentNumber();
      IF (_shipnumber < 0) THEN
	RETURN -10;
      END IF;

      INSERT INTO shiphead
      ( shiphead_number, shiphead_order_id, shiphead_order_type,
	shiphead_shipped,
	shiphead_sfstatus, shiphead_shipvia, shiphead_shipchrg_id,
	shiphead_freight, shiphead_freight_curr_id,
	shiphead_shipdate, shiphead_notes, shiphead_shipform_id, shiphead_dropship )
      SELECT _shipnumber, coitem_cohead_id, pordertype,
	     FALSE,
	     'N', cohead_shipvia,
	     CASE WHEN (cohead_shipchrg_id <= 0) THEN NULL
	          ELSE cohead_shipchrg_id
	     END,
	     cohead_freight, cohead_curr_id,
	     _timestamp::DATE, cohead_shipcomments,
	     CASE WHEN cohead_shipform_id = -1 THEN NULL
	          ELSE cohead_shipform_id
	     END,
	     pDropship
      FROM cohead, coitem
      WHERE coitem_cohead_id=cohead_id
        AND coitem_id=pitemid
      RETURNING shiphead_id INTO _shipheadid;

      UPDATE pack
      SET pack_shiphead_id = _shipheadid,
	  pack_printed = FALSE
      FROM coitem
      WHERE ((pack_head_id=coitem_cohead_id)
	AND  (pack_shiphead_id IS NULL)
	AND  (pack_head_type='SO')
	AND  (coitem_id=pitemid));

    ELSE
      UPDATE pack
      SET pack_printed = FALSE
      FROM coitem
      WHERE ((pack_head_id=coitem_cohead_id)
	AND  (pack_shiphead_id=_shipheadid)
	AND  (pack_head_type='SO')
	AND  (coitem_id=pitemid));
    END IF;

    INSERT INTO shipitem
    ( shipitem_shiphead_id, shipitem_orderitem_id, shipitem_qty,
      shipitem_transdate, shipitem_trans_username, shipitem_invoiced,
      shipitem_invhist_id )
    VALUES
    ( _shipheadid, pitemid, pQty,
      _timestamp, getEffectiveXtUser(), FALSE,
      CASE WHEN _invhistid = -1 THEN NULL
      ELSE _invhistid END )
    RETURNING shipitem_id INTO _shipitemid;

    -- Handle reservations
    IF (fetchmetricbool('EnableSOReservations')) THEN
      -- Remember what was reserved so we can re-reserve if this issue is returned
      INSERT INTO shipitemrsrv
        (shipitemrsrv_shipitem_id, shipitemrsrv_qty)
      SELECT _shipitemid, least(pQty,itemuomtouom(itemsite_item_id, NULL, coitem_qty_uom_id, coitem_qtyreserved))
      FROM coitem JOIN itemsite ON (itemsite_id=coitem_itemsite_id)
      WHERE ((coitem_id=pitemid)
      AND (coitem_qtyreserved > 0));

      -- Update sales order (must be done prior to postInvTrans)
      UPDATE coitem
        SET coitem_qtyreserved = noNeg((coitem_qtyreserved / coitem_qty_invuomratio) - pQty)
      WHERE(coitem_id=pitemid);
    END IF;

    -- Handle g/l transaction
    SELECT postInvTrans( itemsite_id, 'SH', (pQty * coitem_qty_invuomratio),
			   'S/R', porderType,
			   formatSoNumber(coitem_id), shiphead_number,
                           ('Issue ' || item_number || ' to Shipping for customer ' || cohead_billtoname),
			   getPrjAccntId(cohead_prj_id, costcat_shipasset_accnt_id), costcat_asset_accnt_id,
			   _itemlocSeries, _timestamp, NULL, pinvhistid, NULL, pPreDistributed, _ordheadid, _orditemid ) INTO _invhistid
    FROM coitem, cohead, itemsite, item, costcat, shiphead
    WHERE ( (coitem_cohead_id=cohead_id)
     AND (coitem_itemsite_id=itemsite_id)
     AND (itemsite_item_id=item_id)
     AND (itemsite_costcat_id=costcat_id)
     AND (coitem_id=pitemid)
     AND (shiphead_id=_shipheadid) );

    IF (NOT FOUND) THEN
      RAISE EXCEPTION 'Missing cost category for SO item % [xtuple: issueToShipping, -4, %]', pitemid, pitemid;
    END IF;

    SELECT (invhist_unitcost * invhist_invqty) INTO _value
    FROM invhist
    WHERE (invhist_id=_invhistid);

    -- Due to Reservation interdependencies we have to create the shipitem, post inventory,
    -- then update the shipitem with the invhist value
    UPDATE shipitem SET shipitem_value = _value
    WHERE shipitem_id = _shipitemid;

    -- Calculate shipment freight
    SELECT calcShipFreight(_shipheadid) INTO _freight;
    UPDATE shiphead SET shiphead_freight=_freight
    WHERE (shiphead_id=_shipheadid);

  ELSEIF (pordertype = 'TO') THEN

    -- Check site security
    IF (fetchMetricBool('MultiWhs')) THEN

      SELECT warehous_id, isControlledItemsite(itemsite_id), toitem_tohead_id, toitem_id
        INTO _warehouseid, _controlled, _ordheadid, _orditemid
      FROM toitem, tohead, itemsite, site()
      WHERE toitem_id = pitemid
        AND toitem_tohead_id = tohead_id
        AND toitem_item_id = itemsite_item_id
        AND tohead_src_warehous_id = itemsite_warehous_id
        AND warehous_id=tohead_src_warehous_id;


      IF (NOT FOUND) THEN
        RETURN 0;
      END IF;
    END IF;

    SELECT postInvTrans( itemsite_id, 'SH', pQty, 'S/R',
			 pordertype, formatToNumber(toitem_id), '', 'Issue to Shipping',
			 costcat_shipasset_accnt_id, costcat_asset_accnt_id,
			 _itemlocSeries, _timestamp, NULL, NULL, NULL, pPreDistributed, _ordheadid, _orditemid) INTO _invhistid
    FROM tohead, toitem, itemsite, costcat
    WHERE ((tohead_id=toitem_tohead_id)
      AND  (itemsite_item_id=toitem_item_id)
      AND  (itemsite_warehous_id=tohead_src_warehous_id)
      AND  (itemsite_costcat_id=costcat_id)
      AND  (toitem_id=pitemid) );

    IF (NOT FOUND) THEN
      RAISE EXCEPTION 'Missing cost category for TO item % [xtuple: issueToShipping, -4, %]', pitemid, pitemid;
    END IF;

    SELECT (invhist_unitcost * invhist_invqty) INTO _value
    FROM invhist
    WHERE (invhist_id=_invhistid);

    SELECT shiphead_id INTO _shipheadid
    FROM shiphead, toitem JOIN tohead ON (tohead_id=toitem_tohead_id)
    WHERE ( (toitem_id=pitemid)
      AND   (shiphead_number=getOpenShipment(pordertype, tohead_id, tohead_src_warehous_id)) );

    IF (NOT FOUND) THEN
      _shipnumber := fetchShipmentNumber();
      IF (_shipnumber < 0) THEN
	RETURN -10;
      END IF;

      INSERT INTO shiphead
      ( shiphead_id, shiphead_number, shiphead_order_id, shiphead_order_type,
	shiphead_shipped,
	shiphead_sfstatus, shiphead_shipvia, shiphead_shipchrg_id,
	shiphead_freight, shiphead_freight_curr_id,
	shiphead_shipdate, shiphead_notes, shiphead_shipform_id )
      SELECT _shipheadid, _shipnumber, tohead_id, pordertype,
	     FALSE,
	     'N', tohead_shipvia, tohead_shipchrg_id,
	     tohead_freight + SUM(toitem_freight), tohead_freight_curr_id,
	     _timestamp::DATE, tohead_shipcomments, tohead_shipform_id
      FROM tohead, toitem
      WHERE ((toitem_tohead_id=tohead_id)
         AND (tohead_id IN (SELECT toitem_tohead_id
			    FROM toitem
			    WHERE (toitem_id=pitemid))) )
      GROUP BY tohead_id, tohead_shipvia, tohead_shipchrg_id, tohead_freight,
	       tohead_freight_curr_id, tohead_shipcomments, tohead_shipform_id
      RETURNING shiphead_id INTO _shipheadid;
    END IF;

    INSERT INTO shipitem
    ( shipitem_shiphead_id, shipitem_orderitem_id, shipitem_qty,
      shipitem_transdate, shipitem_trans_username, shipitem_invoiced,
      shipitem_value, shipitem_invhist_id )
    VALUES
    ( _shipheadid, pitemid, pQty,
      _timestamp, getEffectiveXtUser(), FALSE,
      _value,
      CASE WHEN _invhistid = -1 THEN NULL
           ELSE _invhistid
      END
    );

  ELSE
    RETURN -11;
  END IF;

  -- Post distribution detail regardless of loc/control methods because postItemlocSeries is required.
  -- However, if pinvhist IS NOT NULL then postItemlocSeries will have already occured in postInvTrans.
  IF (pPreDistributed AND pinvhistid IS NULL) THEN
    -- If it is a controlled item and the results were 0 something is wrong.
    IF (postDistDetail(_itemlocSeries) <= 0 AND _controlled) THEN
      RAISE EXCEPTION 'Posting Distribution Detail Returned 0 Results, [xtuple: issueToShipping, -3]';
    END IF;
  END IF;

  RETURN _itemlocSeries;

END;
$$ LANGUAGE plpgsql;
