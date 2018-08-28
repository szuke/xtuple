CREATE OR REPLACE FUNCTION correctPoReceipt(pPorecvid INTEGER,
                                            pQty NUMERIC,
                                            pFreight NUMERIC,
                                            pItemlocSeries INTEGER) RETURNS INTEGER AS $$
-- Copyright (c) 1999-2017 by OpenMFG LLC, d/b/a xTuple.
-- See www.xtuple.com/CPAL for the full text of the software license.
BEGIN
  RETURN correctReceipt($1, $2, $3, $4, NULL, NULL);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION correctPoReceipt(INTEGER, NUMERIC, NUMERIC, INTEGER, INTEGER, DATE) RETURNS INTEGER AS $$
-- Copyright (c) 1999-2017 by OpenMFG LLC, d/b/a xTuple.
-- See www.xtuple.com/CPAL for the full text of the software license.
BEGIN
  RETURN correctReceipt($1, $2, $3, $4, $5, $6);
END;
$$ LANGUAGE plpgsql;
