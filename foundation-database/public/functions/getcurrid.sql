CREATE OR REPLACE FUNCTION getCurrId(pCurrName text) RETURNS INTEGER STABLE AS $$
-- Copyright (c) 1999-2017 by OpenMFG LLC, d/b/a xTuple.
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  _returnVal INTEGER;
BEGIN
  SELECT curr_id INTO _returnVal
    FROM public.curr_symbol   -- schema-qualified for bug 29358; generally bad
   WHERE curr_abbr = pCurrName;

  IF pCurrName IS NOT NULL AND _returnVal IS NULL THEN
    RAISE EXCEPTION 'Currency % not found [xtuple: getCurrId, -1, %]',
                    pCurrName, pCurrName;
  END IF;

  RETURN _returnVal;
END;
$$ LANGUAGE plpgsql;
