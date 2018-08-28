CREATE OR REPLACE FUNCTION invScrap(INTEGER, NUMERIC, TEXT, TEXT) RETURNS INTEGER AS $$
-- Copyright (c) 1999-2017 by OpenMFG LLC, d/b/a xTuple. 
-- See www.xtuple.com/CPAL for the full text of the software license.
BEGIN
  RETURN invScrap($1, $2, $3, $4, CURRENT_TIMESTAMP);
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION invScrap(INTEGER, NUMERIC, TEXT, TEXT, TIMESTAMP WITH TIME ZONE) RETURNS INTEGER AS $$
-- Copyright (c) 1999-2017 by OpenMFG LLC, d/b/a xTuple. 
-- See www.xtuple.com/CPAL for the full text of the software license.
BEGIN
  RETURN invScrap($1, $2, $3, $4, $5, NULL);
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION invScrap(INTEGER, NUMERIC, TEXT, TEXT, TIMESTAMP WITH TIME ZONE, INTEGER) RETURNS INTEGER AS $$
-- Copyright (c) 1999-2017 by OpenMFG LLC, d/b/a xTuple. 
-- See www.xtuple.com/CPAL for the full text of the software license.
BEGIN
  RETURN invScrap($1, $2, $3, $4, $5, $6, NULL);
END;
$$ LANGUAGE 'plpgsql';

DROP FUNCTION IF EXISTS invScrap(INTEGER, NUMERIC, TEXT, TEXT, TIMESTAMP WITH TIME ZONE, INTEGER, INTEGER);
CREATE OR REPLACE FUNCTION invScrap(pItemsiteId INTEGER, 
                                    pQty NUMERIC, 
                                    pDocumentNumber TEXT, 
                                    pComments TEXT, 
                                    pGlDistTS TIMESTAMP WITH TIME ZONE, 
                                    pInvhistId INTEGER, 
                                    pPrjId INTEGER,
                                    pItemlocSeries INTEGER DEFAULT NULL,
                                    pPreDistributed BOOLEAN DEFAULT FALSE) RETURNS INTEGER AS $$
-- Copyright (c) 1999-2017 by OpenMFG LLC, d/b/a xTuple. 
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  _invhistid INTEGER;
  _itemlocSeries INTEGER := COALESCE(pItemlocSeries, NEXTVAL('itemloc_series_seq'));

BEGIN
  IF (pPreDistributed AND COALESCE(pItemlocSeries, 0) = 0) THEN 
    RAISE EXCEPTION 'pItemlocSeries is Required when pPreDistributed [xtuple: invScrap, -1]';
  ELSEIF (_itemlocSeries <= 0) THEN 
    RAISE EXCEPTION 'Failed to set _itemlocSeries using pItemlocSeries: % [xtuple: invScrap, -2, %]',
      pItemlocSeries, pItemlocSeries;
  END IF;

  --  Make sure the passed itemsite points to a real item
  IF ( ( SELECT (item_type IN ('R', 'F') OR itemsite_costmethod = 'J')
         FROM itemsite, item
         WHERE ( (itemsite_item_id=item_id)
          AND (itemsite_id=pItemsiteId) ) ) ) THEN
    RETURN 0;
  END IF;

  IF (pInvhistId IS NOT NULL) THEN
    SELECT invhist_series INTO _itemlocSeries
    FROM invhist
    WHERE invhist_id=pInvhistId;
  END IF;
  
  SELECT postInvTrans( itemsite_id, 'SI', pQty,
                       'I/M', 'SI', pDocumentNumber, '',
                       CASE WHEN (pQty < 0) THEN ('Reverse Material Scrap for item ' || item_number || E'\n' ||  pComments)
                            ELSE ('Material Scrap for item ' || item_number || E'\n' ||  pComments)
                       END,
                       getPrjAccntId(pPrjId, costcat_scrap_accnt_id), costcat_asset_accnt_id,
                       _itemlocSeries, pGlDistTS, NULL, pInvhistId, NULL, pPreDistributed) INTO _invhistid
  FROM itemsite, item, costcat
  WHERE ( (itemsite_item_id=item_id)
   AND (itemsite_costcat_id=costcat_id)
   AND (itemsite_id=pItemsiteId) );

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Could not post inventory transaction: missing cost category or itemsite for 
      itemsite_id % [xtuple: invScrap, -3, %]', pItemsiteId, pItemsiteId;
  END IF;

  -- Post distribution detail regardless of loc/control methods because postItemlocSeries is required.
  -- If it is a controlled item and the results were 0 something is wrong.
  IF (pPreDistributed AND pInvhistId IS NULL) THEN
    IF (postDistDetail(_itemlocSeries) <= 0 AND isControlledItemsite(pItemsiteId)) THEN
      RAISE EXCEPTION 'Posting Distribution Detail Returned 0 Results, [xtuple: invScrap, -4]';
    END IF;
  END IF;

  RETURN _itemlocSeries;

END;
$$ LANGUAGE 'plpgsql';
