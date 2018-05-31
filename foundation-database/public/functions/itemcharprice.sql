CREATE OR REPLACE FUNCTION itemCharPrice(INTEGER, INTEGER, TEXT, INTEGER, NUMERIC) RETURNS NUMERIC AS $$
-- Copyright (c) 1999-2018 by OpenMFG LLC, d/b/a xTuple.
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  pItemid ALIAS FOR $1;
  pCharid ALIAS FOR $2;
  pCharValue ALIAS FOR $3;
  pCustid ALIAS FOR $4;
  pQty ALIAS FOR $5;

BEGIN
  RETURN itemCharPrice(pItemid, pCharid, pCharValue, pCustid, -1, pQty, baseCurrId(), CURRENT_DATE);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION itemCharPrice(INTEGER, INTEGER, TEXT, INTEGER, INTEGER, NUMERIC) RETURNS NUMERIC AS $$
-- Copyright (c) 1999-2018 by OpenMFG LLC, d/b/a xTuple.
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  pItemid ALIAS FOR $1;
  pCharid ALIAS FOR $2;
  pCharValue ALIAS FOR $3;
  pCustid ALIAS FOR $4;
  pShiptoid ALIAS FOR $5;
  pQty ALIAS FOR $6;

BEGIN
  RETURN itemCharPrice(pItemid, pCharid, pCharValue, pCustid, pShiptoid, pQty, baseCurrId(), CURRENT_DATE);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION itemCharPrice(INTEGER, INTEGER, TEXT, INTEGER, INTEGER, NUMERIC, INTEGER) RETURNS NUMERIC AS $$
-- Copyright (c) 1999-2018 by OpenMFG LLC, d/b/a xTuple.
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  pItemid ALIAS FOR $1;
  pCharid ALIAS FOR $2;
  pCharValue ALIAS FOR $3;
  pCustid ALIAS FOR $4;
  pShiptoid ALIAS FOR $5;
  pQty ALIAS FOR $6;
  pCurrid ALIAS FOR $7;

BEGIN
  RETURN itemCharPrice(pItemid, pCharid, pCharValue, pCustid, pShiptoid, pQty, pCurrid, CURRENT_DATE);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION itemCharPrice(INTEGER, INTEGER, TEXT, INTEGER, INTEGER, NUMERIC, INTEGER, DATE) RETURNS NUMERIC AS $$
-- Copyright (c) 1999-2018 by OpenMFG LLC, d/b/a xTuple.
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  pItemid ALIAS FOR $1;
  pCharid ALIAS FOR $2;
  pCharValue ALIAS FOR $3;
  pCustid ALIAS FOR $4;
  pShiptoid ALIAS FOR $5;
  pQty ALIAS FOR $6;
  pCurrid ALIAS FOR $7;
  pEffective ALIAS FOR $8;

BEGIN
  RETURN itemCharPrice(pItemid, pCharid, pCharValue, pCustid, pShiptoid, pQty, pCurrid, CURRENT_DATE, CURRENT_DATE);
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS itemcharprice(integer, integer, text, integer, integer, numeric, integer, date, date);

CREATE OR REPLACE FUNCTION itemCharPrice(
    pItemid integer,
    pCharid integer,
    pCharValue text,
    pCustid integer,
    pShiptoid integer,
    pQty numeric,
    pCurrid integer,
    pEffective date,
    pAsOf date,
    pShipZoneid integer DEFAULT (-1),
    pSaleTypeid integer DEFAULT (-1))
  RETURNS numeric AS
$BODY$
-- Copyright (c) 1999-2018 by OpenMFG LLC, d/b/a xTuple.
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  _cust RECORD;
  _item RECORD;
  _iteminvpricerat NUMERIC;
  _price NUMERIC;
  _sales NUMERIC;
  _shipto RECORD;

BEGIN
-- If the charass_value passed in is NULL, we can skip this function
  IF (pCharValue IS NULL) THEN
    RETURN 0;
  END IF;

-- Cache Customer and Shipto
  SELECT
    cust_id,
    cust_custtype_id,
    custtype_code,
    cust_discntprcnt INTO _cust
    FROM custinfo
    JOIN custtype ON custtype_id = cust_custtype_id
   WHERE cust_id = pCustid;

  SELECT
    shipto_id,
    shipto_num INTO _shipto
    FROM shiptoinfo
   WHERE shipto_id = pShiptoid;

-- Return the itemCharPrice in the currency passed in as pCurrid

-- Get a value here so we do not have to call the function several times
  SELECT iteminvpricerat(pItemid)
    INTO _iteminvpricerat;

