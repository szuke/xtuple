DO $$
  var dropSql = "drop view if exists xt.quheadinfo cascade;";
  var sql = "create or replace view xt.quheadinfo as " +
  "select quhead.*, " +
    "xt.quote_schedule_date(quhead) as schedule_date, " +
    "xt.quote_freight_weight(quhead) as freight_weight, " +
    "xt.quote_subtotal(quhead) as subtotal, " +
    "xt.quote_tax_total(quhead) as tax_total, " +
    "xt.quote_total(quhead) as total, " +
    "xt.quote_margin(quhead) as margin " +
  "from quhead; ";

  try {
    plv8.execute(sql);
  } catch (error) {
    /* let's cascade-drop the view and try again */
    plv8.execute(dropSql);
    plv8.execute(sql);
  }

$$ language plv8;
          
revoke all on xt.quheadinfo from public;
grant all on table xt.quheadinfo to group xtrole;

create or replace rule "_INSERT" as on insert to xt.quheadinfo do instead (

insert into quhead (
  quhead_id,
  quhead_number,
  quhead_cust_id,
  quhead_quotedate,
  quhead_shipto_id,
  quhead_shiptoname,
  quhead_shiptoaddress1,
  quhead_shiptoaddress2,
  quhead_shiptoaddress3,
  quhead_shiptocity,
  quhead_shiptostate,
  quhead_shiptozipcode,
  quhead_shiptophone,
  quhead_salesrep_id,
  quhead_terms_id,
  quhead_freight,
  quhead_ordercomments,
  quhead_shipcomments,
  quhead_billtoname,
  quhead_billtoaddress1,
  quhead_billtoaddress2,
  quhead_billtoaddress3,
  quhead_billtocity,
  quhead_billtostate,
  quhead_billtozip,
  quhead_commission,
  quhead_custponumber,
  quhead_fob,
  quhead_shipvia,
  quhead_warehous_id,
  quhead_packdate,
  quhead_prj_id,
  quhead_misc,
  quhead_misc_accnt_id,
  quhead_misc_descrip,
  quhead_billtocountry,
  quhead_shiptocountry,
  quhead_curr_id,
  quhead_imported,
  quhead_expire,
  quhead_calcfreight,
  quhead_shipto_cntct_id,
  quhead_shipto_cntct_honorific,
  quhead_shipto_cntct_first_name,
  quhead_shipto_cntct_middle,
  quhead_shipto_cntct_last_name,
  quhead_shipto_cntct_suffix,
  quhead_shipto_cntct_phone,
  quhead_shipto_cntct_title,
  quhead_shipto_cntct_fax,
  quhead_shipto_cntct_email,
  quhead_billto_cntct_id,
  quhead_billto_cntct_honorific,
  quhead_billto_cntct_first_name,
  quhead_billto_cntct_middle,
  quhead_billto_cntct_last_name,
  quhead_billto_cntct_suffix,
  quhead_billto_cntct_phone,
  quhead_billto_cntct_title,
  quhead_billto_cntct_fax,
  quhead_billto_cntct_email,
  quhead_taxzone_id,
  quhead_taxtype_id,
  quhead_ophead_id,
  quhead_status,
  quhead_saletype_id,
  quhead_shipzone_id
) values (
  new.quhead_id,
  new.quhead_number,
  new.quhead_cust_id,
  new.quhead_quotedate,
  new.quhead_shipto_id,
  new.quhead_shiptoname,
  new.quhead_shiptoaddress1,
  new.quhead_shiptoaddress2,
  new.quhead_shiptoaddress3,
  new.quhead_shiptocity,
  new.quhead_shiptostate,
  new.quhead_shiptozipcode,
  new.quhead_shiptophone,
  new.quhead_salesrep_id,
  new.quhead_terms_id,
  new.quhead_freight,
  new.quhead_ordercomments,
  new.quhead_shipcomments,
  new.quhead_billtoname,
  new.quhead_billtoaddress1,
  new.quhead_billtoaddress2,
  new.quhead_billtoaddress3,
  new.quhead_billtocity,
  new.quhead_billtostate,
  new.quhead_billtozip,
  new.quhead_commission,
  new.quhead_custponumber,
  new.quhead_fob,
  new.quhead_shipvia,
  new.quhead_warehous_id,
  new.quhead_packdate,
  new.quhead_prj_id,
  new.quhead_misc,
  new.quhead_misc_accnt_id,
  new.quhead_misc_descrip,
  new.quhead_billtocountry,
  new.quhead_shiptocountry,
  new.quhead_curr_id,
  new.quhead_imported,
  new.quhead_expire,
  new.quhead_calcfreight,
  new.quhead_shipto_cntct_id,
  new.quhead_shipto_cntct_honorific,
  new.quhead_shipto_cntct_first_name,
  new.quhead_shipto_cntct_middle,
  new.quhead_shipto_cntct_last_name,
  new.quhead_shipto_cntct_suffix,
  new.quhead_shipto_cntct_phone,
  new.quhead_shipto_cntct_title,
  new.quhead_shipto_cntct_fax,
  new.quhead_shipto_cntct_email,
  new.quhead_billto_cntct_id,
  new.quhead_billto_cntct_honorific,
  new.quhead_billto_cntct_first_name,
  new.quhead_billto_cntct_middle,
  new.quhead_billto_cntct_last_name,
  new.quhead_billto_cntct_suffix,
  new.quhead_billto_cntct_phone,
  new.quhead_billto_cntct_title,
  new.quhead_billto_cntct_fax,
  new.quhead_billto_cntct_email,
  new.quhead_taxzone_id,
  new.quhead_taxtype_id,
  new.quhead_ophead_id,
  new.quhead_status,
  new.quhead_saletype_id,
  new.quhead_shipzone_id
);
select xt.update_version('public', 'quhead', new.quhead_id, 'INSERT'); 
);

