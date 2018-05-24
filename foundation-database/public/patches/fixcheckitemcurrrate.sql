DO $$
DECLARE
  _base INTEGER;
  _old BOOLEAN;
  _r RECORD;
  _curr RECORD;
  _count INTEGER;

BEGIN

  IF (SELECT COUNT(*) = 1 FROM curr_symbol) THEN
    RETURN;
  END IF;

  -- This patch should have already run
  IF compareVersion(fetchMetricText('ServerVersion'), '4.11.3') > 0 THEN
    RETURN;
  END IF;

  _base := baseCurrID();
  -- Before previous version of this patch that deleted some old useful data
  _old := compareVersion(fetchMetricText('ServerVersion'), '4.11.1') < 0;

  UPDATE checkitem
     SET checkitem_currdate = checkhead_checkdate
    FROM checkhead
   WHERE checkitem_checkhead_id = checkhead_id;

  UPDATE checkitem
     SET checkitem_curr_rate = 1.0
   WHERE checkitem_curr_id = _base
     AND checkitem_curr_rate != 1.0;

  -- Loop over checkhead instead of checkitem due to potential use of SUM.
  -- Performance optimization because there can be a lot of checkitem records.
  FOR _r IN SELECT checkhead_id, checkhead_curr_id, checkhead_curr_rate, checkhead_checkdate,
                   checkhead_amount
              FROM checkhead
             WHERE EXISTS (SELECT 1
                             FROM checkitem
                            WHERE checkitem_checkhead_id = checkhead_id
                              AND checkitem_curr_id != _base)
  LOOP
    SELECT MAX(checkitem_curr_id) AS curr, COUNT(DISTINCT checkitem_curr_id) AS count,
           COUNT(checkitem_id) AS countitems INTO _curr
      FROM checkitem
     WHERE checkitem_checkhead_id = _r.checkhead_id;

    IF (_curr.count = 1 AND _curr.curr = _r.checkhead_curr_id) THEN
      UPDATE checkitem
         SET checkitem_curr_rate = _r.checkhead_curr_rate
       WHERE checkitem_checkhead_id = _r.checkhead_id
         AND checkitem_curr_rate != _r.checkhead_curr_rate;
    ELSE
      IF _old THEN
        WITH curr AS (SELECT checkitem_curr_id,
                             currRate(checkitem_curr_id, _r.checkhead_checkdate) AS stored
                        FROM checkitem
                       WHERE checkitem_checkhead_id = _r.checkhead_id
                       GROUP BY checkitem_curr_id),
             rate AS (SELECT checkitem_curr_rate * _r.checkhead_curr_rate AS actual, stored
                        FROM checkitem
                        JOIN curr ON checkitem.checkitem_curr_id = curr.checkitem_curr_id
                       WHERE checkitem_checkhead_id = _r.checkhead_id)
        UPDATE checkitem
           SET checkitem_curr_rate = CASE WHEN ROUND(rate.actual, 6) = ROUND(rate.stored, 6)
                                          THEN rate.stored
                                          ELSE rate.actual
                                      END
          FROM rate
         WHERE checkitem_checkhead_id = _r.checkhead_id
           AND checkitem_curr_id != _base
           AND checkitem_apopen_id IS NOT NULL
           AND checkitem_curr_rate != 1.0; -- Assume it's from the bad first migration if rate is 1

        GET DIAGNOSTICS _count = ROW_COUNT;

        IF _count < _curr.countitems AND _curr.count = 1 THEN
          WITH curr AS (SELECT checkitem_curr_id,
                               currRate(checkitem_curr_id, _r.checkhead_checkdate) AS stored
                          FROM checkitem
                         WHERE checkitem_checkhead_id = _r.checkhead_id
                         GROUP BY checkitem_curr_id),
               rate AS (SELECT SUM(checkitem_amount) / _r.checkhead_amount *
                               _r.checkhead_curr_rate AS actual, stored
                          FROM checkitem
                          JOIN curr ON checkitem.checkitem_curr_id = curr.checkitem_curr_id
                         WHERE checkitem_checkhead_id = _r.checkhead_id
                         GROUP BY stored)
          UPDATE checkitem
             SET checkitem_curr_rate = CASE WHEN ROUND(rate.actual, 6) = ROUND(rate.stored, 6)
                                            THEN rate.stored
                                            ELSE rate.actual
                                        END
           FROM rate
          WHERE checkitem_checkhead_id = _r.checkhead_id
            AND (checkitem_apopen_id IS NULL
                 OR checkitem_curr_rate = 1.0);
        ELSIF _count < _curr.countitems THEN
          UPDATE checkitem
             SET checkitem_curr_id = currRate(checkitem_curr_id, _r.checkhead_checkdate)
           WHERE checkitem_checkhead_id = _r.checkhead_id
             AND checkitem_curr_id != _base
             AND (checkitem_apopen_id IS NULL
                  OR checkitem_curr_rate = 1.0);
        END IF;
      ELSE
        -- Similar if blocks instead of where clauses for performance reasons
        IF _curr.count = 1 THEN
          WITH curr AS (SELECT checkitem_curr_id,
                               currRate(checkitem_curr_id, _r.checkhead_checkdate) AS stored
                          FROM checkitem
                         WHERE checkitem_checkhead_id = _r.checkhead_id
                         GROUP BY checkitem_curr_id),
               rate AS (SELECT SUM(checkitem_amount) / _r.checkhead_amount *
                               _r.checkhead_curr_rate AS actual, stored
                          FROM checkitem
                          JOIN curr ON checkitem.checkitem_curr_id = curr.checkitem_curr_id
                         WHERE checkitem_checkhead_id = _r.checkhead_id
                         GROUP BY stored)
          UPDATE checkitem
             SET checkitem_curr_rate = CASE WHEN ROUND(rate.actual, 6) = ROUND(rate.stored, 6)
                                            THEN rate.stored
                                            ELSE rate.actual
                                        END
           FROM rate
          WHERE checkitem_checkhead_id = _r.checkhead_id;
        ELSE
          UPDATE checkitem
             SET checkitem_curr_id = currRate(checkitem_curr_id, _r.checkhead_checkdate)
           WHERE checkitem_checkhead_id = _r.checkhead_id
             AND checkitem_curr_id != _base;
        END IF;
      END IF;
    END IF;
  END LOOP;

END;
$$ language plpgsql;
