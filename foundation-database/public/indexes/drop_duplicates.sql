/*  
   Remove duplicate Indexes created in 440 schema and typically recreated in
   subsequent constraints or scripts in the manifest
*/

DROP INDEX IF EXISTS item_number_idx;
DROP INDEX IF EXISTS cohead_number_idx;
DROP INDEX IF EXISTS vend_number_idx;
DROP INDEX IF EXISTS cust_number_idx;
ALTER TABLE public.ipsitemchar DROP CONSTRAINT IF EXISTS ipsitemchar_ipsitemchar_ipsitem_id_key1;
DROP INDEX IF EXISTS apselect_apselect_apopen_id_idx;

