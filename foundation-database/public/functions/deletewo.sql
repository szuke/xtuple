DROP FUNCTION IF EXISTS deleteWo(INTEGER, BOOLEAN);
CREATE OR REPLACE FUNCTION deleteWo(pWoid           INTEGER,
                                    pDeleteChildren BOOLEAN,
                                    pDeleteForce    BOOLEAN DEFAULT FALSE)
  RETURNS INTEGER AS $$
-- Copyright (c) 1999-2016 by OpenMFG LLC, d/b/a xTuple.
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  woStatus CHAR(1);
  itemType CHAR(1);
  ordtype CHAR(1);
  ordid INTEGER;
  wipValue NUMERIC;
  returnCode INTEGER;

BEGIN
  SELECT wo_status, wo_ordtype, wo_ordid, wo_wipvalue, item_type
  INTO woStatus, ordtype, ordid, wipValue, itemType
  FROM wo JOIN itemsite ON (itemsite_id=wo_itemsite_id)
          JOIN item ON (item_id=itemsite_item_id)
  WHERE (wo_id=pWoid);

  IF (wipValue > 0) THEN
    RAISE EXCEPTION 'You cannot delete a W/O with outstanding WIP value [xtuple: deleteWo, -4]';
  END IF;

  IF (pDeleteForce) THEN
    IF (NOT woStatus IN ('O', 'E', 'R', 'C')) THEN
      RAISE EXCEPTION 'The Work Order cannot be deleted in the current status [xtuple: deleteWo, -3]';
    END IF;
  ELSE
    IF (NOT woStatus IN ('O', 'E')) THEN
      RAISE EXCEPTION 'The Work Order cannot be deleted in the current status [xtuple: deleteWo, -3]';
    END IF;

    IF (itemType = 'J') THEN
      RAISE EXCEPTION 'The Work Order cannot be deleted for Job Item Types [xtuple: deleteWo, -2]';
    END IF;
  END IF;

  IF fetchMetricBool('Routings') AND woStatus != 'C'
     AND packageIsEnabled('xtmfg') THEN
    IF EXISTS(SELECT 1 FROM xtmfg.wotc WHERE wotc_wo_id = pWoid) THEN
      RAISE EXCEPTION 'The Work Order cannot be deleted because time clock entries exist [xtuple: deleteWo, -1]';
    END IF;
  END IF;

  IF (woStatus = 'R') THEN
    PERFORM postEvent('RWoRequestCancel', 'W', wo_id,
                      itemsite_warehous_id, formatWoNumber(wo_id),
                      NULL, NULL, NULL, NULL)
    FROM wo JOIN itemsite ON (itemsite_id=wo_itemsite_id)
            JOIN item ON (item_id=itemsite_item_id)
    WHERE (wo_id=pWoid);

     RETURN 0;
  ELSE
    IF (woStatus = 'E') THEN
      PERFORM implodeWo(pWoid, FALSE);
    END IF;
  END IF;

  IF (woStatus IN ('O', 'E', 'C')) THEN
    DELETE FROM womatl
    WHERE (womatl_wo_id=pWoid);

    IF fetchMetricBool('Routings') AND packageIsEnabled('xtmfg') THEN
      DELETE FROM xtmfg.wotc
      WHERE (wotc_wo_id=pWoid);
      DELETE FROM xtmfg.wooper
      WHERE (wooper_wo_id=pWoid);
    END IF;

    IF (ordtype = 'S') THEN
      UPDATE coitem SET coitem_order_type=NULL, coitem_order_id=NULL
      WHERE coitem_id=ordid;
    END IF;

    DELETE FROM wo
    WHERE (wo_id=pWoid);
  END IF;

  IF (pDeleteChildren) THEN
    PERFORM MAX(deleteWo(wo_id, TRUE))
       FROM wo
      WHERE wo_ordtype='W'
        AND wo_ordid = pWoid;
  END IF;

  RETURN 0;
END;
$$ LANGUAGE plpgsql;
