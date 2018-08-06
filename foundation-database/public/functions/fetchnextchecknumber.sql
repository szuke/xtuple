
CREATE OR REPLACE FUNCTION fetchNextCheckNumber(pBankaccntid INTEGER) RETURNS INTEGER AS $$
-- Copyright (c) 1999-2017 by OpenMFG LLC, d/b/a xTuple
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  _nextChkNumber INTEGER;
  _maxUsed       INTEGER;
  _result        INTEGER;

BEGIN

  SELECT bankaccnt_nextchknum INTO _nextChkNumber
    FROM bankaccnt
   WHERE (bankaccnt_id=pBankaccntid);

  SELECT MAX(checkhead_number) INTO _maxUsed
    FROM checkhead
   WHERE checkhead_bankaccnt_id=pBankaccntid;

  IF COALESCE(_maxUsed, 0) >= _nextChkNumber
     AND EXISTS (SELECT 1
                   FROM checkhead
                  WHERE checkhead_bankaccnt_id=pBankaccntid
                    AND checkhead_number=_nextChkNumber)
     AND NOT fetchmetricbool('ReprintPaymentNumbers') THEN
    SELECT prev + 1 INTO _result
      FROM (SELECT checkhead_number AS curr,
                   lag(checkhead_number) OVER (ORDER BY checkhead_number) AS prev
              FROM checkhead
             WHERE checkhead_bankaccnt_id=pBankaccntid
           ) numbers
     WHERE curr - prev > 1
       AND COALESCE(prev, -1) > 0
       AND prev >= _nextChkNumber
     ORDER BY curr
     LIMIT 1;
    _result := COALESCE(_result, _maxUsed + 1);
  END IF;
  _result := COALESCE(_result, _nextChkNumber, 1);

  UPDATE bankaccnt
     SET bankaccnt_nextchknum = _result + 1
   WHERE bankaccnt_id = pBankaccntid;

  RETURN _result;

END;
$$ LANGUAGE plpgsql;

