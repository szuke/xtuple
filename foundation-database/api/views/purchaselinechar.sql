-- Purchase Order Line Characteristics
SELECT dropifexists('VIEW','purchaselinechar','API');
CREATE VIEW api.purchaselinechar
AS 
SELECT 
    pohead_number AS order_number, 
    poitem_linenumber AS line_number,
    char_name AS characteristic,
    charass_value AS value
   FROM pohead, poitem, charass, char
   WHERE ( (pohead_id=poitem_pohead_id)
   AND (charass_char_id=char_id)
   AND (charass_target_id=poitem_id)
   AND (charass_target_type='PI') )
ORDER BY order_number,line_number, characteristic;

GRANT ALL ON TABLE api.purchaselinechar TO xtrole;
COMMENT ON VIEW api.purchaselinechar IS 'Purchase Order Line Item Characteristic';

--Rules

CREATE OR REPLACE RULE "_INSERT" AS
    ON INSERT TO api.purchaselinechar DO INSTEAD

SELECT DISTINCT updateCharAssignment('PI', poitem_id, charass_char_id, NEW.value)
FROM pohead, poitem, itemsite, item, charass, char
WHERE ((pohead_number=NEW.order_number)
AND (pohead_id=poitem_pohead_id)
AND (poitem_linenumber=NEW.line_number)
AND (poitem_itemsite_id=itemsite_id)
AND (item_id=itemsite_item_id)
AND (charass_target_type='I')
AND (charass_target_id=item_id)
AND (char_id=charass_char_id)
AND (char_name=NEW.characteristic));

CREATE OR REPLACE RULE "_UPDATE" AS 
    ON UPDATE TO api.purchaselinechar DO INSTEAD

SELECT DISTINCT updateCharAssignment('PI', poitem_id, charass_char_id, NEW.value)
FROM pohead, poitem, itemsite, item, charass, char
WHERE ((pohead_number=OLD.order_number)
AND (pohead_id=poitem_pohead_id)
AND (poitem_linenumber=OLD.line_number)
AND (poitem_itemsite_id=itemsite_id)
AND (item_id=itemsite_item_id)
AND (charass_target_type='I')
AND (charass_target_id=item_id)
AND (char_id=charass_char_id)
AND (char_name=OLD.characteristic));

CREATE OR REPLACE RULE "_DELETE" AS 
    ON DELETE TO api.purchaselinechar DO INSTEAD NOTHING;
