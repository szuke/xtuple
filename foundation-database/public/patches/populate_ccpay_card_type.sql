ALTER TABLE public.ccpay DISABLE TRIGGER ALL;

-- issue #23459 populate new ccpay_card_type col from ccard table
UPDATE ccpay
   SET ccpay_card_type = ccard_type
  FROM ccard
 WHERE ccard_id = ccpay_ccard_id
   AND ccpay_card_type IS NULL;

ALTER TABLE public.ccpay ENABLE TRIGGER ALL;