-- First get a sales price if any so we when we find other prices
-- we can determine if we want that price or this price.
--  Check for a Sale Price

  SELECT currToCurr(ipshead_curr_id, pCurrid,
                    ipsprice_price - (ipsprice_price * _cust.cust_discntprcnt),
                    pEffective) INTO _sales
    FROM (
      SELECT
        ipshead_curr_id,
        ipsitem_ipshead_id AS ipsprice_ipshead_id,
        itemuomtouom(ipsitem_item_id, ipsitem_qty_uom_id, NULL, ipsitem_qtybreak) AS ipsprice_qtybreak,
        (ipsitemchar_price * itemuomtouomratio(ipsitem_item_id, NULL, ipsitem_price_uom_id)) * _iteminvpricerat AS ipsprice_price
        FROM ipshead
        JOIN sale ON ipshead.ipshead_id = sale_ipshead_id
        JOIN ipsiteminfo ON ipshead.ipshead_id = ipsiteminfo.ipsitem_ipshead_id
        JOIN ipsitemchar ON ipsiteminfo.ipsitem_id = ipsitemchar.ipsitemchar_ipsitem_id
       WHERE pAsOf BETWEEN sale_startdate AND sale_enddate
         AND ipsitem_item_id = pItemid
         AND ipsitemchar_char_id = pCharid
         AND ipsitemchar_value = pCharValue
    ) AS proto
   WHERE ipsprice_qtybreak <= pQty
   ORDER BY
    ipsprice_qtybreak DESC,
    ipsprice_price
   LIMIT 1;

  SELECT
    currToCurr(ipshead_curr_id, pCurrid, ipsprice_price, pEffective) INTO _price
    FROM (
      SELECT
        ipshead_curr_id,
        CASE
          WHEN (COALESCE(ipsass_shipto_id, -1) > 0) THEN 1
          WHEN (COALESCE(LENGTH(ipsass_shipto_pattern), 0) > 0 AND COALESCE(ipsass_cust_id, -1) > 0) THEN 2
          WHEN (COALESCE(LENGTH(ipsass_shipto_pattern), 0) > 0) THEN 3
          WHEN (COALESCE(ipsass_cust_id, -1) > 0) THEN 4
          WHEN (COALESCE(ipsass_custtype_id, -1) > 0) THEN 5
          WHEN (COALESCE(LENGTH(ipsass_custtype_pattern), 0) > 0) THEN 6
          WHEN (COALESCE(ipsass_shipzone_id, -1) > 0) THEN 7
          WHEN (COALESCE(ipsass_saletype_id, -1) > 0) THEN 8
          ELSE 99
        END AS assignseq,
        ipsitem_ipshead_id AS ipsprice_ipshead_id,
        itemuomtouom(ipsitem_item_id, ipsitem_qty_uom_id, NULL, ipsitem_qtybreak) AS ipsprice_qtybreak,
        (ipsitemchar_price * itemuomtouomratio(ipsitem_item_id, NULL, ipsitem_price_uom_id)) * _iteminvpricerat AS ipsprice_price
        FROM ipsass
        JOIN ipshead ON ipshead_id = ipsass_ipshead_id AND NOT ipshead_listprice
        JOIN ipsiteminfo ON ipshead_id = ipsitem_ipshead_id
        JOIN ipsitemchar ON ipsitem_id = ipsitemchar_ipsitem_id
       WHERE (pAsOf BETWEEN ipshead_effective AND (ipshead_expires - 1))
         AND ipsitem_item_id = pItemid
         AND ipsitemchar_char_id = pCharid
         AND ipsitemchar_value = pCharValue
         AND (
          -- 1. Specific Customer Shipto Id
          (ipsass_shipto_id != -1 AND ipsass_shipto_id = _shipto.shipto_id)
          -- 2. Specific Customer Shipto Pattern
          OR (COALESCE(LENGTH(ipsass_shipto_pattern), 0) > 0
              AND ipsass_cust_id > -1
              AND COALESCE(_shipto.shipto_num, '') ~ ipsass_shipto_pattern
              AND ipsass_cust_id = _cust.cust_id
          )
          -- 3. Any Customer Shipto Pattern
          OR (COALESCE(LENGTH(ipsass_shipto_pattern), 0) > 0
              AND ipsass_cust_id = -1
              AND COALESCE(_shipto.shipto_num, '') ~ ipsass_shipto_pattern
          )
          -- 4. Specific Customer
          OR (COALESCE(LENGTH(ipsass_shipto_pattern), 0) = 0
              AND ipsass_cust_id = _cust.cust_id
          )
          -- 5. Customer Type
          OR (ipsass_custtype_id = _cust.cust_custtype_id)
          -- 6. Customer Type Pattern
          OR (COALESCE(LENGTH(ipsass_custtype_pattern), 0) > 0
              AND COALESCE(_cust.custtype_code, '') ~ ipsass_custtype_pattern
          )
          -- 7. Shipping Zone
          OR (COALESCE(ipsass_shipzone_id, 0) > 0
              AND ipsass_shipzone_id = pShipZoneid
          )
          -- 8. Sale Type
          OR (COALESCE(ipsass_saletype_id, 0 ) > 0
              AND ipsass_saletype_id = pSaleTypeid
          )
         )
    ) AS proto
   WHERE ipsprice_qtybreak <= pQty
   ORDER BY
    assignseq,
    ipsprice_qtybreak DESC,
    ipsprice_price
   LIMIT 1
  ;

  IF (_price IS NOT NULL) THEN
    IF ((_sales IS NOT NULL) AND (_sales < _price)) THEN
      RETURN _sales;
    END IF;
    RETURN _price;
  END IF;

-- If we have not found another price yet and we have a
-- sales price we will use that.
  IF (_sales IS NOT NULL) THEN
    RETURN _sales;
  END IF;

--  Check for a list price
  SELECT MIN(currToLocal(pCurrid,
                         charass_price - (charass_price * COALESCE(_cust.cust_discntprcnt, 0)),
                         pEffective)) AS price,
         item_exclusive INTO _item
    FROM charass
    JOIN item ON charass_target_id = item_id
   WHERE item_id = pItemid
     AND charass_char_id = pCharid
     AND charass_value = pCharValue
     AND charass_target_type = 'I'
   GROUP BY item_exclusive;
  IF (FOUND) THEN
    IF (NOT _item.item_exclusive) THEN
      IF (_item.price < 0) THEN
        RETURN 0;
      ELSE
        RETURN _item.price;
      END IF;
    ELSE
      RETURN 0;
    END IF;
  ELSE
    RETURN 0;
  END IF;

END;
$BODY$
LANGUAGE plpgsql STABLE;
