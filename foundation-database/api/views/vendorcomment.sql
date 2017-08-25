-- Vendor Comment

SELECT dropIfExists('VIEW', 'vendorcomment', 'api');
CREATE VIEW api.vendorcomment
AS 
   SELECT vendinfo.vend_number::character varying AS vendor_number,
    cmnttype.cmnttype_name AS type,
    comment.comment_date AS date,
    comment.comment_user AS username,
    comment.comment_text AS text
   FROM vendinfo,
    cmnttype,
    comment
  WHERE comment.comment_source = 'V'::text AND comment.comment_source_id = vendinfo.vend_id AND comment.comment_cmnttype_id = cmnttype.cmnttype_id;

ALTER TABLE api.vendorcomment
  OWNER TO admin;
GRANT ALL ON TABLE api.vendorcomment TO admin;
GRANT ALL ON TABLE api.vendorcomment TO xtrole;
COMMENT ON VIEW api.vendorcomment
  IS 'Vendor Comment';

-- Rules

CREATE OR REPLACE RULE "_DELETE" AS
    ON DELETE TO api.vendorcomment DO INSTEAD NOTHING;

CREATE OR REPLACE RULE "_INSERT" AS
    ON INSERT TO api.vendorcomment DO INSTEAD  INSERT INTO comment (comment_date, comment_source, comment_source_id, comment_user, comment_cmnttype_id, comment_text)
  VALUES (COALESCE(new.date, now()), 'V'::text, getvendid(new.vendor_number::text), COALESCE(new.username, geteffectivextuser()), getcmnttypeid(new.type), new.text);

CREATE OR REPLACE RULE "_UPDATE" AS
    ON UPDATE TO api.vendorcomment DO INSTEAD NOTHING;
