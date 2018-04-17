CREATE OR REPLACE FUNCTION buildInvBal(pItemsiteId INTEGER) RETURNS INTEGER AS $$
-- Copyright (c) 1999-2017 by OpenMFG LLC, d/b/a xTuple.
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  _numRows INTEGER;

BEGIN
  DELETE FROM invbal
  WHERE invbal_itemsite_id=pItemsiteId;

  INSERT INTO invbal
  (invbal_period_id, invbal_itemsite_id,
   invbal_qoh_beginning, invbal_qoh_ending, invbal_qty_in, invbal_qty_out,
   invbal_value_beginning, invbal_value_ending, invbal_value_in, invbal_value_out,
   invbal_nn_beginning, invbal_nn_ending, invbal_nn_in, invbal_nn_out,
   invbal_nnval_beginning, invbal_nnval_ending, invbal_nnval_in, invbal_nnval_out,
   invbal_dirty)
  SELECT period_id, pItemsiteId,
  COALESCE(lag(qty) OVER prev, 0.0), qty, qtyin, qtyout,
  COALESCE(lag(val) OVER prev, 0.0), val, valin, valout,
  COALESCE(lag(nn) OVER prev, 0.0), nn, nnin, nnout,
  COALESCE(lag(nnval) OVER prev, 0.0), nnval, nnvalin, nnvalout,
  false
  FROM
  (
   SELECT period_id, period_start,
          SUM(qtyin - qtyout) OVER runningtotal AS qty, qtyin, qtyout,
          SUM(valin - valout) OVER runningtotal AS val, valin, valout,
          SUM(nnin - nnout) OVER runningtotal AS nn, nnin, nnout,
          SUM(nnvalin - nnvalout) OVER runningtotal AS nnval, nnvalin, nnvalout
   FROM
   (
    SELECT period_id, period_start, 
           COALESCE(SUM(CASE WHEN qty > 0 THEN abs(qty) END), 0.0) AS qtyin,
           COALESCE(SUM(CASE WHEN qty < 0 THEN abs(qty) END), 0.0) AS qtyout,
           COALESCE(SUM(CASE WHEN val > 0 THEN abs(val) END), 0.0) AS valin,
           COALESCE(SUM(CASE WHEN val < 0 THEN abs(val) END), 0.0) AS valout,
           COALESCE(SUM(nnin), 0.0) AS nnin, COALESCE(SUM(nnout), 0.0) AS nnout,
           COALESCE(SUM(nnvalin), 0.0) AS nnvalin, COALESCE(SUM(nnvalout), 0.0) AS nnvalout
    FROM
    (
     SELECT period_id, period_start, qty, val,
            SUM(CASE WHEN nnqty > 0 THEN abs(nnqty) END) AS nnin,
            SUM(CASE WHEN nnqty < 0 THEN abs(nnqty) END) AS nnout,
            SUM(CASE WHEN nnval > 0 THEN abs(nnval) END) AS nnvalin,
            SUM(CASE WHEN nnval < 0 THEN abs(nnval) END) AS nnvalout
     FROM
     (
      SELECT period_id, period_start, invhist_id, qty, val, nnqty, ROUND(nnqty * cost, 2) AS nnval
      FROM
      (
       SELECT period_id, period_start, invhist_id,
              invhist_qoh_after - invhist_qoh_before AS qty,
              invhist_value_after - invhist_value_before AS val,
              invdetail_qty_after - invdetail_qty_before AS nnqty,
              invhist_unitcost AS cost
       FROM period
       LEFT OUTER JOIN invhist ON invhist_transdate::DATE BETWEEN period_start AND period_end
                              AND invhist_itemsite_id=pItemsiteId
                              AND invhist_posted
       LEFT OUTER JOIN (invdetail JOIN location ON invdetail_location_id=location_id
                                               AND NOT location_netable)
                    ON invdetail_invhist_id=invhist_id
      ) transactions
     ) values
     GROUP BY period_id, period_start, invhist_id, qty, val
    ) nntot
    GROUP BY period_id, period_start
   ) tot
   WINDOW runningtotal AS (ORDER BY period_start)
  ) runningtot
  WINDOW prev AS (ORDER BY period_start)
  ORDER BY period_start;

  GET DIAGNOSTICS _numRows := ROW_COUNT;

  RETURN _numRows;

END;
$$ LANGUAGE plpgsql;
