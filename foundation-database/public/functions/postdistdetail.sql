DROP FUNCTION IF EXISTS postDistDetail(INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION postDistDetail(pItemlocSeries INTEGER)
  RETURNS INTEGER AS $$
-- Copyright (c) 1999-2017 by OpenMFG LLC, d/b/a xTuple. 
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  _distCount      INTEGER := 0;
  _distCountTotal INTEGER := 0;
  _r              RECORD;

BEGIN 
  -- Positive qty, lot/serial controlled:
  FOR _r IN 
    SELECT DISTINCT itemlocdist_child_series, itemsite_loccntrl
    FROM itemlocdist 
      JOIN itemsite ON itemlocdist_itemsite_id = itemsite_id
    WHERE itemlocdist_series = pItemlocSeries
      AND itemlocdist_child_series IS NOT NULL 
      AND itemsite_controlmethod IN ('L', 'S') 
      AND itemlocdist_qty > 0 LOOP

    IF (_r.itemsite_loccntrl) THEN 
      SELECT distributeToLocations(itemlocdist_id) INTO _distCount
      FROM itemlocdist
      WHERE itemlocdist_series = _r.itemlocdist_child_series;

      IF COALESCE(_distCount, 0) = 0 THEN
        RAISE EXCEPTION 'Expected a Count of the Distribution Detail Records Posted but 
          distributeToLocations returned % for ls and location controlled item with qty > 0 
          [xtuple: postDistDetail, -1, %]', _distCount, _distCount;
      END IF;

    ELSE
      _distCount := distributeItemlocSeries(_r.itemlocdist_child_series);

      IF COALESCE(_distCount, 0) = 0 THEN
        RAISE EXCEPTION 'Expected a Count of the Distribution Detail Records Posted but 
          distributeItemlocSeries(%) returned: % [xtuple: postDistDetail, -2, %, %]', 
          _r.itemlocdist_child_series, _distCount, _r.itemlocdist_child_series, _distCount;
      END IF;
    END IF;

    _distCountTotal := _distCountTotal + COALESCE(_distCount, 0);
  END LOOP;

  -- Negative qty OR ONLY location controlled:
  FOR _r IN 
    SELECT itemlocdist_id
    FROM itemlocdist 
      JOIN itemsite ON itemlocdist_itemsite_id = itemsite_id
    WHERE itemlocdist_series = pItemlocSeries
      AND (itemlocdist_qty < 0 OR (itemsite_loccntrl AND NOT itemsite_controlmethod IN ('L', 'S'))) LOOP

    _distCount := distributeToLocations(_r.itemlocdist_id);
    
    IF COALESCE(_distCount, 0) = 0 THEN
      RAISE EXCEPTION 'Expected a Count of the Distribution Detail Records Posted but 
          distributeToLocations(%) returned: % [xtuple: postDistDetail, -3, %, %]', 
          _r.itemlocdist_id, _distCount, _r.itemlocdist_id, _distCount;
    END IF;

    _distCountTotal := _distCountTotal + COALESCE(_distCount, 0);
  END LOOP;
 
  PERFORM postitemlocseries(pItemlocSeries);

  RETURN _distCountTotal;
END;
$$ LANGUAGE plpgsql;
