DROP FUNCTION IF EXISTS invExpense(INTEGER, NUMERIC, INTEGER, TEXT, TEXT, TIMESTAMP WITH TIME ZONE, INTEGER);
CREATE OR REPLACE FUNCTION invExpense(pItemsiteid     INTEGER,
                                      pQty            NUMERIC,
                                      pExpcatid       INTEGER,
                                      pDocumentNumber TEXT,
                                      pComments       TEXT,
                                      pGlDistTS       TIMESTAMP WITH TIME ZONE
                                                      DEFAULT CURRENT_TIMESTAMP,
                                      pPrjid          INTEGER DEFAULT NULL,
                                      pItemlocSeries  INTEGER DEFAULT NULL,
                                      pPreDistributed BOOLEAN DEFAULT FALSE)
  RETURNS INTEGER AS $$
-- Copyright (c) 1999-2017 by OpenMFG LLC, d/b/a xTuple. 
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  _invhistid INTEGER;
  _itemlocSeries INTEGER := COALESCE(pItemlocSeries, NEXTVAL('itemloc_series_seq'));

BEGIN
  IF (pPreDistributed AND COALESCE(pItemlocSeries, 0) = 0) THEN 
    RAISE EXCEPTION 'pItemlocSeries is Required when pPreDistributed [xtuple: invExpense, -1]';
  END IF;

  --  Make sure the passed itemsite points to a real item
  IF ( ( SELECT (item_type IN ('R', 'F') OR itemsite_costmethod = 'J')
         FROM itemsite, item
         WHERE ( (itemsite_item_id=item_id)
          AND (itemsite_id=pItemsiteid) ) ) ) THEN
    RETURN 0;
  END IF;

  SELECT postInvTrans( itemsite_id, 'EX', pQty,
                       'I/M', 'EX', pDocumentNumber, '',
                       CASE WHEN (pQty < 0) THEN ('Reverse Material Expense for item ' || item_number || E'\n' ||  pComments)
                            ELSE  ('Material Expense for item ' || item_number || E'\n' ||  pComments)
                       END,
                       getPrjAccntId(pPrjid, expcat_exp_accnt_id), costcat_asset_accnt_id,
                       _itemlocSeries, pGlDistTS, NULL, NULL, NULL, pPreDistributed) INTO _invhistid
  FROM itemsite, item, costcat, expcat
  WHERE ( (itemsite_item_id=item_id)
   AND (itemsite_costcat_id=costcat_id)
   AND (itemsite_id=pItemsiteid)
   AND (expcat_id=pExpcatid) );

  IF (NOT FOUND) THEN
    RAISE EXCEPTION 'Could not post inventory transaction: missing cost category or itemsite for 
      itemsite_id % [xtuple: invExpense, -3, %]', pItemsiteid, pItemsiteid;
  END IF;

  INSERT INTO invhistexpcat (invhistexpcat_invhist_id, invhistexpcat_expcat_id)
  VALUES (_invhistid, pExpcatid);

  -- Post distribution detail regardless of loc/control methods because postItemlocSeries is required.
  -- If it is a controlled item and the results were 0 something is wrong.
  IF (pPreDistributed) THEN
    IF (postDistDetail(_itemlocSeries) <= 0 AND isControlledItemsite(pItemsiteid)) THEN
      RAISE EXCEPTION 'Posting Distribution Detail Returned 0 Results, [xtuple: invExpense, -2]';
    END IF;
  END IF;

  RETURN _itemlocSeries;

END;
$$ LANGUAGE plpgsql;
