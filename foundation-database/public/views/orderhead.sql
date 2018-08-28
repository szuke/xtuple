
SELECT dropIfExists('view', 'orderhead');
CREATE VIEW orderhead AS

  SELECT pohead.pohead_id AS orderhead_id,
    'PO'::text AS orderhead_type,
    pohead.pohead_number AS orderhead_number,
    pohead.pohead_status AS orderhead_status,
    pohead.pohead_orderdate AS orderhead_orderdate,
    ( SELECT count(*) AS count
           FROM poitem
          WHERE poitem.poitem_pohead_id = pohead.pohead_id) AS orderhead_linecount,
    pohead.pohead_vend_id AS orderhead_from_id,
    ( SELECT vendinfo.vend_name
           FROM vendinfo
          WHERE pohead.pohead_vend_id = vendinfo.vend_id) AS orderhead_from,
    NULL::integer AS orderhead_to_id,
    ''::text AS orderhead_to,
    pohead.pohead_curr_id AS orderhead_curr_id,
    pohead.pohead_agent_username AS orderhead_agent_username,
    pohead.pohead_shipvia AS orderhead_shipvia
    FROM pohead
  UNION ALL
  SELECT cohead.cohead_id AS orderhead_id,
    'SO'::text AS orderhead_type,
    cohead.cohead_number AS orderhead_number,
    cohead.cohead_status AS orderhead_status,
    cohead.cohead_orderdate AS orderhead_orderdate,
    ( SELECT count(*) AS count
           FROM coitem
          WHERE coitem.coitem_cohead_id = cohead.cohead_id) AS orderhead_linecount,
    NULL::integer AS orderhead_from_id,
    ''::text AS orderhead_from,
    cohead.cohead_cust_id AS orderhead_to_id,
        CASE
            WHEN length(cohead.cohead_shiptoname) > 0 THEN cohead.cohead_shiptoname
            ELSE cohead.cohead_billtoname
        END AS orderhead_to,
    cohead.cohead_curr_id AS orderhead_curr_id,
    ''::text AS orderhead_agent_username,
    cohead.cohead_shipvia AS orderhead_shipvia
    FROM cohead;

REVOKE ALL ON TABLE orderhead FROM PUBLIC;
GRANT  ALL ON TABLE orderhead TO GROUP xtrole;

COMMENT ON VIEW orderhead IS 'Union of all orders for use by widgets and stored procedures which process multiple types of order';
