--DROP FUNCTION IF EXISTS currToBase(INTEGER, NUMERIC, DATE) CASCADE;
--HACK: The above line causes issue #29619, removing important views from xtdash
--Normally functions need to be dropped in case of function signature change
--We can skip that step in this case because the function signature has been the same up until now
--and it is only a problem after parameters are given a name
--This prevents dependent views from being deleted

CREATE OR REPLACE FUNCTION currToBase(pId    INTEGER,
                                      pValue NUMERIC,
                                      pDate  DATE) RETURNS NUMERIC STABLE AS $$
-- Copyright (c) 1999-2017 by OpenMFG LLC, d/b/a xTuple.
-- See www.xtuple.com/CPAL for the full text of the software license.
-- watch for bug #3901 - rounding because of the CurrencyExchangeSense metric
DECLARE
  _date   DATE    := COALESCE(pDate,  CURRENT_DATE);
  _output NUMERIC := COALESCE(pValue, 0.0);
BEGIN

  IF _output != 0.0 THEN
    SELECT pValue / curr_rate INTO  _output
      FROM public.curr_rate     -- schema-qualified for bug 29358; generally bad
     WHERE curr_id = pId
       AND _date BETWEEN curr_effective AND curr_expires;
  END IF;

  IF _output IS NULL THEN
    RAISE EXCEPTION 'No exchange rate for % on % [xtuple: currToBase, -1, %, %, %]',
                    pId, _date, pId, pValue, pDate;
  END IF;

  RETURN _output;
END;
$$ LANGUAGE plpgsql;
