CREATE OR REPLACE FUNCTION deleteItemlocSeries(pItemlocSeries INTEGER, pFailed BOOLEAN DEFAULT FALSE) RETURNS INTEGER AS $$
-- Copyright (c) 1999-2017 by OpenMFG LLC, d/b/a xTuple. 
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  _r              RECORD;
  _count          INTEGER := 0;
  _lsIdsToDelete  INTEGER[];
  _lsId           INTEGER;

BEGIN
  IF (pItemlocSeries IS NULL) THEN
    RAISE EXCEPTION 'Transaction series must be provided. [xtuple: deleteItemlocSeries, -1, %]', pItemlocSeries;
  END IF;

  -- In the case of a failed transaction, clean up orphaned records
  IF (pFailed) THEN
    DELETE
    FROM invdetail
    USING itemlocdist
      JOIN invhist ON invhist_id = itemlocdist_invhist_id
    WHERE invdetail_invhist_id = invhist_id 
      AND itemlocdist_series = pItemlocSeries;

    DELETE FROM invhist WHERE invhist_series = pItemlocSeries;
    
    DELETE FROM itemlocpost WHERE itemlocpost_itemlocseries = pItemlocseries;

    -- Reverse createLotSerial outcome   
    FOR _r IN 
      SELECT itemlocdist_id, itemlocdist_qty, itemlocdist_itemsite_id, 
        lsdetail_id, lsdetail_source_id, lsdetail_source_type, lsdetail_ls_id
      FROM getallitemlocdist(pItemlocSeries)
        JOIN lsdetail ON itemlocdist_id = lsdetail_source_id LOOP

      -- If there is no qoh for the lot (itemloc record), delete the lot number
      IF NOT EXISTS (
        SELECT true 
        FROM itemloc 
        WHERE itemloc_ls_id = _r.lsdetail_ls_id
        LIMIT 1) THEN

        _lsIdsToDelete := _lsIdsToDelete || _r.lsdetail_ls_id;
      END IF;

      -- Delete associated lsdetail records
      DELETE FROM lsdetail 
      WHERE lsdetail_id = _r.lsdetail_id;

    END LOOP;
  END IF;

  IF (SELECT TRUE FROM pg_proc WHERE proname = 'deleteitemlocdist') THEN
    PERFORM deleteItemlocdist(itemlocdist_id) FROM getallitemlocdist(pItemlocSeries);
  ELSE
    DELETE FROM itemlocdist 
      USING getallitemlocdist(pItemlocSeries) AS ilds 
    WHERE ilds.itemlocdist_id = itemlocdist.itemlocdist_id;
  END IF;
  
  GET DIAGNOSTICS _count = ROW_COUNT;

  -- Delete ls records last because of fkey constraints
  IF (pFailed AND _lsIdsToDelete IS NOT NULL) THEN 
    DELETE FROM charass 
      USING char
    WHERE charass_char_id = char_id 
      AND charass_target_id IN (SELECT (UNNEST(_lsIdsToDelete)))
      AND charass_target_type = 'LS';
    
    FOREACH _lsId IN ARRAY _lsIdsToDelete LOOP
      DELETE FROM ls
      WHERE ls_id = _lsId 
        AND (SELECT TRUE FROM itemlocdist WHERE itemlocdist_ls_id = _lsId LIMIT 1) IS NULL;
    END LOOP;
  END IF;
  
  RETURN _count;

END;
$$ LANGUAGE plpgsql;