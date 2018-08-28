DO $$
DECLARE
  _r RECORD;
BEGIN
  FOR _r IN
    SELECT DISTINCT ON (trialbal_accnt_id) trialbal_id
    FROM trialbal
    JOIN period ON (period_id=trialbal_period_id)
    ORDER BY trialbal_accnt_id, period_end DESC
  LOOP
    PERFORM forwardupdatetrialbalance(_r.trialbal_id);
  END LOOP;
END;
$$ LANGUAGE plpgsql;
