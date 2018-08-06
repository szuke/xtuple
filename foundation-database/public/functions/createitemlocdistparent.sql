DROP FUNCTION IF EXISTS createItemlocdistParent(INTEGER, NUMERIC, TEXT, INTEGER, INTEGER, INTEGER, INTEGER, TEXT);
CREATE OR REPLACE FUNCTION createItemlocdistParent(
  pItemsiteid INTEGER, 
  pQty NUMERIC, 
  pOrderType TEXT, 
  pOrderitemId INTEGER, 
  pItemlocSeries INTEGER,
  pInvhistId INTEGER DEFAULT NULL, -- Used when NOT pPreDistributed in postInvTrans to send the invhist_id
  pItemlocdistId INTEGER DEFAULT NULL, -- Used in enterPoReceipt.cpp for TO (from WH) for example, it sets the itemlocdist_source_id record 
  pTransType TEXT DEFAULT NULL
) RETURNS INTEGER AS $$
-- Copyright (c) 1999-2017 by OpenMFG LLC, d/b/a xTuple.
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  _itemlocdistId  INTEGER;
  _r              RECORD;

BEGIN
  --  Cache item and itemsite info  
  SELECT itemsite_controlmethod IN ('L', 'S') AS lscntrl,
         itemsite_loccntrl AS loccntrl INTO _r
  FROM itemsite 
    JOIN item ON item_id = itemsite_item_id
  WHERE itemsite_id=pItemsiteid;

  IF (NOT _r.lscntrl AND NOT _r.loccntrl) THEN
    RAISE EXCEPTION 'Itemsite Must be Lot/Serial or Location Controlled. 
      [xtuple: createItemlocdistParent, -1, %]', pItemsiteid;
  END IF;

  IF (pItemlocSeries IS NULL) THEN
    RAISE EXCEPTION 'Series is required. 
      [xtuple: createItemlocdistParent, -2, %]', pItemlocSeries;
  END IF;

  -- Create the parent itemlocdist record using the series passed
  INSERT INTO itemlocdist 
  ( itemlocdist_itemsite_id,
    itemlocdist_source_type,
    itemlocdist_source_id,
    itemlocdist_reqlotserial,
    itemlocdist_distlotserial,
    itemlocdist_expiration,
    itemlocdist_qty,
    itemlocdist_series,
    itemlocdist_invhist_id,
    itemlocdist_order_type,
    itemlocdist_order_id, -- this column should be renamed itemlocdist_orderitem_id
    itemlocdist_child_series,
    itemlocdist_transtype )
  VALUES (pItemsiteid,
    'O',
    pItemlocdistId,
    ((pQty > 0) AND _r.lscntrl),
    (pQty < 0),
    endOfTime(),
    pQty,
    pItemlocSeries,
    pInvhistId,
    pOrderType,
    pOrderitemId,
    pItemlocSeries,
    COALESCE(pTransType, pOrderType) )
  RETURNING itemlocdist_id INTO _itemlocdistId;
  
  IF (NOT FOUND) THEN
    RAISE EXCEPTION 'Failed to Create Parent Itemlocdist Record. 
      [xtuple: createItemlocdistParent, -3]';
  END IF;

  RETURN _itemlocdistId;
END;
$$ LANGUAGE plpgsql;
