DROP FUNCTION IF EXISTS invAdjustment(INTEGER, NUMERIC, TEXT, TEXT);

DROP FUNCTION IF EXISTS invAdjustment(INTEGER, NUMERIC, TEXT, TEXT, TIMESTAMP WITH TIME ZONE);

DROP FUNCTION IF EXISTS invAdjustment(INTEGER, NUMERIC, TEXT, TEXT, TIMESTAMP WITH TIME ZONE, NUMERIC);

DROP FUNCTION IF EXISTS invAdjustment(INTEGER, NUMERIC, TEXT, TEXT, TIMESTAMP WITH TIME ZONE, NUMERIC, INTEGER);

DROP FUNCTION IF EXISTS invAdjustment(INTEGER, NUMERIC, TEXT, TEXT, TIMESTAMP WITH TIME ZONE, NUMERIC, INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION invAdjustment(pItemsiteid      INTEGER, 
                                         pQty             NUMERIC, 
                                         pDocumentNumber  TEXT, 
                                         pComments        TEXT, 
                                         pGlDistTS        TIMESTAMP WITH TIME ZONE 
                                                          DEFAULT CURRENT_TIMESTAMP, 
                                         pCostValue       NUMERIC DEFAULT NULL, 
                                         pGlAccountid     INTEGER DEFAULT NULL,
                                         pItemlocSeries   INTEGER DEFAULT NULL,
                                         pPreDistributed  BOOLEAN DEFAULT FALSE) 
  RETURNS INTEGER AS $$
-- Copyright (c) 1999-2014 by OpenMFG LLC, d/b/a xTuple. 
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  _invhistId      INTEGER;
  _itemlocSeries  INTEGER := COALESCE(pItemlocSeries, NEXTVAL('itemloc_series_seq'));
  
BEGIN
  IF (pPreDistributed AND COALESCE(pItemlocSeries, 0) = 0) THEN 
    RAISE EXCEPTION 'pItemlocSeries is Required when pPreDistributed [xtuple: invAdjustment, -1]';
  END IF;

  --  Make sure the passed itemsite points to a real item
  IF ( ( SELECT (item_type IN ('R', 'F') OR itemsite_costmethod = 'J')
         FROM itemsite, item
         WHERE ( (itemsite_item_id=item_id)
          AND (itemsite_id=pItemsiteid) ) ) ) THEN
    RAISE EXCEPTION 'Item is not eligible for inventory adjustments based on item_type 
      or itemsite_costmethod [xtuple: invAdjustment, -2]';
  END IF;

  SELECT postinvtrans(itemsite_id, 'AD', pQty, 'I/M', 'AD', pDocumentNumber, '',
                       ('Miscellaneous Adjustment for item ' || item_number || E'\n' ||  pComments),
                       costcat_asset_accnt_id, coalesce(pGlAccountid, costcat_adjustment_accnt_id),
                       _itemlocSeries, pGlDistTS, pCostValue,
                       NULL, NULL, pPreDistributed) INTO _invhistId
  FROM itemsite, item, costcat
  WHERE itemsite_item_id=item_id
    AND itemsite_costcat_id=costcat_id
    AND itemsite_id=pItemsiteid;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Could not post inventory transaction: no cost category found for 
      itemsite_id % [xtuple: invAdjustment, -3, %]', pItemsiteid, pItemsiteid;
  END IF;

  -- Post distribution detail regardless of loc/control methods because postItemlocSeries is required.
  -- If it is a controlled item and the results were 0 something is wrong.
  IF (pPreDistributed) THEN
    IF (postDistDetail(_itemlocSeries) <= 0 AND isControlledItemsite(pItemsiteid)) THEN
      RAISE EXCEPTION 'Posting Distribution Detail Returned 0 Results, [xtuple: invAdjustment, -4]';
    END IF;
  END IF;

  RETURN _itemlocSeries;
END;
$$ LANGUAGE 'plpgsql';