create or replace rule "_UPDATE" as on update to xt.quheadinfo do instead (

update quhead set
  quhead_number = new.quhead_number,
  quhead_cust_id = new.quhead_cust_id,
  quhead_quotedate = new.quhead_quotedate,
  quhead_shipto_id = new.quhead_shipto_id,
  quhead_shiptoname = new.quhead_shiptoname,
  quhead_shiptoaddress1 = new.quhead_shiptoaddress1,
  quhead_shiptoaddress2 = new.quhead_shiptoaddress2,
  quhead_shiptoaddress3 = new.quhead_shiptoaddress3,
  quhead_shiptocity = new.quhead_shiptocity,
  quhead_shiptostate = new.quhead_shiptostate,
  quhead_shiptozipcode = new.quhead_shiptozipcode,
  quhead_shiptophone = new.quhead_shiptophone,
  quhead_salesrep_id = new.quhead_salesrep_id,
  quhead_terms_id = new.quhead_terms_id,
  quhead_freight = new.quhead_freight,
  quhead_ordercomments = new.quhead_ordercomments,
  quhead_shipcomments = new.quhead_shipcomments,
  quhead_billtoname = new.quhead_billtoname,
  quhead_billtoaddress1 = new.quhead_billtoaddress1,
  quhead_billtoaddress2 = new.quhead_billtoaddress2,
  quhead_billtoaddress3 = new.quhead_billtoaddress3,
  quhead_billtocity = new.quhead_billtocity,
  quhead_billtostate = new.quhead_billtostate,
  quhead_billtozip = new.quhead_billtozip,
  quhead_commission = new.quhead_commission,
  quhead_custponumber = new.quhead_custponumber,
  quhead_fob = new.quhead_fob,
  quhead_shipvia = new.quhead_shipvia,
  quhead_warehous_id = new.quhead_warehous_id,
  quhead_packdate = new.quhead_packdate,
  quhead_prj_id = new.quhead_prj_id,
  quhead_misc = new.quhead_misc,
  quhead_misc_accnt_id = new.quhead_misc_accnt_id,
  quhead_misc_descrip = new.quhead_misc_descrip,
  quhead_billtocountry = new.quhead_billtocountry,
  quhead_shiptocountry = new.quhead_shiptocountry,
  quhead_curr_id = new.quhead_curr_id,
  quhead_imported = new.quhead_imported,
  quhead_expire = new.quhead_expire,
  quhead_calcfreight = new.quhead_calcfreight,
  quhead_shipto_cntct_id = new.quhead_shipto_cntct_id,
  quhead_shipto_cntct_honorific = new.quhead_shipto_cntct_honorific,
  quhead_shipto_cntct_first_name = new.quhead_shipto_cntct_first_name,
  quhead_shipto_cntct_middle = new.quhead_shipto_cntct_middle,
  quhead_shipto_cntct_last_name = new.quhead_shipto_cntct_last_name,
  quhead_shipto_cntct_suffix = new.quhead_shipto_cntct_suffix,
  quhead_shipto_cntct_phone = new.quhead_shipto_cntct_phone,
  quhead_shipto_cntct_title = new.quhead_shipto_cntct_title,
  quhead_shipto_cntct_fax = new.quhead_shipto_cntct_fax,
  quhead_shipto_cntct_email = new.quhead_shipto_cntct_email,
  quhead_billto_cntct_id = new.quhead_billto_cntct_id,
  quhead_billto_cntct_honorific = new.quhead_billto_cntct_honorific,
  quhead_billto_cntct_first_name = new.quhead_billto_cntct_first_name,
  quhead_billto_cntct_middle = new.quhead_billto_cntct_middle,
  quhead_billto_cntct_last_name = new.quhead_billto_cntct_last_name,
  quhead_billto_cntct_suffix = new.quhead_billto_cntct_suffix,
  quhead_billto_cntct_phone = new.quhead_billto_cntct_phone,
  quhead_billto_cntct_title = new.quhead_billto_cntct_title,
  quhead_billto_cntct_fax = new.quhead_billto_cntct_fax,
  quhead_billto_cntct_email = new.quhead_billto_cntct_email,
  quhead_taxzone_id = new.quhead_taxzone_id,
  quhead_taxtype_id = new.quhead_taxtype_id,
  quhead_ophead_id = new.quhead_ophead_id,
  quhead_status = new.quhead_status,
  quhead_saletype_id = new.quhead_saletype_id,
  quhead_shipzone_id = quhead_shipzone_id
where quhead_id = old.quhead_id;
select xt.update_version('public', 'quhead', new.quhead_id, 'UPDATE'); 
);

create or replace rule "_DELETE" as on delete to xt.quheadinfo do instead (

select deletequote(old.quhead_id);
select xt.update_version('public', 'quhead', old.quhead_id, 'DELETE'); 

);