CREATE OR REPLACE FUNCTION distributevoucherfreight(
    pVoheadid integer,
    pCostElement integer,
    pdistrtype text,
    pfreight numeric)
  RETURNS integer AS $$
-- Copyright (c) 1999-2016 by OpenMFG LLC, d/b/a xTuple.
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  _distr   RECORD;
  _vodist  RECORD;
BEGIN

  FOR _distr IN
    SELECT * FROM calculatefreightdistribution(pVoheadid, pCostElement, pDistrType, pFreight, false)
  LOOP
    SELECT vodist_taxtype_id AS taxtype,
           vodist_qty AS qty,
           vodist_discountable AS discountable
    INTO _vodist
    FROM vodist
    WHERE vodist_vohead_id = pVoHeadid
    AND vodist_poitem_id = _distr.freightdistr_poitem_id
    AND vodist_costelem_id <> pCostElement
    LIMIT 1;

    IF (FOUND) THEN
      INSERT INTO vodist (vodist_poitem_id, vodist_vohead_id, vodist_costelem_id, vodist_amount,
                        vodist_qty, vodist_expcat_id, vodist_tax_id, vodist_discountable,
                        vodist_notes, vodist_taxtype_id)
      VALUES (_distr.freightdistr_poitem_id, pVoHeadid, pCostElement,  _distr.freightdistr_amount,
              _vodist.qty, -1, -1, _vodist.discountable, 'Freight Auto Distribution', _vodist.taxtype);
    END IF;
  END LOOP;

  RETURN pVoheadid;
END;
$$ LANGUAGE plpgsql;
