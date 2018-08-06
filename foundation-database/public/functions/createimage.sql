CREATE OR REPLACE FUNCTION public.createimage(
                                        pTitle text,
                                        pDescription text,
                                        pImageData TEXT)
  RETURNS integer AS $$
-- Copyright (c) 1999-2017 by OpenMFG LLC, d/b/a xTuple. 
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  _id integer;
BEGIN
  INSERT INTO image (image_name, image_descrip, image_data) 
             VALUES (pTitle, pDescription, pImageData)
  RETURNING image_id INTO _id;
  return _id;
END;
$$ LANGUAGE plpgsql;
