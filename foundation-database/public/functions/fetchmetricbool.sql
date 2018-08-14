CREATE OR REPLACE FUNCTION FetchMetricBool(text) 
RETURNS BOOLEAN AS $$
-- Copyright (c) 1999-2018 by OpenMFG LLC, d/b/a xTuple.
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  _pMetricName ALIAS FOR $1;
  _returnVal BOOLEAN;
BEGIN
  SELECT CASE 
    WHEN MIN(LOWER(metric_value)) IN ('t', 'true') THEN
     true
    ELSE
     false
    END INTO _returnVal
    FROM metric
   WHERE metric_name = _pMetricName;
  RETURN _returnVal;
END;
$$ LANGUAGE plpgsql STABLE;
