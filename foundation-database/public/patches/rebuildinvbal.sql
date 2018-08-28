DO $$
BEGIN

  IF (fetchMetricBool('EnableAsOfQOH')) THEN
    PERFORM buildInvBal(invbal_itemsite_id)
    FROM
    (SELECT DISTINCT invbal_itemsite_id,
            COALESCE(SUM(abs(qty)), 0.0)=CASE WHEN qtyin THEN invbal_qty_in
                                              WHEN qtyout THEN invbal_qty_out
                                              ELSE 0.0 END AS valid
     FROM
     (SELECT invbal_id, invbal_itemsite_id, invbal_qty_in, invbal_qty_out,
             invhist_qoh_after - invhist_qoh_before AS qty,
             invhist_qoh_after - invhist_qoh_before > 0 AS qtyin,
             invhist_qoh_after - invhist_qoh_before < 0 AS qtyout
      FROM invbal
      JOIN period ON invbal_period_id=period_id
      LEFT OUTER JOIN invhist ON invbal_itemsite_id=invhist_itemsite_id
                             AND invhist_transdate BETWEEN period_start AND period_end) transactions
     GROUP BY invbal_id, invbal_itemsite_id, invbal_qty_in, invbal_qty_out, qtyin, qtyout) invbal
    WHERE NOT valid;
  END IF;

END;
$$ LANGUAGE plpgsql;
