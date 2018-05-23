-- Dumped from database version 9.1.12
-- Dumped by pg_dump version 9.1.12
-- Started on 2014-03-27 11:30:47 EDT

SET statement_timeout = 0;
SET client_encoding = 'SQL_ASCII';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;


CREATE SCHEMA api;
ALTER SCHEMA api OWNER TO admin;

REVOKE ALL ON SCHEMA api FROM PUBLIC;
REVOKE ALL ON SCHEMA api FROM admin;
GRANT ALL ON SCHEMA api TO admin;
GRANT ALL ON SCHEMA api TO xtrole;

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;
COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';

SET search_path = public, pg_catalog;

--
-- TOC entry 2699 (class 1247 OID 146565224)
-- Dependencies: 8 182
-- Name: seqiss; Type: TYPE; Schema: public; Owner: admin
--

CREATE TYPE seqiss AS (
       seqiss_number integer,
       seqiss_time timestamp with time zone
);


ALTER TYPE public.seqiss OWNER TO admin;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 189 (class 1259 OID 146565245)
-- Dependencies: 5838 8
-- Name: cntslip; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE cntslip (
    cntslip_id integer DEFAULT nextval(('"cntslip_cntslip_id_seq"'::text)::regclass) NOT NULL,
    cntslip_cnttag_id integer,
    cntslip_entered timestamp with time zone,
    cntslip_posted boolean,
    cntslip_number text,
    cntslip_qty numeric(18,6),
    cntslip_comments text,
    cntslip_location_id integer,
    cntslip_lotserial text,
    cntslip_lotserial_expiration date,
    cntslip_lotserial_warrpurc date,
    cntslip_username text
);


ALTER TABLE public.cntslip OWNER TO admin;

--
-- TOC entry 8908 (class 0 OID 0)
-- Dependencies: 189
-- Name: TABLE cntslip; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE cntslip IS 'Count Slip information';


--
-- TOC entry 190 (class 1259 OID 146565252)
-- Dependencies: 5839 8
-- Name: invcnt; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE invcnt (
    invcnt_id integer DEFAULT nextval(('invcnt_invcnt_id_seq'::text)::regclass) NOT NULL,
    invcnt_itemsite_id integer,
    invcnt_tagdate timestamp with time zone,
    invcnt_cntdate timestamp with time zone,
    invcnt_qoh_before numeric(18,6),
    invcnt_qoh_after numeric(18,6),
    invcnt_matcost numeric(16,6),
    invcnt_posted boolean,
    invcnt_postdate timestamp with time zone,
    invcnt_comments text,
    invcnt_priority boolean,
    invcnt_tagnumber text,
    invcnt_invhist_id integer,
    invcnt_location_id integer,
    invcnt_cnt_username text,
    invcnt_post_username text,
    invcnt_tag_username text
);


ALTER TABLE public.invcnt OWNER TO admin;

--
-- TOC entry 8910 (class 0 OID 0)
-- Dependencies: 190
-- Name: TABLE invcnt; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE invcnt IS 'Count Tag information';


--
-- TOC entry 191 (class 1259 OID 146565259)
-- Dependencies: 5840 5841 5842 5843 5844 5845 5846 5847 5848 5849 5850 5851 5852 5853 8
-- Name: item; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE item (
    item_id integer DEFAULT nextval(('item_item_id_seq'::text)::regclass) NOT NULL,
    item_number text NOT NULL,
    item_descrip1 text NOT NULL,
    item_descrip2 text NOT NULL,
    item_classcode_id integer NOT NULL,
    item_picklist boolean DEFAULT true NOT NULL,
    item_comments text,
    item_sold boolean NOT NULL,
    item_fractional boolean NOT NULL,
    item_active boolean NOT NULL,
    item_type character(1) DEFAULT 'R'::bpchar NOT NULL,
    item_prodweight numeric(16,2) DEFAULT 0 NOT NULL,
    item_packweight numeric(16,2) DEFAULT 0 NOT NULL,
    item_prodcat_id integer NOT NULL,
    item_exclusive boolean DEFAULT false NOT NULL,
    item_listprice numeric(16,4) NOT NULL,
    item_config boolean DEFAULT false,
    item_extdescrip text,
    item_upccode text,
    item_maxcost numeric(16,6) DEFAULT 0 NOT NULL,
    item_inv_uom_id integer NOT NULL,
    item_price_uom_id integer NOT NULL,
    item_warrdays integer DEFAULT 0,
    item_freightclass_id integer,
    item_tax_recoverable boolean DEFAULT false NOT NULL,
    item_listcost numeric(16,6) DEFAULT 0.0 NOT NULL,
    CONSTRAINT item_item_number_check CHECK ((item_number <> ''::text)),
    CONSTRAINT item_item_type_check CHECK (((((((((((((item_type = 'P'::bpchar) OR (item_type = 'M'::bpchar)) OR (item_type = 'F'::bpchar)) OR (item_type = 'O'::bpchar)) OR (item_type = 'R'::bpchar)) OR (item_type = 'S'::bpchar)) OR (item_type = 'T'::bpchar)) OR (item_type = 'B'::bpchar)) OR (item_type = 'L'::bpchar)) OR (item_type = 'Y'::bpchar)) OR (item_type = 'C'::bpchar)) OR (item_type = 'K'::bpchar))),
    CONSTRAINT item_sold_check CHECK ((NOT (item_sold AND (item_prodcat_id = (-1)))))
);


ALTER TABLE public.item OWNER TO admin;


--
-- TOC entry 192 (class 1259 OID 146565279)
-- Dependencies: 5854 5855 5856 5857 5858 5859 5860 5861 5862 5863 5864 5865 5866 5867 5868 5869 5870 5871 5872 5873 5874 5875 5876 5877 5878 5879 5880 8
-- Name: itemsite; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE itemsite (
    itemsite_id integer DEFAULT nextval(('itemsite_itemsite_id_seq'::text)::regclass) NOT NULL,
    itemsite_item_id integer NOT NULL,
    itemsite_warehous_id integer,
    itemsite_qtyonhand numeric(18,6) NOT NULL,
    itemsite_reorderlevel numeric(18,6) NOT NULL,
    itemsite_ordertoqty numeric(18,6) NOT NULL,
    itemsite_cyclecountfreq integer NOT NULL,
    itemsite_datelastcount date,
    itemsite_datelastused date,
    itemsite_loccntrl boolean NOT NULL,
    itemsite_safetystock numeric(18,6) NOT NULL,
    itemsite_minordqty numeric(18,6) NOT NULL,
    itemsite_multordqty numeric(18,6) NOT NULL,
    itemsite_leadtime integer NOT NULL,
    itemsite_abcclass character(1),
    itemsite_issuemethod character(1),
    itemsite_controlmethod character(1),
    itemsite_active boolean NOT NULL,
    itemsite_plancode_id integer NOT NULL,
    itemsite_costcat_id integer NOT NULL,
    itemsite_eventfence integer NOT NULL,
    itemsite_sold boolean NOT NULL,
    itemsite_stocked boolean NOT NULL,
    itemsite_freeze boolean DEFAULT false NOT NULL,
    itemsite_location_id integer NOT NULL,
    itemsite_useparams boolean NOT NULL,
    itemsite_useparamsmanual boolean NOT NULL,
    itemsite_soldranking integer DEFAULT 1,
    itemsite_createpr boolean,
    itemsite_location text,
    itemsite_location_comments text,
    itemsite_notes text,
    itemsite_perishable boolean NOT NULL,
    itemsite_nnqoh numeric(18,6) DEFAULT 0 NOT NULL,
    itemsite_autoabcclass boolean NOT NULL,
    itemsite_ordergroup integer DEFAULT 1 NOT NULL,
    itemsite_disallowblankwip boolean DEFAULT false NOT NULL,
    itemsite_maxordqty numeric(18,6) DEFAULT 0.0 NOT NULL,
    itemsite_mps_timefence integer DEFAULT 0 NOT NULL,
    itemsite_createwo boolean DEFAULT false NOT NULL,
    itemsite_warrpurc boolean DEFAULT false NOT NULL,
    itemsite_autoreg boolean DEFAULT false,
    itemsite_costmethod character(1) NOT NULL,
    itemsite_value numeric(12,2) NOT NULL,
    itemsite_ordergroup_first boolean DEFAULT false NOT NULL,
    itemsite_supply_itemsite_id integer,
    itemsite_planning_type character(1) DEFAULT 'M'::bpchar NOT NULL,
    itemsite_wosupply boolean DEFAULT false NOT NULL,
    itemsite_posupply boolean DEFAULT false NOT NULL,
    itemsite_lsseq_id integer,
    itemsite_cosdefault character(1),
    itemsite_createsopr boolean DEFAULT false,
    itemsite_createsopo boolean DEFAULT false,
    itemsite_dropship boolean DEFAULT false,
    itemsite_recvlocation_id integer DEFAULT (-1) NOT NULL,
    itemsite_issuelocation_id integer DEFAULT (-1) NOT NULL,
    itemsite_location_dist boolean DEFAULT false NOT NULL,
    itemsite_recvlocation_dist boolean DEFAULT false NOT NULL,
    itemsite_issuelocation_dist boolean DEFAULT false NOT NULL,
    CONSTRAINT itemsite_itemsite_abcclass_check CHECK (((((itemsite_abcclass = 'A'::bpchar) OR (itemsite_abcclass = 'B'::bpchar)) OR (itemsite_abcclass = 'C'::bpchar)) OR (itemsite_abcclass = 'T'::bpchar))),
    CONSTRAINT itemsite_itemsite_controlmethod_check CHECK (((((itemsite_controlmethod = 'N'::bpchar) OR (itemsite_controlmethod = 'R'::bpchar)) OR (itemsite_controlmethod = 'S'::bpchar)) OR (itemsite_controlmethod = 'L'::bpchar))),
    CONSTRAINT itemsite_itemsite_costmethod_check CHECK (((((itemsite_costmethod = 'N'::bpchar) OR (itemsite_costmethod = 'A'::bpchar)) OR (itemsite_costmethod = 'S'::bpchar)) OR (itemsite_costmethod = 'J'::bpchar))),
    CONSTRAINT itemsite_itemsite_ordergroup_check CHECK ((itemsite_ordergroup > 0))
);


ALTER TABLE public.itemsite OWNER TO admin;


--
-- TOC entry 193 (class 1259 OID 146565312)
-- Dependencies: 5881 5882 5883 5884 5885 5886 8
-- Name: whsinfo; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE whsinfo (
    warehous_id integer DEFAULT nextval(('warehous_warehous_id_seq'::text)::regclass) NOT NULL,
    warehous_code text NOT NULL,
    warehous_descrip text,
    warehous_fob text,
    warehous_active boolean,
    warehous_counttag_prefix text,
    warehous_counttag_number integer,
    warehous_bol_prefix text,
    warehous_bol_number integer,
    warehous_shipping boolean,
    warehous_useslips boolean,
    warehous_usezones boolean,
    warehous_aislesize integer,
    warehous_aislealpha boolean,
    warehous_racksize integer,
    warehous_rackalpha boolean,
    warehous_binsize integer,
    warehous_binalpha boolean,
    warehous_locationsize integer,
    warehous_locationalpha boolean,
    warehous_enforcearbl boolean,
    warehous_default_accnt_id integer,
    warehous_shipping_commission numeric(8,4) DEFAULT 0.00,
    warehous_cntct_id integer,
    warehous_addr_id integer,
    warehous_transit boolean DEFAULT false NOT NULL,
    warehous_shipform_id integer,
    warehous_shipvia_id integer,
    warehous_shipcomments text,
    warehous_costcat_id integer,
    warehous_sitetype_id integer,
    warehous_taxzone_id integer,
    warehous_sequence integer DEFAULT 0 NOT NULL,
    CONSTRAINT whsinfo_check CHECK (((warehous_transit AND (warehous_costcat_id IS NOT NULL)) OR (NOT warehous_transit))),
    CONSTRAINT whsinfo_warehous_code_check CHECK ((warehous_code <> ''::text))
);


ALTER TABLE public.whsinfo OWNER TO admin;


--
-- TOC entry 907 (class 1255 OID 146565330)
-- Dependencies: 4536 8
-- Name: basecurrid(); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION basecurrid() RETURNS integer
    LANGUAGE plpgsql IMMUTABLE
    AS $$
-- Copyright (c) 1999-2014 by OpenMFG LLC, d/b/a xTuple.
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  returnVal INTEGER;
BEGIN
  SELECT curr_id INTO returnVal
    FROM curr_symbol
   WHERE curr_base = TRUE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'No base currency found';
  END IF;
  RETURN returnVal;
END;
$$;


ALTER FUNCTION public.basecurrid() OWNER TO admin;


--
-- TOC entry 910 (class 1255 OID 146565333)
-- Dependencies: 4536 8
-- Name: geteffectivextuser(); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION geteffectivextuser() RETURNS text
    LANGUAGE plpgsql STABLE
    AS $$
-- Copyright (c) 1999-2014 by OpenMFG LLC, d/b/a xTuple.
-- See www.xtuple.com/CPAL for the full text of the software license.
BEGIN
/*
  The default return value of this function is simply
  the user currently connected.

  Overload this function from another schema
  to implement specific user handling from an external
  application that uses connection pooling.
  Use setEffectiveXtUser(text) to create a temporary table that
  inserts user data that can in turn be used as a lookup
  reference for an over loaded version of this function like so:

  SELECT effective_value
  FROM effective_user
  WHERE effective_key = 'username'
*/

  RETURN CURRENT_USER;

END;
$$;


ALTER FUNCTION public.geteffectivextuser() OWNER TO admin;


--
-- TOC entry 195 (class 1259 OID 146565335)
-- Dependencies: 5887 5888 5889 5890 5891 5892 5893 5894 5895 5896 5897 5898 5899 8
-- Name: cohead; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE cohead (
    cohead_id integer DEFAULT nextval(('cohead_cohead_id_seq'::text)::regclass) NOT NULL,
    cohead_number text NOT NULL,
    cohead_cust_id integer NOT NULL,
    cohead_custponumber text,
    cohead_orderdate date,
    cohead_warehous_id integer,
    cohead_shipto_id integer,
    cohead_shiptoname text,
    cohead_shiptoaddress1 text,
    cohead_shiptoaddress2 text,
    cohead_shiptoaddress3 text,
    cohead_shiptoaddress4 text,
    cohead_shiptoaddress5 text,
    cohead_salesrep_id integer NOT NULL,
    cohead_terms_id integer NOT NULL,
    cohead_fob text,
    cohead_shipvia text,
    cohead_shiptocity text,
    cohead_shiptostate text,
    cohead_shiptozipcode text,
    cohead_freight numeric(16,4) NOT NULL,
    cohead_misc numeric(16,4) DEFAULT 0 NOT NULL,
    cohead_imported boolean DEFAULT false,
    cohead_ordercomments text,
    cohead_shipcomments text,
    cohead_shiptophone text,
    cohead_shipchrg_id integer,
    cohead_shipform_id integer,
    cohead_billtoname text,
    cohead_billtoaddress1 text,
    cohead_billtoaddress2 text,
    cohead_billtoaddress3 text,
    cohead_billtocity text,
    cohead_billtostate text,
    cohead_billtozipcode text,
    cohead_misc_accnt_id integer,
    cohead_misc_descrip text,
    cohead_commission numeric(16,4),
    cohead_miscdate date,
    cohead_holdtype character(1),
    cohead_packdate date,
    cohead_prj_id integer,
    cohead_wasquote boolean DEFAULT false NOT NULL,
    cohead_lastupdated timestamp without time zone DEFAULT ('now'::text)::timestamp(6) with time zone NOT NULL,
    cohead_shipcomplete boolean DEFAULT false NOT NULL,
    cohead_created timestamp without time zone DEFAULT ('now'::text)::timestamp(6) with time zone,
    cohead_creator text DEFAULT geteffectivextuser(),
    cohead_quote_number text,
    cohead_billtocountry text,
    cohead_shiptocountry text,
    cohead_curr_id integer DEFAULT basecurrid(),
    cohead_calcfreight boolean DEFAULT false NOT NULL,
    cohead_shipto_cntct_id integer,
    cohead_shipto_cntct_honorific text,
    cohead_shipto_cntct_first_name text,
    cohead_shipto_cntct_middle text,
    cohead_shipto_cntct_last_name text,
    cohead_shipto_cntct_suffix text,
    cohead_shipto_cntct_phone text,
    cohead_shipto_cntct_title text,
    cohead_shipto_cntct_fax text,
    cohead_shipto_cntct_email text,
    cohead_billto_cntct_id integer,
    cohead_billto_cntct_honorific text,
    cohead_billto_cntct_first_name text,
    cohead_billto_cntct_middle text,
    cohead_billto_cntct_last_name text,
    cohead_billto_cntct_suffix text,
    cohead_billto_cntct_phone text,
    cohead_billto_cntct_title text,
    cohead_billto_cntct_fax text,
    cohead_billto_cntct_email text,
    cohead_taxzone_id integer,
    cohead_taxtype_id integer,
    cohead_ophead_id integer,
    cohead_status character(1) DEFAULT 'O'::bpchar NOT NULL,
    cohead_saletype_id integer,
    cohead_shipzone_id integer,
    CONSTRAINT cohead_check CHECK (((cohead_misc = (0)::numeric) OR ((cohead_misc <> (0)::numeric) AND (cohead_misc_accnt_id IS NOT NULL)))),
    CONSTRAINT cohead_cohead_number_check CHECK ((cohead_number <> ''::text))
);


ALTER TABLE public.cohead OWNER TO admin;


--
-- TOC entry 196 (class 1259 OID 146565354)
-- Dependencies: 5900 5901 5902 5903 5904 5905 5906 5907 5908 5909 5910 5911 8
-- Name: coitem; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE coitem (
    coitem_id integer DEFAULT nextval(('coitem_coitem_id_seq'::text)::regclass) NOT NULL,
    coitem_cohead_id integer,
    coitem_linenumber integer NOT NULL,
    coitem_itemsite_id integer,
    coitem_status character(1),
    coitem_scheddate date,
    coitem_promdate date,
    coitem_qtyord numeric(18,6) NOT NULL,
    coitem_unitcost numeric(16,6) NOT NULL,
    coitem_price numeric(16,4) NOT NULL,
    coitem_custprice numeric(16,4) NOT NULL,
    coitem_qtyshipped numeric(18,6) NOT NULL,
    coitem_order_id integer,
    coitem_memo text,
    coitem_imported boolean DEFAULT false,
    coitem_qtyreturned numeric(18,6),
    coitem_closedate timestamp with time zone,
    coitem_custpn text,
    coitem_order_type character(1),
    coitem_close_username text,
    coitem_lastupdated timestamp without time zone DEFAULT ('now'::text)::timestamp(6) with time zone NOT NULL,
    coitem_substitute_item_id integer,
    coitem_created timestamp without time zone DEFAULT ('now'::text)::timestamp(6) with time zone,
    coitem_creator text DEFAULT geteffectivextuser(),
    coitem_prcost numeric(16,6),
    coitem_qty_uom_id integer NOT NULL,
    coitem_qty_invuomratio numeric(20,10) NOT NULL,
    coitem_price_uom_id integer NOT NULL,
    coitem_price_invuomratio numeric(20,10) NOT NULL,
    coitem_warranty boolean DEFAULT false NOT NULL,
    coitem_cos_accnt_id integer,
    coitem_qtyreserved numeric(18,6) DEFAULT 0.0 NOT NULL,
    coitem_subnumber integer DEFAULT 0 NOT NULL,
    coitem_firm boolean DEFAULT false NOT NULL,
    coitem_taxtype_id integer,
    coitem_rev_accnt_id integer,
    coitem_pricemode character(1) DEFAULT 'D'::bpchar NOT NULL,
    CONSTRAINT coitem_coitem_status_check CHECK ((((coitem_status = 'O'::bpchar) OR (coitem_status = 'C'::bpchar)) OR (coitem_status = 'X'::bpchar))),
    CONSTRAINT valid_coitem_pricemode CHECK ((coitem_pricemode = ANY (ARRAY['D'::bpchar, 'M'::bpchar])))
);


ALTER TABLE public.coitem OWNER TO admin;


--
-- TOC entry 197 (class 1259 OID 146565372)
-- Dependencies: 5912 5913 5914 5915 5916 5917 5918 5919 8
-- Name: pohead; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE pohead (
    pohead_id integer DEFAULT nextval(('pohead_pohead_id_seq'::text)::regclass) NOT NULL,
    pohead_status character(1),
    pohead_number text NOT NULL,
    pohead_orderdate date,
    pohead_vend_id integer,
    pohead_fob text,
    pohead_shipvia text,
    pohead_comments text,
    pohead_freight numeric(16,2) DEFAULT 0,
    pohead_printed boolean DEFAULT false,
    pohead_terms_id integer,
    pohead_warehous_id integer,
    pohead_vendaddr_id integer,
    pohead_agent_username text,
    pohead_curr_id integer DEFAULT basecurrid(),
    pohead_saved boolean DEFAULT true NOT NULL,
    pohead_taxzone_id integer,
    pohead_taxtype_id integer,
    pohead_dropship boolean DEFAULT false,
    pohead_vend_cntct_id integer,
    pohead_vend_cntct_honorific text,
    pohead_vend_cntct_first_name text,
    pohead_vend_cntct_middle text,
    pohead_vend_cntct_last_name text,
    pohead_vend_cntct_suffix text,
    pohead_vend_cntct_phone text,
    pohead_vend_cntct_title text,
    pohead_vend_cntct_fax text,
    pohead_vend_cntct_email text,
    pohead_vendaddress1 text,
    pohead_vendaddress2 text,
    pohead_vendaddress3 text,
    pohead_vendcity text,
    pohead_vendstate text,
    pohead_vendzipcode text,
    pohead_vendcountry text,
    pohead_shipto_cntct_id integer,
    pohead_shipto_cntct_honorific text,
    pohead_shipto_cntct_first_name text,
    pohead_shipto_cntct_middle text,
    pohead_shipto_cntct_last_name text,
    pohead_shipto_cntct_suffix text,
    pohead_shipto_cntct_phone text,
    pohead_shipto_cntct_title text,
    pohead_shipto_cntct_fax text,
    pohead_shipto_cntct_email text,
    pohead_shiptoaddress_id integer,
    pohead_shiptoaddress1 text,
    pohead_shiptoaddress2 text,
    pohead_shiptoaddress3 text,
    pohead_shiptocity text,
    pohead_shiptostate text,
    pohead_shiptozipcode text,
    pohead_shiptocountry text,
    pohead_cohead_id integer,
    pohead_released date,
    pohead_shiptoname text,
    CONSTRAINT pohead_pohead_number_check CHECK ((pohead_number <> ''::text)),
    CONSTRAINT pohead_pohead_status_check CHECK ((((pohead_status = 'U'::bpchar) OR (pohead_status = 'O'::bpchar)) OR (pohead_status = 'C'::bpchar)))
);


ALTER TABLE public.pohead OWNER TO admin;


--
-- TOC entry 198 (class 1259 OID 146565386)
-- Dependencies: 5920 5921 5922 5923 5924 5925 5926 5927 5928 8
-- Name: poitem; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE poitem (
    poitem_id integer DEFAULT nextval(('poitem_poitem_id_seq'::text)::regclass) NOT NULL,
    poitem_status character(1),
    poitem_pohead_id integer,
    poitem_linenumber integer,
    poitem_duedate date,
    poitem_itemsite_id integer,
    poitem_vend_item_descrip text,
    poitem_vend_uom text,
    poitem_invvenduomratio numeric(20,10),
    poitem_qty_ordered numeric(18,6) NOT NULL,
    poitem_qty_received numeric(18,6) DEFAULT 0.0 NOT NULL,
    poitem_qty_returned numeric(18,6) DEFAULT 0.0 NOT NULL,
    poitem_qty_vouchered numeric(18,6) DEFAULT 0.0 NOT NULL,
    poitem_unitprice numeric(16,6),
    poitem_vend_item_number text,
    poitem_comments text,
    poitem_qty_toreceive numeric(18,6),
    poitem_expcat_id integer,
    poitem_itemsrc_id integer,
    poitem_freight numeric(16,4) DEFAULT 0.0 NOT NULL,
    poitem_freight_received numeric(16,4) DEFAULT 0.0 NOT NULL,
    poitem_freight_vouchered numeric(16,4) DEFAULT 0.0 NOT NULL,
    poitem_prj_id integer,
    poitem_stdcost numeric(16,6),
    poitem_bom_rev_id integer,
    poitem_boo_rev_id integer,
    poitem_manuf_name text,
    poitem_manuf_item_number text,
    poitem_manuf_item_descrip text,
    poitem_taxtype_id integer,
    poitem_tax_recoverable boolean DEFAULT true NOT NULL,
    poitem_rlsd_duedate date,
    poitem_order_id integer,
    poitem_order_type character(1),
    CONSTRAINT poitem_poitem_status_check CHECK ((((poitem_status = 'U'::bpchar) OR (poitem_status = 'O'::bpchar)) OR (poitem_status = 'C'::bpchar)))
);


ALTER TABLE public.poitem OWNER TO admin;


--
-- TOC entry 199 (class 1259 OID 146565401)
-- Dependencies: 5930 5931 8
-- Name: taxtype; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE taxtype (
    taxtype_id integer NOT NULL,
    taxtype_name text NOT NULL,
    taxtype_descrip text,
    taxtype_sys boolean DEFAULT false NOT NULL,
    CONSTRAINT taxtype_taxtype_name_check CHECK ((taxtype_name <> ''::text))
);


ALTER TABLE public.taxtype OWNER TO admin;

--
-- TOC entry 8937 (class 0 OID 0)
-- Dependencies: 199
-- Name: TABLE taxtype; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE taxtype IS 'The list of Tax Types';


--
-- TOC entry 200 (class 1259 OID 146565409)
-- Dependencies: 5933 5934 8
-- Name: uom; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE uom (
    uom_id integer NOT NULL,
    uom_name text NOT NULL,
    uom_descrip text,
    uom_item_weight boolean DEFAULT false NOT NULL,
    CONSTRAINT uom_uom_name_check CHECK ((uom_name <> ''::text))
);


ALTER TABLE public.uom OWNER TO admin;

--
-- TOC entry 8939 (class 0 OID 0)
-- Dependencies: 200
-- Name: TABLE uom; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE uom IS 'Unit of Measure information';


--
-- TOC entry 202 (class 1259 OID 146565656)
-- Dependencies: 5936 8
-- Name: invbal; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE invbal (
    invbal_id integer NOT NULL,
    invbal_period_id integer,
    invbal_itemsite_id integer,
    invbal_qoh_beginning numeric(18,6) NOT NULL,
    invbal_qoh_ending numeric(18,6) NOT NULL,
    invbal_qty_in numeric(18,6) NOT NULL,
    invbal_qty_out numeric(18,6) NOT NULL,
    invbal_value_beginning numeric(12,2) NOT NULL,
    invbal_value_ending numeric(12,2) NOT NULL,
    invbal_value_in numeric(12,2) NOT NULL,
    invbal_value_out numeric(12,2) NOT NULL,
    invbal_nn_beginning numeric(18,6) NOT NULL,
    invbal_nn_ending numeric(18,6) NOT NULL,
    invbal_nn_in numeric(18,6) NOT NULL,
    invbal_nn_out numeric(18,6) NOT NULL,
    invbal_nnval_beginning numeric(12,2) NOT NULL,
    invbal_nnval_ending numeric(12,2) NOT NULL,
    invbal_nnval_in numeric(12,2) NOT NULL,
    invbal_nnval_out numeric(12,2) NOT NULL,
    invbal_dirty boolean DEFAULT true NOT NULL
);


ALTER TABLE public.invbal OWNER TO admin;

--
-- TOC entry 203 (class 1259 OID 146565672)
-- Dependencies: 5937 5938 5939 5940 5941 5942 5943 8
-- Name: bomitem; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE bomitem (
    bomitem_id integer DEFAULT nextval(('bomitem_bomitem_id_seq'::text)::regclass) NOT NULL,
    bomitem_parent_item_id integer NOT NULL,
    bomitem_seqnumber integer,
    bomitem_item_id integer NOT NULL,
    bomitem_qtyper numeric(20,8) NOT NULL,
    bomitem_scrap numeric(8,4) NOT NULL,
    bomitem_status character(1),
    bomitem_effective date NOT NULL,
    bomitem_expires date NOT NULL,
    bomitem_createwo boolean NOT NULL,
    bomitem_issuemethod character(1) NOT NULL,
    bomitem_schedatwooper boolean NOT NULL,
    bomitem_ecn text,
    bomitem_moddate date,
    bomitem_subtype character(1) NOT NULL,
    bomitem_uom_id integer NOT NULL,
    bomitem_rev_id integer DEFAULT (-1),
    bomitem_booitem_seq_id integer DEFAULT (-1),
    bomitem_char_id integer,
    bomitem_value text,
    bomitem_notes text,
    bomitem_ref text,
    bomitem_qtyfxd numeric(20,8) DEFAULT 0 NOT NULL,
    bomitem_issuewo boolean DEFAULT false NOT NULL,
    CONSTRAINT bomitem_bomitem_issuemethod_check CHECK ((((bomitem_issuemethod = 'M'::bpchar) OR (bomitem_issuemethod = 'S'::bpchar)) OR (bomitem_issuemethod = 'L'::bpchar))),
    CONSTRAINT bomitem_bomitem_subtype_check CHECK ((((bomitem_subtype = 'N'::bpchar) OR (bomitem_subtype = 'I'::bpchar)) OR (bomitem_subtype = 'B'::bpchar)))
);


ALTER TABLE public.bomitem OWNER TO admin;


--
-- TOC entry 204 (class 1259 OID 146565765)
-- Dependencies: 5945 8
-- Name: cntct; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE cntct (
    cntct_id integer NOT NULL,
    cntct_crmacct_id integer,
    cntct_addr_id integer,
    cntct_first_name text,
    cntct_last_name text,
    cntct_honorific text,
    cntct_initials text,
    cntct_active boolean DEFAULT true,
    cntct_phone text,
    cntct_phone2 text,
    cntct_fax text,
    cntct_email text,
    cntct_webaddr text,
    cntct_notes text,
    cntct_title text,
    cntct_number text NOT NULL,
    cntct_middle text,
    cntct_suffix text,
    cntct_owner_username text,
    cntct_name text
);


ALTER TABLE public.cntct OWNER TO admin;


--
-- TOC entry 1344 (class 1255 OID 146565899)
-- Dependencies: 4536 8
-- Name: createpriv(text, text, text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION createpriv(text, text, text) RETURNS integer
    LANGUAGE plpgsql
    AS $_$
-- Copyright (c) 1999-2014 by OpenMFG LLC, d/b/a xTuple.
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  pModule ALIAS FOR $1;
  pName   ALIAS FOR $2;
  pDesc   ALIAS FOR $3;
  _id     INTEGER;
BEGIN

  SELECT priv_id
    INTO _id
    FROM priv
   WHERE(priv_name=pName);

  IF (FOUND) THEN
    UPDATE priv
       SET priv_module=pModule,
           priv_descrip=pDesc
     WHERE(priv_id=_id);
  ELSE
    SELECT nextval('priv_priv_id_seq') INTO _id;
    INSERT INTO priv
          (priv_id, priv_module, priv_name, priv_descrip)
    VALUES(_id, pModule, pName, pDesc);
  END IF;

  RETURN _id;
END;
$_$;


ALTER FUNCTION public.createpriv(text, text, text) OWNER TO admin;


--
-- TOC entry 205 (class 1259 OID 146565930)
-- Dependencies: 5947 5948 5949 5950 5951 8
-- Name: crmacct; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE crmacct (
    crmacct_id integer NOT NULL,
    crmacct_number text NOT NULL,
    crmacct_name text,
    crmacct_active boolean DEFAULT true,
    crmacct_type character(1),
    crmacct_cust_id integer,
    crmacct_competitor_id integer,
    crmacct_partner_id integer,
    crmacct_prospect_id integer,
    crmacct_vend_id integer,
    crmacct_cntct_id_1 integer,
    crmacct_cntct_id_2 integer,
    crmacct_parent_id integer,
    crmacct_notes text,
    crmacct_taxauth_id integer,
    crmacct_owner_username text,
    crmacct_emp_id integer,
    crmacct_salesrep_id integer,
    crmacct_usr_username text,
    CONSTRAINT crmacct_crmacct_number_check CHECK ((crmacct_number <> ''::text)),
    CONSTRAINT crmacct_crmacct_type_check CHECK ((crmacct_type = ANY (ARRAY['I'::bpchar, 'O'::bpchar]))),
    CONSTRAINT crmacct_crmacct_usr_username_check CHECK ((btrim(crmacct_usr_username) <> ''::text)),
    CONSTRAINT crmacct_owner_username_check CHECK ((btrim(crmacct_owner_username) <> ''::text))
);


ALTER TABLE public.crmacct OWNER TO admin;


--
-- TOC entry 1519 (class 1255 OID 146566085)
-- Dependencies: 8
-- Name: endoftime(); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION endoftime() RETURNS date
    LANGUAGE sql IMMUTABLE
    AS $$
-- Copyright (c) 1999-2014 by OpenMFG LLC, d/b/a xTuple.
-- See www.xtuple.com/CPAL for the full text of the software license.
SELECT DATE('2100-01-01') as result;
$$;


ALTER FUNCTION public.endoftime() OWNER TO admin;


--
-- TOC entry 1545 (class 1255 OID 146566118)
-- Dependencies: 4536 8
-- Name: fetchmetricbool(text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION fetchmetricbool(text) RETURNS boolean
    LANGUAGE plpgsql STABLE
    AS $_$
-- Copyright (c) 1999-2014 by OpenMFG LLC, d/b/a xTuple.
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  _pMetricName ALIAS FOR $1;
  _returnVal BOOLEAN;
BEGIN
  SELECT CASE
    WHEN MIN(metric_value) = 't' THEN
     true
    ELSE
     false
    END INTO _returnVal
    FROM metric
   WHERE metric_name = _pMetricName;
  RETURN _returnVal;
END;
$_$;


ALTER FUNCTION public.fetchmetricbool(text) OWNER TO admin;

--
-- TOC entry 1549 (class 1255 OID 146566122)
-- Dependencies: 4536 8
-- Name: fetchnextnumber(text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION fetchnextnumber(text) RETURNS text
    LANGUAGE plpgsql
    AS $_$
-- Copyright (c) 1999-2014 by OpenMFG LLC, d/b/a xTuple.
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  psequence	ALIAS FOR $1;
  _number	TEXT;
  _numcol	TEXT;
  _select	TEXT;
  _table	TEXT;
  _test		TEXT;
  _nextnum	INTEGER;
  _seqiss       seqiss;
  __seqiss      seqiss[];
  _not_issued       BOOLEAN;

BEGIN
  SELECT CAST(orderseq_number AS text), orderseq_number, orderseq_table, orderseq_numcol, COALESCE(orderseq_seqiss, ARRAY[]::seqiss[])
    INTO _number, _nextnum, _table, _numcol, __seqiss
  FROM orderseq
  WHERE (orderseq_name=psequence) FOR UPDATE;

  IF (NOT FOUND) THEN
    RAISE EXCEPTION 'Invalid orderseq_name %', psequence;
  END IF;

  LOOP

    _seqiss := (_nextnum, now());

    SELECT count(*) = 0 INTO _not_issued
    FROM (SELECT UNNEST(__seqiss) AS issued) data
    WHERE (issued).seqiss_number = _nextnum;

    _nextnum := _nextnum + 1;

    -- Test if the number has been issued, but not committed
    IF (_not_issued) THEN

      -- Test if the number has been committed
      _select := 'SELECT ' || quote_ident(_numcol) ||
	         ' FROM '  || quote_ident(_table) ||
	         ' WHERE (' || quote_ident(_numcol) || '=' ||
                 quote_literal(_number) || ');';

      EXECUTE _select INTO _test;

      IF (_test IS NULL OR NOT FOUND) THEN
        EXIT;
      END IF;

    END IF;

    -- Number in use, try again
    _number = _nextnum::text;

  END LOOP;

  UPDATE orderseq SET
    orderseq_number = _nextnum
  WHERE (orderseq_name=psequence);

  IF (fetchMetricBool('EnableGaplessNumbering')) THEN
    UPDATE orderseq SET
      orderseq_seqiss = orderseq_seqiss || _seqiss
    WHERE (orderseq_name=psequence);
  END IF;

  RETURN _number;

END;
$_$;


ALTER FUNCTION public.fetchnextnumber(text) OWNER TO admin;


--
-- TOC entry 1583 (class 1255 OID 146566159)
-- Dependencies: 4536 8
-- Name: fixacl(); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION fixacl() RETURNS integer
    LANGUAGE plpgsql
    AS $$
-- Copyright (c) 1999-2014 by OpenMFG LLC, d/b/a xTuple.
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  _r        RECORD;
  _count    INTEGER := 0;
  _oldgrp   BOOLEAN := false;
  _objtype  TEXT;
  _table    TEXT;
  _schema   TEXT;

BEGIN
  IF EXISTS(SELECT 1 FROM pg_group WHERE groname = 'openmfg') THEN
    _oldgrp := true;
  END IF;

  FOR _r IN SELECT relname, nspname, relkind,
                   CASE relkind WHEN 'r' THEN 1
                                WHEN 'v' THEN 2
                                WHEN 'S' THEN 3
                                ELSE 4
                   END AS seq
            FROM pg_catalog.pg_class c, pg_namespace n
            WHERE ((n.oid=c.relnamespace)
              AND  (nspname in ('public', 'api') OR
                    nspname in (SELECT pkghead_name FROM pkghead))
              AND  (relkind in ('S', 'r', 'v')))
            ORDER BY seq
  LOOP
    _schema := quote_ident(_r.nspname);
    _table  := quote_ident(_r.relname);

    RAISE DEBUG '%.%', _schema, _table;

    IF (_oldgrp) THEN
      EXECUTE 'REVOKE ALL ON ' || _schema || '.' || _table || ' FROM openmfg;';
    END IF;
    EXECUTE 'REVOKE ALL ON ' || _schema || '.' || _table || ' FROM PUBLIC;';
    EXECUTE 'GRANT ALL ON '  || _schema || '.' || _table || ' TO GROUP xtrole;';
    _count := _count + 1;

    _objtype := CASE _r.relkind WHEN 'S' THEN 'SEQUENCE'
                                WHEN 'r' THEN 'TABLE'
                                WHEN 'v' THEN 'VIEW'
                                ELSE NULL
                END;
    IF (_objtype IS NOT NULL) THEN
      BEGIN
        EXECUTE 'ALTER ' || _objtype || ' ' ||
                _schema || '.' || _table || ' OWNER TO admin;';
      EXCEPTION WHEN OTHERS THEN
        RAISE WARNING 'Could not change ownership of %.% to admin',
                      _schema, _table;
      END;
    END IF;

  END LOOP;

  RETURN _count;
END;
$$;


ALTER FUNCTION public.fixacl() OWNER TO admin;

--
-- TOC entry 1786 (class 1255 OID 146566362)
-- Dependencies: 4536 8
-- Name: grantgroup(text, integer); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION grantgroup(text, integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$
-- Copyright (c) 1999-2014 by OpenMFG LLC, d/b/a xTuple.
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  pUsername ALIAS FOR $1;
  pGrpid ALIAS FOR $2;
  _test INTEGER;

BEGIN

  SELECT usrgrp_id INTO _test
  FROM usrgrp
  WHERE ( (usrgrp_username=pUsername)
   AND (usrgrp_grp_id=pGrpid) );

  IF (FOUND) THEN
    RETURN FALSE;
  END IF;

  INSERT INTO usrgrp
  ( usrgrp_username, usrgrp_grp_id )
  VALUES
  ( pUsername, pGrpid );

  RETURN TRUE;

END;
$_$;


ALTER FUNCTION public.grantgroup(text, integer) OWNER TO admin;

--
-- TOC entry 1789 (class 1255 OID 146566365)
-- Dependencies: 4536 8
-- Name: grantprivgroup(integer, integer); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION grantprivgroup(integer, integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$
-- Copyright (c) 1999-2014 by OpenMFG LLC, d/b/a xTuple.
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  pGrpid ALIAS FOR $1;
  pPrivid ALIAS FOR $2;
  _test INTEGER;

BEGIN

  SELECT grppriv_id INTO _test
  FROM grppriv
  WHERE ( (grppriv_grp_id=pGrpid)
   AND (grppriv_priv_id=pPrivid) );

  IF (FOUND) THEN
    RETURN FALSE;
  END IF;

  INSERT INTO grppriv
  ( grppriv_grp_id, grppriv_priv_id )
  VALUES
  ( pGrpid, pPrivid );

  RETURN TRUE;

END;
$_$;


ALTER FUNCTION public.grantprivgroup(integer, integer) OWNER TO admin;


--
-- TOC entry 206 (class 1259 OID 146566375)
-- Dependencies: 5952 5953 5954 8
-- Name: incdt; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE incdt (
    incdt_id integer NOT NULL,
    incdt_number integer NOT NULL,
    incdt_crmacct_id integer,
    incdt_cntct_id integer,
    incdt_summary text,
    incdt_descrip text,
    incdt_item_id integer,
    incdt_timestamp timestamp without time zone DEFAULT now() NOT NULL,
    incdt_status character(1) DEFAULT 'N'::bpchar NOT NULL,
    incdt_assigned_username text,
    incdt_incdtcat_id integer,
    incdt_incdtseverity_id integer,
    incdt_incdtpriority_id integer,
    incdt_incdtresolution_id integer,
    incdt_lotserial text,
    incdt_ls_id integer,
    incdt_aropen_id integer,
    incdt_owner_username text,
    incdt_recurring_incdt_id integer,
    incdt_updated timestamp without time zone DEFAULT now() NOT NULL,
    incdt_prj_id integer,
    incdt_public boolean
);


ALTER TABLE public.incdt OWNER TO admin;


--
-- TOC entry 207 (class 1259 OID 146566396)
-- Dependencies: 5956 5957 5958 5959 5960 5961 5962 5963 5964 8
-- Name: apopen; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE apopen (
    apopen_id integer DEFAULT nextval(('"apopen_apopen_id_seq"'::text)::regclass) NOT NULL,
    apopen_docdate date,
    apopen_duedate date,
    apopen_terms_id integer,
    apopen_vend_id integer,
    apopen_doctype character(1),
    apopen_docnumber text,
    apopen_amount numeric(20,2),
    apopen_notes text,
    apopen_posted boolean,
    apopen_reference text,
    apopen_invcnumber text,
    apopen_ponumber text,
    apopen_journalnumber integer,
    apopen_paid numeric(20,2) DEFAULT 0,
    apopen_open boolean,
    apopen_username text,
    apopen_discount boolean DEFAULT false NOT NULL,
    apopen_accnt_id integer DEFAULT (-1),
    apopen_curr_id integer DEFAULT basecurrid(),
    apopen_closedate date,
    apopen_distdate date,
    apopen_void boolean DEFAULT false NOT NULL,
    apopen_curr_rate numeric NOT NULL,
    apopen_discountable_amount numeric(20,2) DEFAULT 0,
    apopen_status text,
    CONSTRAINT apopen_apopen_status_check CHECK ((((apopen_status = 'O'::text) OR (apopen_status = 'H'::text)) OR (apopen_status = 'C'::text))),
    CONSTRAINT apopen_apopen_status_notnull CHECK ((apopen_status IS NOT NULL))
);


ALTER TABLE public.apopen OWNER TO admin;


--
-- TOC entry 208 (class 1259 OID 146566411)
-- Dependencies: 5966 8
-- Name: curr_symbol; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE curr_symbol (
    curr_id integer NOT NULL,
    curr_base boolean DEFAULT false NOT NULL,
    curr_name character varying(50) NOT NULL,
    curr_symbol character varying(9) NOT NULL,
    curr_abbr character varying(3) NOT NULL
);


ALTER TABLE public.curr_symbol OWNER TO admin;

--
-- TOC entry 8983 (class 0 OID 0)
-- Dependencies: 208
-- Name: TABLE curr_symbol; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE curr_symbol IS 'Currency Names, Symbols, and Abbreviations';


--
-- TOC entry 209 (class 1259 OID 146566415)
-- Dependencies: 5967 5968 5969 8
-- Name: terms; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE terms (
    terms_id integer DEFAULT nextval(('terms_terms_id_seq'::text)::regclass) NOT NULL,
    terms_code text NOT NULL,
    terms_descrip text,
    terms_type character(1),
    terms_duedays integer,
    terms_discdays integer,
    terms_discprcnt numeric(10,6),
    terms_cutoffday integer,
    terms_ap boolean,
    terms_ar boolean,
    terms_fincharg boolean DEFAULT true NOT NULL,
    CONSTRAINT terms_terms_code_check CHECK ((terms_code <> ''::text))
);


ALTER TABLE public.terms OWNER TO admin;

--
-- TOC entry 8985 (class 0 OID 0)
-- Dependencies: 209
-- Name: TABLE terms; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE terms IS 'Billing Terms information';


--
-- TOC entry 210 (class 1259 OID 146566424)
-- Dependencies: 5970 5971 5972 5973 5974 5975 5976 5977 5978 5979 5980 5981 5982 5983 8
-- Name: vendinfo; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE vendinfo (
    vend_id integer DEFAULT nextval(('vend_vend_id_seq'::text)::regclass) NOT NULL,
    vend_name text,
    vend_lastpurchdate date,
    vend_active boolean,
    vend_po boolean,
    vend_comments text,
    vend_pocomments text,
    vend_number text NOT NULL,
    vend_1099 boolean,
    vend_exported boolean,
    vend_fobsource character(1),
    vend_fob text,
    vend_terms_id integer,
    vend_shipvia text,
    vend_vendtype_id integer,
    vend_qualified boolean,
    vend_ediemail text,
    vend_ediemailbody text,
    vend_edisubject text,
    vend_edifilename text,
    vend_accntnum text,
    vend_emailpodelivery boolean,
    vend_restrictpurch boolean,
    vend_edicc text,
    vend_curr_id integer DEFAULT basecurrid(),
    vend_cntct1_id integer,
    vend_cntct2_id integer,
    vend_addr_id integer,
    vend_match boolean DEFAULT false NOT NULL,
    vend_ach_enabled boolean DEFAULT false NOT NULL,
    vend_ach_accnttype text,
    vend_ach_use_vendinfo boolean DEFAULT true NOT NULL,
    vend_ach_indiv_number text DEFAULT ''::text NOT NULL,
    vend_ach_indiv_name text DEFAULT ''::text NOT NULL,
    vend_ediemailhtml boolean DEFAULT false NOT NULL,
    vend_ach_routingnumber bytea DEFAULT '\x00'::bytea NOT NULL,
    vend_ach_accntnumber bytea DEFAULT '\x00'::bytea NOT NULL,
    vend_taxzone_id integer,
    vend_accnt_id integer,
    vend_expcat_id integer DEFAULT (-1),
    vend_tax_id integer DEFAULT (-1),
    CONSTRAINT vendinfo_vend_ach_accnttype_check CHECK (((vend_ach_accnttype = 'K'::text) OR (vend_ach_accnttype = 'C'::text))),
    CONSTRAINT vendinfo_vend_number_check CHECK ((vend_number <> ''::text))
);


ALTER TABLE public.vendinfo OWNER TO admin;


--
-- TOC entry 212 (class 1259 OID 146566450)
-- Dependencies: 5984 5985 5986 5987 5988 5989 5990 5991 5992 8
-- Name: aropen; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE aropen (
    aropen_id integer DEFAULT nextval(('"aropen_aropen_id_seq"'::text)::regclass) NOT NULL,
    aropen_docdate date NOT NULL,
    aropen_duedate date NOT NULL,
    aropen_terms_id integer,
    aropen_cust_id integer,
    aropen_doctype character(1),
    aropen_docnumber text,
    aropen_applyto text,
    aropen_ponumber text,
    aropen_amount numeric(20,2) NOT NULL,
    aropen_notes text,
    aropen_posted boolean DEFAULT false NOT NULL,
    aropen_salesrep_id integer,
    aropen_commission_due numeric(20,2),
    aropen_commission_paid boolean DEFAULT false,
    aropen_ordernumber text,
    aropen_cobmisc_id integer DEFAULT (-1),
    aropen_journalnumber integer,
    aropen_paid numeric(20,2) DEFAULT 0,
    aropen_open boolean,
    aropen_username text,
    aropen_rsncode_id integer,
    aropen_salescat_id integer DEFAULT (-1),
    aropen_accnt_id integer DEFAULT (-1),
    aropen_curr_id integer DEFAULT basecurrid(),
    aropen_closedate date,
    aropen_distdate date,
    aropen_curr_rate numeric NOT NULL,
    aropen_discount boolean DEFAULT false NOT NULL,
    aropen_fincharg_date date,
    aropen_fincharg_amount numeric(20,2)
);


ALTER TABLE public.aropen OWNER TO admin;


-- TOC entry 213 (class 1259 OID 146566465)
-- Dependencies: 5993 5994 5995 5996 5997 5998 5999 6000 6001 6002 6003 6004 6005 8
-- Name: custinfo; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE custinfo (
    cust_id integer DEFAULT nextval(('cust_cust_id_seq'::text)::regclass) NOT NULL,
    cust_active boolean NOT NULL,
    cust_custtype_id integer,
    cust_salesrep_id integer,
    cust_commprcnt numeric(10,6),
    cust_name text,
    cust_creditlmt integer,
    cust_creditrating text,
    cust_financecharge boolean,
    cust_backorder boolean NOT NULL,
    cust_partialship boolean NOT NULL,
    cust_terms_id integer,
    cust_discntprcnt numeric(10,6) NOT NULL,
    cust_balmethod character(1) NOT NULL,
    cust_ffshipto boolean NOT NULL,
    cust_shipform_id integer,
    cust_shipvia text,
    cust_blanketpos boolean NOT NULL,
    cust_shipchrg_id integer NOT NULL,
    cust_creditstatus character(1) NOT NULL,
    cust_comments text,
    cust_ffbillto boolean NOT NULL,
    cust_usespos boolean NOT NULL,
    cust_number text NOT NULL,
    cust_dateadded date DEFAULT ('now'::text)::date,
    cust_exported boolean DEFAULT false,
    cust_emaildelivery boolean DEFAULT false,
    cust_ediemail text,
    cust_edisubject text,
    cust_edifilename text,
    cust_ediemailbody text,
    cust_autoupdatestatus boolean NOT NULL,
    cust_autoholdorders boolean NOT NULL,
    cust_edicc text,
    cust_ediprofile_id integer,
    cust_preferred_warehous_id integer DEFAULT (-1) NOT NULL,
    cust_curr_id integer DEFAULT basecurrid(),
    cust_creditlmt_curr_id integer DEFAULT basecurrid(),
    cust_cntct_id integer,
    cust_corrcntct_id integer,
    cust_soemaildelivery boolean DEFAULT false,
    cust_soediemail text,
    cust_soedisubject text,
    cust_soedifilename text,
    cust_soediemailbody text,
    cust_soedicc text,
    cust_soediprofile_id integer,
    cust_gracedays integer,
    cust_ediemailhtml boolean DEFAULT false NOT NULL,
    cust_soediemailhtml boolean DEFAULT false NOT NULL,
    cust_taxzone_id integer,
    cust_statementcycle text,
    CONSTRAINT custinfo_balmethod_check CHECK (((cust_balmethod = 'B'::bpchar) OR (cust_balmethod = 'O'::bpchar))),
    CONSTRAINT custinfo_creditstatus_check CHECK ((((cust_creditstatus = 'G'::bpchar) OR (cust_creditstatus = 'W'::bpchar)) OR (cust_creditstatus = 'H'::bpchar))),
    CONSTRAINT custinfo_cust_number_check CHECK ((cust_number <> ''::text))
);


ALTER TABLE public.custinfo OWNER TO admin;


--
-- TOC entry 214 (class 1259 OID 146566484)
-- Dependencies: 6007 8
-- Name: rsncode; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE rsncode (
    rsncode_id integer NOT NULL,
    rsncode_code text NOT NULL,
    rsncode_descrip text,
    rsncode_doctype text,
    CONSTRAINT rsncode_rsncode_code_check CHECK ((rsncode_code <> ''::text))
);


ALTER TABLE public.rsncode OWNER TO admin;

--
-- TOC entry 9010 (class 0 OID 0)
-- Dependencies: 214
-- Name: TABLE rsncode; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE rsncode IS 'Debit/Credit Memo Reason Code information';


--
-- TOC entry 215 (class 1259 OID 146566491)
-- Dependencies: 6009 8
-- Name: salescat; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE salescat (
    salescat_id integer NOT NULL,
    salescat_active boolean,
    salescat_name text NOT NULL,
    salescat_descrip text,
    salescat_sales_accnt_id integer,
    salescat_prepaid_accnt_id integer,
    salescat_ar_accnt_id integer,
    CONSTRAINT salescat_salescat_name_check CHECK ((salescat_name <> ''::text))
);


ALTER TABLE public.salescat OWNER TO admin;

--
-- TOC entry 9012 (class 0 OID 0)
-- Dependencies: 215
-- Name: TABLE salescat; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE salescat IS 'Sales Category information';


--
-- TOC entry 216 (class 1259 OID 146566498)
-- Dependencies: 6010 6011 8
-- Name: salesrep; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE salesrep (
    salesrep_id integer DEFAULT nextval(('salesrep_salesrep_id_seq'::text)::regclass) NOT NULL,
    salesrep_active boolean,
    salesrep_number text NOT NULL,
    salesrep_name text,
    salesrep_commission numeric(8,4),
    salesrep_method character(1),
    salesrep_emp_id integer,
    CONSTRAINT salesrep_salesrep_number_check CHECK ((salesrep_number <> ''::text))
);


ALTER TABLE public.salesrep OWNER TO admin;


--
-- TOC entry 218 (class 1259 OID 146566514)
-- Dependencies: 6012 6013 6014 6015 8
-- Name: cmhead; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE cmhead (
    cmhead_id integer DEFAULT nextval(('cmhead_cmhead_id_seq'::text)::regclass) NOT NULL,
    cmhead_number text NOT NULL,
    cmhead_posted boolean,
    cmhead_invcnumber text,
    cmhead_custponumber text,
    cmhead_cust_id integer,
    cmhead_docdate date,
    cmhead_shipto_id integer,
    cmhead_shipto_name text,
    cmhead_shipto_address1 text,
    cmhead_shipto_address2 text,
    cmhead_shipto_address3 text,
    cmhead_shipto_city text,
    cmhead_shipto_state text,
    cmhead_shipto_zipcode text,
    cmhead_salesrep_id integer,
    cmhead_freight numeric(16,4),
    cmhead_misc numeric(16,4),
    cmhead_comments text,
    cmhead_printed boolean,
    cmhead_billtoname text,
    cmhead_billtoaddress1 text,
    cmhead_billtoaddress2 text,
    cmhead_billtoaddress3 text,
    cmhead_billtocity text,
    cmhead_billtostate text,
    cmhead_billtozip text,
    cmhead_hold boolean,
    cmhead_commission numeric(8,4),
    cmhead_misc_accnt_id integer,
    cmhead_misc_descrip text,
    cmhead_rsncode_id integer,
    cmhead_curr_id integer DEFAULT basecurrid(),
    cmhead_freighttaxtype_id integer,
    cmhead_gldistdate date,
    cmhead_billtocountry text,
    cmhead_shipto_country text,
    cmhead_rahead_id integer,
    cmhead_taxzone_id integer,
    cmhead_prj_id integer,
    cmhead_void boolean DEFAULT false,
    cmhead_saletype_id integer,
    cmhead_shipzone_id integer,
    CONSTRAINT cmhead_cmhead_number_check CHECK ((cmhead_number <> ''::text))
);


ALTER TABLE public.cmhead OWNER TO admin;

--
-- TOC entry 9020 (class 0 OID 0)
-- Dependencies: 218
-- Name: TABLE cmhead; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE cmhead IS 'S/O Credit Memo header information';


--
-- TOC entry 9021 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN cmhead.cmhead_freighttaxtype_id; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN cmhead.cmhead_freighttaxtype_id IS 'Deprecated column - DO NOT USE';


--
-- TOC entry 9022 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN cmhead.cmhead_saletype_id; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN cmhead.cmhead_saletype_id IS 'Associated sale type for credit memo.';


--
-- TOC entry 9023 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN cmhead.cmhead_shipzone_id; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN cmhead.cmhead_shipzone_id IS 'Associated shipping zone for credit memo.';


--
-- TOC entry 219 (class 1259 OID 146566524)
-- Dependencies: 6016 6017 8
-- Name: shiptoinfo; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE shiptoinfo (
    shipto_id integer DEFAULT nextval(('shipto_shipto_id_seq'::text)::regclass) NOT NULL,
    shipto_cust_id integer NOT NULL,
    shipto_name text,
    shipto_salesrep_id integer,
    shipto_comments text,
    shipto_shipcomments text,
    shipto_shipzone_id integer,
    shipto_shipvia text,
    shipto_commission numeric(10,4) NOT NULL,
    shipto_shipform_id integer,
    shipto_shipchrg_id integer,
    shipto_active boolean NOT NULL,
    shipto_default boolean,
    shipto_num text,
    shipto_ediprofile_id integer,
    shipto_cntct_id integer,
    shipto_addr_id integer,
    shipto_taxzone_id integer,
    shipto_preferred_warehous_id integer DEFAULT (-1) NOT NULL
);


ALTER TABLE public.shiptoinfo OWNER TO admin;


--
-- TOC entry 220 (class 1259 OID 146566532)
-- Dependencies: 6019 8
-- Name: taxzone; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE taxzone (
    taxzone_id integer NOT NULL,
    taxzone_code text NOT NULL,
    taxzone_descrip text,
    CONSTRAINT taxzone_taxzone_code_check CHECK ((taxzone_code <> ''::text))
);


ALTER TABLE public.taxzone OWNER TO admin;

--
-- TOC entry 9028 (class 0 OID 0)
-- Dependencies: 220
-- Name: TABLE taxzone; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE taxzone IS 'Tax zone information';


--
-- TOC entry 9029 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN taxzone.taxzone_id; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN taxzone.taxzone_id IS 'Primary key';


--
-- TOC entry 9030 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN taxzone.taxzone_code; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN taxzone.taxzone_code IS 'Code';


--
-- TOC entry 9031 (class 0 OID 0)
-- Dependencies: 220
-- Name: COLUMN taxzone.taxzone_descrip; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN taxzone.taxzone_descrip IS 'Description';


--
-- TOC entry 222 (class 1259 OID 146566545)
-- Dependencies: 6020 6021 8
-- Name: cmitem; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE cmitem (
    cmitem_id integer DEFAULT nextval(('cmitem_cmitem_id_seq'::text)::regclass) NOT NULL,
    cmitem_cmhead_id integer NOT NULL,
    cmitem_linenumber integer NOT NULL,
    cmitem_itemsite_id integer NOT NULL,
    cmitem_qtycredit numeric(18,6) NOT NULL,
    cmitem_qtyreturned numeric(18,6) NOT NULL,
    cmitem_unitprice numeric(16,4) NOT NULL,
    cmitem_comments text,
    cmitem_rsncode_id integer,
    cmitem_taxtype_id integer,
    cmitem_qty_uom_id integer NOT NULL,
    cmitem_qty_invuomratio numeric(20,10) NOT NULL,
    cmitem_price_uom_id integer NOT NULL,
    cmitem_price_invuomratio numeric(20,10) NOT NULL,
    cmitem_raitem_id integer,
    cmitem_updateinv boolean DEFAULT true NOT NULL
);


ALTER TABLE public.cmitem OWNER TO admin;


--
-- TOC entry 224 (class 1259 OID 146566573)
-- Dependencies: 6022 6023 6024 6026 8
-- Name: invchead; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE invchead (
    invchead_id integer NOT NULL,
    invchead_cust_id integer NOT NULL,
    invchead_shipto_id integer,
    invchead_ordernumber text,
    invchead_orderdate date,
    invchead_posted boolean NOT NULL,
    invchead_printed boolean NOT NULL,
    invchead_invcnumber text NOT NULL,
    invchead_invcdate date NOT NULL,
    invchead_shipdate date,
    invchead_ponumber text,
    invchead_shipvia text,
    invchead_fob text,
    invchead_billto_name text,
    invchead_billto_address1 text,
    invchead_billto_address2 text,
    invchead_billto_address3 text,
    invchead_billto_city text,
    invchead_billto_state text,
    invchead_billto_zipcode text,
    invchead_billto_phone text,
    invchead_shipto_name text,
    invchead_shipto_address1 text,
    invchead_shipto_address2 text,
    invchead_shipto_address3 text,
    invchead_shipto_city text,
    invchead_shipto_state text,
    invchead_shipto_zipcode text,
    invchead_shipto_phone text,
    invchead_salesrep_id integer,
    invchead_commission numeric(20,10) NOT NULL,
    invchead_terms_id integer,
    invchead_freight numeric(16,2) NOT NULL,
    invchead_misc_amount numeric(16,2) NOT NULL,
    invchead_misc_descrip text,
    invchead_misc_accnt_id integer,
    invchead_payment numeric(16,2),
    invchead_paymentref text,
    invchead_notes text,
    invchead_billto_country text,
    invchead_shipto_country text,
    invchead_prj_id integer,
    invchead_curr_id integer DEFAULT basecurrid(),
    invchead_gldistdate date,
    invchead_recurring boolean DEFAULT false NOT NULL,
    invchead_recurring_interval integer,
    invchead_recurring_type text,
    invchead_recurring_until date,
    invchead_recurring_invchead_id integer,
    invchead_shipchrg_id integer,
    invchead_taxzone_id integer,
    invchead_void boolean DEFAULT false,
    invchead_saletype_id integer,
    invchead_shipzone_id integer,
    CONSTRAINT invchead_invchead_invcnumber_check CHECK ((invchead_invcnumber <> ''::text))
);


ALTER TABLE public.invchead OWNER TO admin;


--
-- TOC entry 225 (class 1259 OID 146566583)
-- Dependencies: 6028 6029 8
-- Name: prj; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE prj (
    prj_id integer NOT NULL,
    prj_number text NOT NULL,
    prj_name text NOT NULL,
    prj_descrip text,
    prj_status character(1) NOT NULL,
    prj_so boolean,
    prj_wo boolean,
    prj_po boolean,
    prj_owner_username text,
    prj_start_date date,
    prj_due_date date,
    prj_assigned_date date,
    prj_completed_date date,
    prj_username text,
    prj_recurring_prj_id integer,
    prj_crmacct_id integer,
    prj_cntct_id integer,
    prj_prjtype_id integer,
    CONSTRAINT prj_prj_number_check CHECK ((prj_number <> ''::text)),
    CONSTRAINT prj_prj_status_check CHECK ((prj_status = ANY (ARRAY['P'::bpchar, 'O'::bpchar, 'C'::bpchar])))
);


ALTER TABLE public.prj OWNER TO admin;


--
-- TOC entry 226 (class 1259 OID 146566591)
-- Dependencies: 6031 8
-- Name: saletype; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE saletype (
    saletype_id integer NOT NULL,
    saletype_code text NOT NULL,
    saletype_descr text,
    saletype_active boolean DEFAULT true NOT NULL
);


ALTER TABLE public.saletype OWNER TO admin;


--
-- TOC entry 227 (class 1259 OID 146566598)
-- Dependencies: 6032 6033 8
-- Name: shipzone; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE shipzone (
    shipzone_id integer DEFAULT nextval(('shipzone_shipzone_id_seq'::text)::regclass) NOT NULL,
    shipzone_name text NOT NULL,
    shipzone_descrip text,
    CONSTRAINT shipzone_shipzone_name_check CHECK ((shipzone_name <> ''::text))
);


ALTER TABLE public.shipzone OWNER TO admin;

--
-- TOC entry 9056 (class 0 OID 0)
-- Dependencies: 227
-- Name: TABLE shipzone; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE shipzone IS 'Shipping Zone information';


--
-- TOC entry 229 (class 1259 OID 146566612)
-- Dependencies: 6035 6036 8
-- Name: invcitem; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE invcitem (
    invcitem_id integer NOT NULL,
    invcitem_invchead_id integer NOT NULL,
    invcitem_linenumber integer,
    invcitem_item_id integer,
    invcitem_warehous_id integer DEFAULT (-1),
    invcitem_custpn text,
    invcitem_number text,
    invcitem_descrip text,
    invcitem_ordered numeric(20,6) NOT NULL,
    invcitem_billed numeric(20,6) NOT NULL,
    invcitem_custprice numeric(20,4),
    invcitem_price numeric(20,4) NOT NULL,
    invcitem_notes text,
    invcitem_salescat_id integer,
    invcitem_taxtype_id integer,
    invcitem_qty_uom_id integer,
    invcitem_qty_invuomratio numeric(20,10) NOT NULL,
    invcitem_price_uom_id integer,
    invcitem_price_invuomratio numeric(20,10) NOT NULL,
    invcitem_coitem_id integer,
    invcitem_updateinv boolean DEFAULT false,
    invcitem_rev_accnt_id integer
);


ALTER TABLE public.invcitem OWNER TO admin;


--
-- TOC entry 231 (class 1259 OID 146566739)
-- Dependencies: 6038 6039 8
-- Name: ophead; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE ophead (
    ophead_id integer NOT NULL,
    ophead_name text NOT NULL,
    ophead_crmacct_id integer,
    ophead_owner_username text,
    ophead_opstage_id integer,
    ophead_opsource_id integer,
    ophead_optype_id integer,
    ophead_probability_prcnt integer,
    ophead_amount numeric(20,4),
    ophead_target_date date,
    ophead_actual_date date,
    ophead_notes text,
    ophead_curr_id integer,
    ophead_active boolean DEFAULT true,
    ophead_cntct_id integer,
    ophead_username text,
    ophead_start_date date,
    ophead_assigned_date date,
    ophead_priority_id integer,
    ophead_number text NOT NULL,
    CONSTRAINT ophead_ophead_number_check CHECK ((ophead_number <> ''::text))
);


ALTER TABLE public.ophead OWNER TO admin;


--
-- TOC entry 232 (class 1259 OID 146566885)
-- Dependencies: 6041 8
-- Name: prjtask; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE prjtask (
    prjtask_id integer NOT NULL,
    prjtask_number text NOT NULL,
    prjtask_name text NOT NULL,
    prjtask_descrip text,
    prjtask_prj_id integer NOT NULL,
    prjtask_anyuser boolean,
    prjtask_status character(1) NOT NULL,
    prjtask_hours_budget numeric(18,6) NOT NULL,
    prjtask_hours_actual numeric(18,6) NOT NULL,
    prjtask_exp_budget numeric(16,4) NOT NULL,
    prjtask_exp_actual numeric(16,4) NOT NULL,
    prjtask_owner_username text,
    prjtask_start_date date,
    prjtask_due_date date,
    prjtask_assigned_date date,
    prjtask_completed_date date,
    prjtask_username text,
    CONSTRAINT prjtask_prjtask_status_check CHECK ((prjtask_status = ANY (ARRAY['P'::bpchar, 'O'::bpchar, 'C'::bpchar])))
);


ALTER TABLE public.prjtask OWNER TO admin;


--
-- TOC entry 2157 (class 1255 OID 146567005)
-- Dependencies: 4536 8
-- Name: saveaddr(integer, text, text, text, text, text, text, text, text, boolean, text, text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION saveaddr(integer, text, text, text, text, text, text, text, text, boolean, text, text) RETURNS integer
    LANGUAGE plpgsql
    AS $_$
-- Copyright (c) 1999-2014 by OpenMFG LLC, d/b/a xTuple.
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  pAddrId ALIAS FOR $1;
  pNumber ALIAS FOR $2;
  pAddr1 ALIAS FOR $3;
  pAddr2 ALIAS FOR $4;
  pAddr3 ALIAS FOR $5;
  pCity ALIAS FOR $6;
  pState ALIAS FOR $7;
  pPostalCode ALIAS FOR $8;
  pCountry ALIAS FOR $9;
  pActive ALIAS FOR $10;
  pNotes ALIAS FOR $11;
  pFlag ALIAS FOR $12;
  _addrId INTEGER;
  _addrNumber INTEGER;
  _flag TEXT;
  _p RECORD;
  _cnt INTEGER;
  _notes TEXT;

BEGIN
  --Validate
  IF ((pFlag IS NULL) OR (pFlag = '') OR (pFlag = 'CHECK') OR (pFlag = 'CHANGEONE') OR (pFlag = 'CHANGEALL')) THEN
    IF (pFlag='') THEN
      _flag := 'CHECK';
    ELSE
      _flag := COALESCE(pFlag,'CHECK');
    END IF;
  ELSE
	RAISE EXCEPTION 'Invalid Flag (%). Valid flags are CHECK, CHANGEONE or CHANGEALL', pFlag;
  END IF;

  _notes := COALESCE(pNotes,'');

  --If there is nothing here, get out
  IF ( (pNumber = '' OR pNumber IS NULL)
    AND (pAddr1 = '' OR pAddr1 IS NULL)
    AND (pAddr2 = '' OR pAddr2 IS NULL)
    AND (pAddr3 = '' OR pAddr3 IS NULL)
    AND (pCity = '' OR pCity IS NULL)
    AND (pState = '' OR pState IS NULL)
    AND (pPostalCode = '' OR pPostalCode IS NULL)
    AND (pCountry = '' OR pCountry IS NULL) ) THEN
    RETURN NULL;

  END IF;

  _addrId := COALESCE(pAddrId,-1);

  --If we have an ID see if anything has changed, if not get out
  IF (_addrId >= 0) THEN
    SELECT * FROM addr INTO _p
    WHERE ((pAddrId=addr_id)
    AND (COALESCE(pNumber,addr_number)=addr_number)
    AND (COALESCE(pAddr1, '')=COALESCE(addr_line1, ''))
    AND (COALESCE(pAddr2, '')=COALESCE(addr_line2, ''))
    AND (COALESCE(pAddr3, '')=COALESCE(addr_line3, ''))
    AND (COALESCE(pCity, '')=COALESCE(addr_city, ''))
    AND (COALESCE(pState, '')=COALESCE(addr_state, ''))
    AND (COALESCE(pPostalCode, '')=COALESCE(addr_postalcode, ''))
    AND (COALESCE(pCountry, '')=COALESCE(addr_country, ''))
    AND (pActive=addr_active)
    AND (_notes=COALESCE(addr_notes,'')));
    IF (FOUND) THEN
      RETURN _addrId;
    END IF;
  END IF;

  --Check to see if duplicate address exists

    SELECT addr_id, addr_notes INTO _p
    FROM addr
    WHERE ((_addrId <> addr_id)
    AND  (COALESCE(UPPER(addr_line1),'') = COALESCE(UPPER(pAddr1),''))
    AND  (COALESCE(UPPER(addr_line2),'') = COALESCE(UPPER(pAddr2),''))
    AND  (COALESCE(UPPER(addr_line3),'') = COALESCE(UPPER(pAddr3),''))
    AND  (COALESCE(UPPER(addr_city),'') = COALESCE(UPPER(pCity),''))
    AND  (COALESCE(UPPER(addr_state),'') = COALESCE(UPPER(pState),''))
    AND  (COALESCE(UPPER(addr_postalcode),'') = COALESCE(UPPER(pPostalcode),''))
    AND  (COALESCE(UPPER(addr_country),'') = COALESCE(UPPER(pCountry),'')));
    IF (FOUND) THEN
	--Note:  To prevent overwriting of existing notes, the application
	--needs to load any existing notes for a matching address before altering them.
	IF (_notes <> _p.addr_notes) THEN
		UPDATE addr
		SET addr_notes=addr_notes || '
' || _notes
		WHERE addr_id=_p.addr_id;
	END IF;
        RETURN _p.addr_id;  --A matching address exits
    END IF;

  IF (_addrId < 0) THEN
    _flag := 'CHANGEONE';
  END IF;

  IF (_flag = 'CHECK') THEN
    IF addrUseCount(_addrId) > 1 THEN
      RETURN -2;
    ELSIF (SELECT COUNT(addr_id)=0 FROM addr WHERE (addr_id=_addrId)) THEN
      _flag := 'CHANGEONE';
    ELSE
      _flag := 'CHANGEALL';
    END IF;
  END IF;

  IF (_flag = 'CHANGEALL') THEN
    _addrNumber := pNumber;
    IF (_addrNumber IS NULL) THEN
      SELECT addr_number INTO _addrNumber
        FROM addr
       WHERE(addr_id = _addrId);
      IF (_addrNumber IS NULL) THEN
        _addrNumber := fetchNextNumber('AddressNumber');
      END IF;
    END IF;

    UPDATE addr SET
      addr_line1 = pAddr1, addr_line2 = pAddr2, addr_line3 = pAddr3,
      addr_city = pCity, addr_state = pState,
      addr_postalcode = pPostalcode, addr_country = pCountry,
      addr_active = pActive, addr_notes = pNotes
    WHERE addr_id = _addrId;
    RETURN _addrId;

  ELSE
    SELECT NEXTVAL('addr_addr_id_seq') INTO _addrId;

    IF (_flag = 'CHANGEONE') THEN
      _addrNumber := fetchNextNumber('AddressNumber');
    ELSE
      _addrNumber := COALESCE(pNumber::text,fetchNextNumber('AddressNumber'));
    END IF;

    INSERT INTO addr ( addr_id, addr_number,
    addr_line1, addr_line2, addr_line3,
    addr_city, addr_state, addr_postalcode, addr_country,
    addr_active, addr_notes
    ) VALUES ( _addrId, _addrNumber,
    pAddr1, pAddr2, pAddr3,
    pCity, pState, pPostalcode, pCountry,
    pActive, _notes);
    RETURN _addrId;

  END IF;
END;
$_$;


ALTER FUNCTION public.saveaddr(integer, text, text, text, text, text, text, text, text, boolean, text, text) OWNER TO admin;

--
-- TOC entry 2163 (class 1255 OID 146567012)
-- Dependencies: 4536 8
-- Name: savecntct(integer, text, integer, integer, text, text, text, text, text, text, boolean, text, text, text, text, text, text, text, text, text); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION savecntct(pcntctid integer, pcontactnumber text, pcrmacctid integer, paddrid integer, phonorific text, pfirstname text, pmiddlename text, plastname text, psuffix text, pinitials text, pactive boolean, pphone text, pphone2 text, pfax text, pemail text, pwebaddr text, pnotes text, ptitle text, pflag text, pownerusername text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
-- Copyright (c) 1999-2014 by OpenMFG LLC, d/b/a xTuple.
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  _cntctId INTEGER;
  _cntctNumber TEXT;
  _isNew BOOLEAN;
  _flag TEXT;
  _contactCount INTEGER := 0;

BEGIN
  --Validate
  IF ((pFlag IS NULL) OR (pFlag = '') OR (pFlag = 'CHECK') OR (pFlag = 'CHANGEONE') OR (pFlag = 'CHANGEALL')) THEN
    IF (pFlag='') THEN
      _flag := 'CHECK';
    ELSE
      _flag := COALESCE(pFlag,'CHECK');
    END IF;
  ELSE
	RAISE EXCEPTION 'Invalid Flag (%). Valid flags are CHECK, CHANGEONE or CHANGEALL', pFlag;
  END IF;

  --If there is nothing here get out
  IF ( (pCntctId IS NULL OR pCntctId = -1)
	AND (pAddrId IS NULL)
	AND (COALESCE(pFirstName, '') = '')
	AND (COALESCE(pMiddleName, '') = '')
	AND (COALESCE(pLastName, '') = '')
	AND (COALESCE(pSuffix, '') = '')
	AND (COALESCE(pHonorific, '') = '')
	AND (COALESCE(pInitials, '') = '')
	AND (COALESCE(pPhone, '') = '')
	AND (COALESCE(pPhone2, '') = '')
	AND (COALESCE(pFax, '') = '')
	AND (COALESCE(pEmail, '') = '')
	AND (COALESCE(pWebAddr, '') = '')
	AND (COALESCE(pNotes, '') = '')
	AND (COALESCE(pTitle, '') = '') ) THEN

	RETURN NULL;

  END IF;

  IF (pCntctId IS NULL OR pCntctId = -1) THEN
    _isNew := true;
    _cntctId := nextval('cntct_cntct_id_seq');
    _cntctNumber := COALESCE(pContactNumber,fetchNextNumber('ContactNumber'));
  ELSE
    SELECT COUNT(cntct_id) INTO _contactCount
      FROM cntct
      WHERE ((cntct_id=pCntctId)
      AND (cntct_first_name=pFirstName)
      AND (cntct_last_name=pLastName));

    -- ask whether new or update if name changes
    -- but only if this isn't a new record with a pre-allocated id
    IF (_contactCount < 1 AND _flag = 'CHECK') THEN
      IF (EXISTS(SELECT cntct_id
                 FROM cntct
                 WHERE (cntct_id=pCntctId))) THEN
        RETURN -10;
      ELSE
        _isNew := true;
        _cntctNumber := fetchNextNumber('ContactNumber');
      END IF;
    ELSIF (_flag = 'CHANGEONE') THEN
      _isNew := true;
      _cntctId := nextval('cntct_cntct_id_seq');
      _cntctNumber := fetchNextNumber('ContactNumber');
    ELSIF (_flag = 'CHANGEALL') THEN
      _isNew := false;
    END IF;
  END IF;

  IF (pContactNumber = '') THEN
    _cntctNumber := fetchNextNumber('ContactNumber');
  ELSE
    _cntctNumber := COALESCE(_cntctNumber,pContactNumber,fetchNextNumber('ContactNumber'));
  END IF;

  IF (_isNew) THEN
    _cntctId := COALESCE(_cntctId,pCntctId,nextval('cntct_cntct_id_seq'));

    INSERT INTO cntct (
      cntct_id,cntct_number,
      cntct_crmacct_id,cntct_addr_id,cntct_first_name,
      cntct_last_name,cntct_honorific,cntct_initials,
      cntct_active,cntct_phone,cntct_phone2,
      cntct_fax,cntct_email,cntct_webaddr,
      cntct_notes,cntct_title,cntct_middle,cntct_suffix, cntct_owner_username )
    VALUES (
      _cntctId, COALESCE(_cntctNumber,fetchNextNumber('ContactNumber')) ,pCrmAcctId,pAddrId,
      pFirstName,pLastName,pHonorific,
      pInitials,COALESCE(pActive,true),pPhone,pPhone2,pFax,
      pEmail,pWebAddr,pNotes,pTitle,pMiddleName,pSuffix,pOwnerUsername );

    RETURN _cntctId;

  ELSE
    UPDATE cntct SET
      cntct_number=COALESCE(_cntctNumber,fetchNextNumber('ContactNumber')),
      cntct_crmacct_id=COALESCE(pCrmAcctId,cntct_crmacct_id),
      cntct_addr_id=COALESCE(pAddrId,cntct_addr_id),
      cntct_first_name=COALESCE(pFirstName,cntct_first_name),
      cntct_last_name=COALESCE(pLastName,cntct_last_name),
      cntct_honorific=COALESCE(pHonorific,cntct_honorific),
      cntct_initials=COALESCE(pInitials,cntct_initials),
      cntct_active=COALESCE(pActive,cntct_active),
      cntct_phone=COALESCE(pPhone,cntct_phone),
      cntct_phone2=COALESCE(pPhone2,cntct_phone2),
      cntct_fax=COALESCE(pFax,cntct_fax),
      cntct_email=COALESCE(pEmail,cntct_email),
      cntct_webaddr=COALESCE(pWebAddr,cntct_webaddr),
      cntct_notes=COALESCE(pNotes,cntct_notes),
      cntct_title=COALESCE(pTitle,cntct_title),
      cntct_middle=COALESCE(pMiddleName,cntct_middle),
      cntct_suffix=COALESCE(pSuffix,cntct_suffix),
      cntct_owner_username=COALESCE(pOwnerUsername, cntct_owner_username)
    WHERE (cntct_id=pCntctId);

    RETURN pCntctId;

  END IF;
END;
$$;


ALTER FUNCTION public.savecntct(pcntctid integer, pcontactnumber text, pcrmacctid integer, paddrid integer, phonorific text, pfirstname text, pmiddlename text, plastname text, psuffix text, pinitials text, pactive boolean, pphone text, pphone2 text, pfax text, pemail text, pwebaddr text, pnotes text, ptitle text, pflag text, pownerusername text) OWNER TO admin;

--
-- TOC entry 2233 (class 1255 OID 146567082)
-- Dependencies: 8
-- Name: startoftime(); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION startoftime() RETURNS date
    LANGUAGE sql IMMUTABLE
    AS $$
-- Copyright (c) 1999-2014 by OpenMFG LLC, d/b/a xTuple.
-- See www.xtuple.com/CPAL for the full text of the software license.
SELECT DATE('1970-01-01') AS return;
$$;


ALTER FUNCTION public.startoftime() OWNER TO admin;


--
-- TOC entry 233 (class 1259 OID 146567113)
-- Dependencies: 6042 6043 6044 8
-- Name: todoitem; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE todoitem (
    todoitem_id integer NOT NULL,
    todoitem_name text NOT NULL,
    todoitem_description text,
    todoitem_incdt_id integer,
    todoitem_creator_username text DEFAULT geteffectivextuser() NOT NULL,
    todoitem_status character(1),
    todoitem_active boolean DEFAULT true NOT NULL,
    todoitem_start_date date,
    todoitem_due_date date,
    todoitem_assigned_date date,
    todoitem_completed_date date,
    todoitem_seq integer DEFAULT 0 NOT NULL,
    todoitem_notes text,
    todoitem_crmacct_id integer,
    todoitem_ophead_id integer,
    todoitem_owner_username text,
    todoitem_priority_id integer,
    todoitem_username text,
    todoitem_recurring_todoitem_id integer,
    todoitem_cntct_id integer
);


ALTER TABLE public.todoitem OWNER TO admin;

--
-- TOC entry 9076 (class 0 OID 0)
-- Dependencies: 233
-- Name: TABLE todoitem; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE todoitem IS 'To-Do List items.';


--
-- TOC entry 9077 (class 0 OID 0)
-- Dependencies: 233
-- Name: COLUMN todoitem.todoitem_recurring_todoitem_id; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN todoitem.todoitem_recurring_todoitem_id IS 'The first todoitem record in the series if this is a recurring To-Do item. If the todoitem_recurring_todoitem_id is the same as the todoitem_id, this record is the first in the series.';


--
-- TOC entry 234 (class 1259 OID 146567214)
-- Dependencies: 6046 6047 6048 6049 6050 6051 6052 6053 6054 6056 8
-- Name: addr; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE addr (
    addr_id integer NOT NULL,
    addr_active boolean DEFAULT true,
    addr_line1 text DEFAULT ''::text,
    addr_line2 text DEFAULT ''::text,
    addr_line3 text DEFAULT ''::text,
    addr_city text DEFAULT ''::text,
    addr_state text DEFAULT ''::text,
    addr_postalcode text DEFAULT ''::text,
    addr_country text DEFAULT ''::text,
    addr_notes text DEFAULT ''::text,
    addr_number text NOT NULL,
    CONSTRAINT addr_addr_number_check CHECK ((addr_number <> ''::text))
);


ALTER TABLE public.addr OWNER TO admin;

--
-- TOC entry 9081 (class 0 OID 0)
-- Dependencies: 234
-- Name: TABLE addr; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE addr IS 'Postal Address';


--
-- TOC entry 236 (class 1259 OID 146567235)
-- Dependencies: 6057 6058 6059 6060 6061 6062 6063 6064 6065 6066 6067 6068 6069 6071 8
-- Name: char; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE "char" (
    char_id integer NOT NULL,
    char_name text NOT NULL,
    char_items boolean,
    char_options boolean,
    char_attributes boolean,
    char_lotserial boolean,
    char_notes text,
    char_customers boolean,
    char_crmaccounts boolean,
    char_addresses boolean,
    char_contacts boolean,
    char_opportunity boolean,
    char_employees boolean DEFAULT false,
    char_mask text,
    char_validator text,
    char_incidents boolean DEFAULT false,
    char_type integer DEFAULT 0 NOT NULL,
    char_order integer DEFAULT 0 NOT NULL,
    char_search boolean DEFAULT true NOT NULL,
    char_quotes boolean DEFAULT false,
    char_salesorders boolean DEFAULT false,
    char_invoices boolean DEFAULT false,
    char_vendors boolean DEFAULT false,
    char_purchaseorders boolean DEFAULT false,
    char_vouchers boolean DEFAULT false,
    char_projects boolean DEFAULT false,
    char_tasks boolean DEFAULT false,
    CONSTRAINT char_char_name_check CHECK ((char_name <> ''::text))
);


ALTER TABLE public."char" OWNER TO admin;


--
-- TOC entry 237 (class 1259 OID 146567255)
-- Dependencies: 6073 6074 8
-- Name: charass; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE charass (
    charass_id integer NOT NULL,
    charass_target_type text,
    charass_target_id integer,
    charass_char_id integer,
    charass_value text,
    charass_default boolean DEFAULT false NOT NULL,
    charass_price numeric(16,4) DEFAULT 0 NOT NULL
);


ALTER TABLE public.charass OWNER TO admin;

--
-- TOC entry 9087 (class 0 OID 0)
-- Dependencies: 237
-- Name: TABLE charass; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE charass IS 'Characteristic assignment information';


--
-- TOC entry 239 (class 1259 OID 146567267)
-- Dependencies: 6076 6077 6078 8
-- Name: cmnttype; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE cmnttype (
    cmnttype_id integer NOT NULL,
    cmnttype_name text NOT NULL,
    cmnttype_descrip text NOT NULL,
    cmnttype_usedin text,
    cmnttype_sys boolean DEFAULT false NOT NULL,
    cmnttype_editable boolean DEFAULT false NOT NULL,
    cmnttype_order integer,
    CONSTRAINT cmnttype_cmnttype_name_check CHECK ((cmnttype_name <> ''::text))
);


ALTER TABLE public.cmnttype OWNER TO admin;

--
-- TOC entry 9091 (class 0 OID 0)
-- Dependencies: 239
-- Name: TABLE cmnttype; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE cmnttype IS 'Comment Type information';


--
-- TOC entry 240 (class 1259 OID 146567276)
-- Dependencies: 6079 8
-- Name: comment; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE comment (
    comment_id integer DEFAULT nextval(('"comment_comment_id_seq"'::text)::regclass) NOT NULL,
    comment_source_id integer,
    comment_date timestamp with time zone,
    comment_user text,
    comment_text text,
    comment_cmnttype_id integer,
    comment_source text,
    comment_public boolean
);


ALTER TABLE public.comment OWNER TO admin;

--
-- TOC entry 9093 (class 0 OID 0)
-- Dependencies: 240
-- Name: TABLE comment; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE comment IS 'Comment information';


--
-- TOC entry 242 (class 1259 OID 146567287)
-- Dependencies: 6081 6082 6083 8
-- Name: docass; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE docass (
    docass_id integer NOT NULL,
    docass_source_id integer NOT NULL,
    docass_source_type text NOT NULL,
    docass_target_id integer NOT NULL,
    docass_target_type text DEFAULT 'URL'::text NOT NULL,
    docass_purpose character(1) DEFAULT 'S'::bpchar NOT NULL,
    CONSTRAINT docass_docass_purpose_check CHECK (((((((((docass_purpose = 'I'::bpchar) OR (docass_purpose = 'E'::bpchar)) OR (docass_purpose = 'M'::bpchar)) OR (docass_purpose = 'P'::bpchar)) OR (docass_purpose = 'A'::bpchar)) OR (docass_purpose = 'C'::bpchar)) OR (docass_purpose = 'S'::bpchar)) OR (docass_purpose = 'D'::bpchar)))
);


ALTER TABLE public.docass OWNER TO admin;


--
-- TOC entry 243 (class 1259 OID 146567296)
-- Dependencies: 8
-- Name: file; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE file (
    file_id integer NOT NULL,
    file_title text NOT NULL,
    file_stream bytea,
    file_descrip text NOT NULL
);


ALTER TABLE public.file OWNER TO admin;

--
-- TOC entry 244 (class 1259 OID 146567302)
-- Dependencies: 8
-- Name: urlinfo; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE urlinfo (
    url_id integer NOT NULL,
    url_title text NOT NULL,
    url_url text NOT NULL
);


ALTER TABLE public.urlinfo OWNER TO admin;

--
-- TOC entry 247 (class 1259 OID 146567317)
-- Dependencies: 242 8
-- Name: docass_docass_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE docass_docass_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.docass_docass_id_seq OWNER TO admin;

--
-- TOC entry 9104 (class 0 OID 0)
-- Dependencies: 247
-- Name: docass_docass_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE docass_docass_id_seq OWNED BY docass.docass_id;


--
-- TOC entry 248 (class 1259 OID 146567319)
-- Dependencies: 6086 8
-- Name: image; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE image (
    image_id integer DEFAULT nextval(('"image_image_id_seq"'::text)::regclass) NOT NULL,
    image_name text,
    image_descrip text,
    image_data text
);


ALTER TABLE public.image OWNER TO admin;

--
-- TOC entry 9106 (class 0 OID 0)
-- Dependencies: 248
-- Name: TABLE image; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE image IS 'Image information';


--
-- TOC entry 249 (class 1259 OID 146567326)
-- Dependencies: 6087 6088 8
-- Name: imageass; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE imageass (
    imageass_id integer DEFAULT nextval('docass_docass_id_seq'::regclass) NOT NULL,
    imageass_source_id integer NOT NULL,
    imageass_source text NOT NULL,
    imageass_image_id integer NOT NULL,
    imageass_purpose character(1) NOT NULL,
    CONSTRAINT imageass_imageass_purpose_check CHECK (((((((((imageass_purpose = 'I'::bpchar) OR (imageass_purpose = 'E'::bpchar)) OR (imageass_purpose = 'M'::bpchar)) OR (imageass_purpose = 'P'::bpchar)) OR (imageass_purpose = 'A'::bpchar)) OR (imageass_purpose = 'C'::bpchar)) OR (imageass_purpose = 'D'::bpchar)) OR (imageass_purpose = 'S'::bpchar)))
);


ALTER TABLE public.imageass OWNER TO admin;

--
-- TOC entry 9108 (class 0 OID 0)
-- Dependencies: 249
-- Name: TABLE imageass; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE imageass IS 'Image Assignement References';


--
-- TOC entry 254 (class 1259 OID 146567350)
-- Dependencies: 6089 6090 6091 8
-- Name: bomhead; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE bomhead (
    bomhead_id integer DEFAULT nextval(('"bomhead_bomhead_id_seq"'::text)::regclass) NOT NULL,
    bomhead_item_id integer NOT NULL,
    bomhead_serial integer,
    bomhead_docnum text,
    bomhead_revision text,
    bomhead_revisiondate date,
    bomhead_batchsize numeric(18,6),
    bomhead_requiredqtyper numeric(20,8),
    bomhead_rev_id integer DEFAULT (-1),
    CONSTRAINT bomhead_bomhead_batchsize_check CHECK ((bomhead_batchsize > (0)::numeric))
);


ALTER TABLE public.bomhead OWNER TO admin;


--
-- TOC entry 258 (class 1259 OID 146567373)
-- Dependencies: 8
-- Name: bomitemsub; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE bomitemsub (
    bomitemsub_id integer NOT NULL,
    bomitemsub_bomitem_id integer NOT NULL,
    bomitemsub_item_id integer NOT NULL,
    bomitemsub_uomratio numeric(20,10) NOT NULL,
    bomitemsub_rank integer NOT NULL
);


ALTER TABLE public.bomitemsub OWNER TO admin;

--
-- TOC entry 9126 (class 0 OID 0)
-- Dependencies: 258
-- Name: TABLE bomitemsub; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE bomitemsub IS 'Bill of Materials (BOM) defined Substitutions information';


--
-- TOC entry 260 (class 1259 OID 146567381)
-- Dependencies: 6094 8
-- Name: budghead; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE budghead (
    budghead_id integer NOT NULL,
    budghead_name text NOT NULL,
    budghead_descrip text,
    CONSTRAINT budghead_budghead_name_check CHECK ((budghead_name <> ''::text))
);


ALTER TABLE public.budghead OWNER TO admin;

--
-- TOC entry 262 (class 1259 OID 146567392)
-- Dependencies: 6095 6096 6097 6098 8
-- Name: accnt; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE accnt (
    accnt_id integer DEFAULT nextval(('accnt_accnt_id_seq'::text)::regclass) NOT NULL,
    accnt_number text,
    accnt_descrip text,
    accnt_comments text,
    accnt_profit text,
    accnt_sub text,
    accnt_type character(1) NOT NULL,
    accnt_extref text,
    accnt_company text,
    accnt_forwardupdate boolean,
    accnt_subaccnttype_code text,
    accnt_curr_id integer DEFAULT basecurrid(),
    accnt_active boolean DEFAULT true NOT NULL,
    accnt_name text,
    CONSTRAINT accnt_accnt_type_check CHECK ((accnt_type = ANY (ARRAY['A'::bpchar, 'E'::bpchar, 'L'::bpchar, 'Q'::bpchar, 'R'::bpchar])))
);


ALTER TABLE public.accnt OWNER TO admin;


--
-- TOC entry 263 (class 1259 OID 146567402)
-- Dependencies: 8
-- Name: budgitem; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE budgitem (
    budgitem_id integer NOT NULL,
    budgitem_budghead_id integer NOT NULL,
    budgitem_period_id integer NOT NULL,
    budgitem_accnt_id integer NOT NULL,
    budgitem_amount numeric(20,4) NOT NULL
);


ALTER TABLE public.budgitem OWNER TO admin;

--
-- TOC entry 264 (class 1259 OID 146567405)
-- Dependencies: 6101 8
-- Name: period; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE period (
    period_id integer NOT NULL,
    period_start date,
    period_end date,
    period_closed boolean,
    period_freeze boolean,
    period_initial boolean DEFAULT false,
    period_name text,
    period_yearperiod_id integer,
    period_quarter integer,
    period_number integer NOT NULL
);


ALTER TABLE public.period OWNER TO admin;

--
-- TOC entry 9136 (class 0 OID 0)
-- Dependencies: 264
-- Name: TABLE period; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE period IS 'Accounting Period information';


--
-- TOC entry 266 (class 1259 OID 146567416)
-- Dependencies: 6102 6103 6104 6105 6106 6108 8
-- Name: bankaccnt; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE bankaccnt (
    bankaccnt_id integer NOT NULL,
    bankaccnt_name text NOT NULL,
    bankaccnt_descrip text,
    bankaccnt_bankname text,
    bankaccnt_accntnumber text,
    bankaccnt_ar boolean,
    bankaccnt_ap boolean,
    bankaccnt_nextchknum integer,
    bankaccnt_type character(1),
    bankaccnt_accnt_id integer,
    bankaccnt_check_form_id integer,
    bankaccnt_userec boolean,
    bankaccnt_rec_accnt_id integer,
    bankaccnt_curr_id integer DEFAULT basecurrid(),
    bankaccnt_notes text,
    bankaccnt_routing text DEFAULT ''::text NOT NULL,
    bankaccnt_ach_enabled boolean DEFAULT false NOT NULL,
    bankaccnt_ach_origin text DEFAULT ''::text NOT NULL,
    bankaccnt_ach_genchecknum boolean DEFAULT false NOT NULL,
    bankaccnt_ach_leadtime integer,
    bankaccnt_ach_lastdate date,
    bankaccnt_ach_lastfileid character(1),
    bankaccnt_ach_origintype text,
    bankaccnt_ach_originname text,
    bankaccnt_ach_desttype text,
    bankaccnt_ach_fed_dest text,
    bankaccnt_ach_destname text,
    bankaccnt_ach_dest text,
    CONSTRAINT bankaccnt_bankaccnt_name_check CHECK ((bankaccnt_name <> ''::text))
);


ALTER TABLE public.bankaccnt OWNER TO admin;


--
-- TOC entry 267 (class 1259 OID 146567428)
-- Dependencies: 6109 6110 6111 6112 6113 6114 6115 6117 8
-- Name: cashrcpt; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE cashrcpt (
    cashrcpt_id integer NOT NULL,
    cashrcpt_cust_id integer NOT NULL,
    cashrcpt_amount numeric(20,2) NOT NULL,
    cashrcpt_fundstype character(1) NOT NULL,
    cashrcpt_docnumber text,
    cashrcpt_bankaccnt_id integer NOT NULL,
    cashrcpt_notes text,
    cashrcpt_distdate date DEFAULT ('now'::text)::date,
    cashrcpt_salescat_id integer DEFAULT (-1),
    cashrcpt_curr_id integer DEFAULT basecurrid(),
    cashrcpt_usecustdeposit boolean DEFAULT false NOT NULL,
    cashrcpt_void boolean DEFAULT false NOT NULL,
    cashrcpt_number text NOT NULL,
    cashrcpt_docdate date,
    cashrcpt_posted boolean DEFAULT false NOT NULL,
    cashrcpt_posteddate date,
    cashrcpt_postedby text,
    cashrcpt_applydate date,
    cashrcpt_discount numeric(20,2) DEFAULT 0.00 NOT NULL,
    cashrcpt_curr_rate numeric NOT NULL,
    CONSTRAINT cashrcpt_cashrcpt_number_check CHECK ((cashrcpt_number <> ''::text))
);


ALTER TABLE public.cashrcpt OWNER TO admin;


--
-- TOC entry 269 (class 1259 OID 146567447)
-- Dependencies: 6119 6120 8
-- Name: cashrcptitem; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE cashrcptitem (
    cashrcptitem_id integer NOT NULL,
    cashrcptitem_cashrcpt_id integer NOT NULL,
    cashrcptitem_aropen_id integer NOT NULL,
    cashrcptitem_amount numeric(20,2) NOT NULL,
    cashrcptitem_discount numeric(20,2) DEFAULT 0.00 NOT NULL,
    cashrcptitem_applied boolean DEFAULT true
);


ALTER TABLE public.cashrcptitem OWNER TO admin;


--
-- TOC entry 271 (class 1259 OID 146567457)
-- Dependencies: 8
-- Name: cashrcptmisc; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE cashrcptmisc (
    cashrcptmisc_id integer NOT NULL,
    cashrcptmisc_cashrcpt_id integer NOT NULL,
    cashrcptmisc_accnt_id integer NOT NULL,
    cashrcptmisc_amount numeric(20,2) NOT NULL,
    cashrcptmisc_notes text
);


ALTER TABLE public.cashrcptmisc OWNER TO admin;


--
-- TOC entry 278 (class 1259 OID 146567491)
-- Dependencies: 6122 6123 6124 6125 6126 6127 6128 8
-- Name: ccard; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE ccard (
    ccard_id integer NOT NULL,
    ccard_seq integer DEFAULT 10 NOT NULL,
    ccard_cust_id integer NOT NULL,
    ccard_active boolean DEFAULT true,
    ccard_name bytea,
    ccard_address1 bytea,
    ccard_address2 bytea,
    ccard_city bytea,
    ccard_state bytea,
    ccard_zip bytea,
    ccard_country bytea,
    ccard_number bytea,
    ccard_debit boolean DEFAULT false,
    ccard_month_expired bytea,
    ccard_year_expired bytea,
    ccard_type character(1) NOT NULL,
    ccard_date_added timestamp without time zone DEFAULT ('now'::text)::timestamp(6) with time zone NOT NULL,
    ccard_lastupdated timestamp without time zone DEFAULT ('now'::text)::timestamp(6) with time zone NOT NULL,
    ccard_added_by_username text DEFAULT geteffectivextuser() NOT NULL,
    ccard_last_updated_by_username text DEFAULT geteffectivextuser() NOT NULL
);


ALTER TABLE public.ccard OWNER TO admin;

--
-- TOC entry 9164 (class 0 OID 0)
-- Dependencies: 278
-- Name: TABLE ccard; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE ccard IS 'Credit Card Information - all bytea data is encrypted';


--
-- TOC entry 280 (class 1259 OID 146567509)
-- Dependencies: 6130 6131 6132 8
-- Name: custtype; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE custtype (
    custtype_id integer DEFAULT nextval(('custtype_custtype_id_seq'::text)::regclass) NOT NULL,
    custtype_code text NOT NULL,
    custtype_descrip text NOT NULL,
    custtype_char boolean DEFAULT false NOT NULL,
    CONSTRAINT custtype_custtype_code_check CHECK ((custtype_code <> ''::text))
);


ALTER TABLE public.custtype OWNER TO admin;

--
-- TOC entry 9168 (class 0 OID 0)
-- Dependencies: 280
-- Name: TABLE custtype; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE custtype IS 'Customer Type information';


--
-- TOC entry 281 (class 1259 OID 146567518)
-- Dependencies: 6134 8
-- Name: shipchrg; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE shipchrg (
    shipchrg_id integer NOT NULL,
    shipchrg_name text NOT NULL,
    shipchrg_descrip text,
    shipchrg_custfreight boolean,
    shipchrg_handling character(1),
    CONSTRAINT shipchrg_shipchrg_name_check CHECK ((shipchrg_name <> ''::text))
);


ALTER TABLE public.shipchrg OWNER TO admin;

--
-- TOC entry 9170 (class 0 OID 0)
-- Dependencies: 281
-- Name: TABLE shipchrg; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE shipchrg IS 'Shipping Charge information';


--
-- TOC entry 282 (class 1259 OID 146567525)
-- Dependencies: 6135 6136 8
-- Name: shipform; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE shipform (
    shipform_id integer DEFAULT nextval(('"shipform_shipform_id_seq"'::text)::regclass) NOT NULL,
    shipform_name text NOT NULL,
    shipform_report_id integer,
    shipform_report_name text,
    CONSTRAINT shipform_shipform_name_check CHECK ((shipform_name <> ''::text))
);


ALTER TABLE public.shipform OWNER TO admin;

--
-- TOC entry 9172 (class 0 OID 0)
-- Dependencies: 282
-- Name: TABLE shipform; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE shipform IS 'Shipping Form information';


--
-- TOC entry 9173 (class 0 OID 0)
-- Dependencies: 282
-- Name: COLUMN shipform.shipform_report_id; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN shipform.shipform_report_id IS 'Obsolete -- reference shipform_report_name instead.';


--
-- TOC entry 284 (class 1259 OID 146567539)
-- Dependencies: 6138 8
-- Name: taxauth; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE taxauth (
    taxauth_id integer NOT NULL,
    taxauth_code text NOT NULL,
    taxauth_name text,
    taxauth_extref text,
    taxauth_addr_id integer,
    taxauth_curr_id integer,
    taxauth_county text,
    taxauth_accnt_id integer,
    CONSTRAINT taxauth_taxauth_code_check CHECK ((taxauth_code <> ''::text))
);


ALTER TABLE public.taxauth OWNER TO admin;


--
-- TOC entry 285 (class 1259 OID 146567549)
-- Dependencies: 6139 6140 6141 6143 8
-- Name: taxreg; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE taxreg (
    taxreg_id integer NOT NULL,
    taxreg_rel_id integer NOT NULL,
    taxreg_rel_type character(1),
    taxreg_taxauth_id integer,
    taxreg_number text NOT NULL,
    taxreg_taxzone_id integer,
    taxreg_effective date DEFAULT startoftime(),
    taxreg_expires date DEFAULT endoftime(),
    taxreg_notes text DEFAULT ''::text,
    CONSTRAINT taxreg_taxreg_number_check CHECK ((taxreg_number <> ''::text))
);


ALTER TABLE public.taxreg OWNER TO admin;

--
-- TOC entry 9180 (class 0 OID 0)
-- Dependencies: 285
-- Name: TABLE taxreg; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE taxreg IS 'Stores Tax Registration numbers related to objects and a given tax authority. The rel_id specifies the object id and teh rel_type specifies the object type. See column comment for additional detail on types.';


--
-- TOC entry 9181 (class 0 OID 0)
-- Dependencies: 285
-- Name: COLUMN taxreg.taxreg_rel_type; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN taxreg.taxreg_rel_type IS 'The type of relation this record is for. Known values are C=Customer, V=Vendor, NULL=This Manufacturer in which case taxreg_rel_id is meaningless and should be -1.';


--
-- TOC entry 291 (class 1259 OID 146567583)
-- Dependencies: 6145 8
-- Name: dept; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE dept (
    dept_id integer NOT NULL,
    dept_number text NOT NULL,
    dept_name text NOT NULL,
    CONSTRAINT dept_dept_number_check CHECK ((dept_number <> ''::text))
);


ALTER TABLE public.dept OWNER TO admin;

--
-- TOC entry 9193 (class 0 OID 0)
-- Dependencies: 291
-- Name: TABLE dept; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE dept IS 'List of Departments';


--
-- TOC entry 292 (class 1259 OID 146567590)
-- Dependencies: 6146 6147 6148 6150 6151 6152 6153 8
-- Name: emp; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE emp (
    emp_id integer NOT NULL,
    emp_code text NOT NULL,
    emp_number text NOT NULL,
    emp_active boolean DEFAULT true NOT NULL,
    emp_cntct_id integer,
    emp_warehous_id integer,
    emp_mgr_emp_id integer,
    emp_wage_type text NOT NULL,
    emp_wage numeric,
    emp_wage_curr_id integer DEFAULT basecurrid(),
    emp_wage_period text NOT NULL,
    emp_dept_id integer,
    emp_shift_id integer,
    emp_notes text,
    emp_image_id integer,
    emp_username text,
    emp_extrate numeric,
    emp_extrate_period text NOT NULL,
    emp_startdate date DEFAULT ('now'::text)::date,
    emp_name text NOT NULL,
    CONSTRAINT emp_check CHECK (((((COALESCE(emp_wage_type, ''::text) = ''::text) OR (COALESCE(emp_wage_type, ''::text) = 'H'::text)) OR (COALESCE(emp_wage_type, ''::text) = 'S'::text)) AND ((COALESCE(emp_wage, (0)::numeric) = (0)::numeric) OR ((COALESCE(emp_wage_type, ''::text) <> ''::text) AND (emp_wage IS NOT NULL))))),
    CONSTRAINT emp_emp_code_check CHECK ((emp_code <> ''::text)),
    CONSTRAINT emp_emp_number_check CHECK ((emp_number <> ''::text)),
    CONSTRAINT emp_emp_wage_period_check CHECK ((((((((COALESCE(emp_wage_period, ''::text) = ''::text) OR (COALESCE(emp_wage_period, ''::text) = 'H'::text)) OR (COALESCE(emp_wage_period, ''::text) = 'D'::text)) OR (COALESCE(emp_wage_period, ''::text) = 'W'::text)) OR (COALESCE(emp_wage_period, ''::text) = 'BW'::text)) OR (COALESCE(emp_wage_period, ''::text) = 'M'::text)) OR (COALESCE(emp_wage_period, ''::text) = 'Y'::text)))
);


ALTER TABLE public.emp OWNER TO admin;

--
-- TOC entry 293 (class 1259 OID 146567603)
-- Dependencies: 6155 8
-- Name: shift; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE shift (
    shift_id integer NOT NULL,
    shift_number text NOT NULL,
    shift_name text NOT NULL,
    CONSTRAINT shift_shift_number_check CHECK ((shift_number <> ''::text))
);


ALTER TABLE public.shift OWNER TO admin;

--
-- TOC entry 9204 (class 0 OID 0)
-- Dependencies: 293
-- Name: TABLE shift; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE shift IS 'List of work Shifts';


--
-- TOC entry 297 (class 1259 OID 146567623)
-- Dependencies: 6156 6157 6158 6159 8
-- Name: shipdata; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE shipdata (
    shipdata_cohead_number text NOT NULL,
    shipdata_cosmisc_tracknum text NOT NULL,
    shipdata_cosmisc_packnum_tracknum text NOT NULL,
    shipdata_weight numeric(16,4),
    shipdata_base_freight numeric(16,4),
    shipdata_total_freight numeric(16,4),
    shipdata_shipper text DEFAULT 'UPS'::text,
    shipdata_billing_option text,
    shipdata_package_type text,
    shipdata_void_ind character(1) NOT NULL,
    shipdata_lastupdated timestamp without time zone DEFAULT ('now'::text)::timestamp(6) with time zone NOT NULL,
    shipdata_shiphead_number text,
    shipdata_base_freight_curr_id integer DEFAULT basecurrid(),
    shipdata_total_freight_curr_id integer DEFAULT basecurrid()
);


ALTER TABLE public.shipdata OWNER TO admin;

--
-- TOC entry 9212 (class 0 OID 0)
-- Dependencies: 297
-- Name: TABLE shipdata; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE shipdata IS 'Shipping Interface information - note that the shipdata_cohead_nember is text and not int.  That is due to ODBC chopping off during the transfer';


--
-- TOC entry 299 (class 1259 OID 146567638)
-- Dependencies: 6161 8
-- Name: freightclass; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE freightclass (
    freightclass_id integer NOT NULL,
    freightclass_code text NOT NULL,
    freightclass_descrip text,
    CONSTRAINT freightclass_freightclass_code_check CHECK ((freightclass_code <> ''::text))
);


ALTER TABLE public.freightclass OWNER TO admin;

--
-- TOC entry 9216 (class 0 OID 0)
-- Dependencies: 299
-- Name: TABLE freightclass; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE freightclass IS 'This table is the freight price schedules.';


--
-- TOC entry 300 (class 1259 OID 146567645)
-- Dependencies: 6163 6164 8
-- Name: ipsfreight; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE ipsfreight (
    ipsfreight_id integer NOT NULL,
    ipsfreight_ipshead_id integer NOT NULL,
    ipsfreight_qtybreak numeric DEFAULT 0 NOT NULL,
    ipsfreight_price numeric DEFAULT 0 NOT NULL,
    ipsfreight_type character(1) NOT NULL,
    ipsfreight_warehous_id integer,
    ipsfreight_shipzone_id integer,
    ipsfreight_freightclass_id integer,
    ipsfreight_shipvia text
);


ALTER TABLE public.ipsfreight OWNER TO admin;

--
-- TOC entry 301 (class 1259 OID 146567653)
-- Dependencies: 6165 6166 6167 8
-- Name: ipshead; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE ipshead (
    ipshead_id integer DEFAULT nextval(('"ipshead_ipshead_id_seq"'::text)::regclass) NOT NULL,
    ipshead_name text NOT NULL,
    ipshead_descrip text,
    ipshead_effective date,
    ipshead_expires date,
    ipshead_curr_id integer DEFAULT basecurrid() NOT NULL,
    ipshead_updated date,
    CONSTRAINT ipshead_ipshead_name_check CHECK ((ipshead_name <> ''::text))
);


ALTER TABLE public.ipshead OWNER TO admin;


--
-- TOC entry 304 (class 1259 OID 146567672)
-- Dependencies: 6169 8
-- Name: incdtcat; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE incdtcat (
    incdtcat_id integer NOT NULL,
    incdtcat_name text NOT NULL,
    incdtcat_order integer,
    incdtcat_descrip text,
    incdtcat_ediprofile_id integer,
    CONSTRAINT incdtcat_incdtcat_name_check CHECK ((incdtcat_name <> ''::text))
);


ALTER TABLE public.incdtcat OWNER TO admin;

--
-- TOC entry 9225 (class 0 OID 0)
-- Dependencies: 304
-- Name: TABLE incdtcat; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE incdtcat IS 'Incident Category table';


--
-- TOC entry 305 (class 1259 OID 146567679)
-- Dependencies: 6171 8
-- Name: incdtpriority; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE incdtpriority (
    incdtpriority_id integer NOT NULL,
    incdtpriority_name text NOT NULL,
    incdtpriority_order integer,
    incdtpriority_descrip text,
    CONSTRAINT incdtpriority_incdtpriority_name_check CHECK ((incdtpriority_name <> ''::text))
);


ALTER TABLE public.incdtpriority OWNER TO admin;

--
-- TOC entry 9227 (class 0 OID 0)
-- Dependencies: 305
-- Name: TABLE incdtpriority; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE incdtpriority IS 'Incident Priority table';


--
-- TOC entry 306 (class 1259 OID 146567686)
-- Dependencies: 6173 8
-- Name: incdtresolution; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE incdtresolution (
    incdtresolution_id integer NOT NULL,
    incdtresolution_name text NOT NULL,
    incdtresolution_order integer,
    incdtresolution_descrip text,
    CONSTRAINT incdtresolution_incdtresolution_name_check CHECK ((incdtresolution_name <> ''::text))
);


ALTER TABLE public.incdtresolution OWNER TO admin;

--
-- TOC entry 9229 (class 0 OID 0)
-- Dependencies: 306
-- Name: TABLE incdtresolution; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE incdtresolution IS 'Incident Resolution table';


--
-- TOC entry 307 (class 1259 OID 146567693)
-- Dependencies: 6175 8
-- Name: incdtseverity; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE incdtseverity (
    incdtseverity_id integer NOT NULL,
    incdtseverity_name text NOT NULL,
    incdtseverity_order integer,
    incdtseverity_descrip text,
    CONSTRAINT incdtseverity_incdtseverity_name_check CHECK ((incdtseverity_name <> ''::text))
);


ALTER TABLE public.incdtseverity OWNER TO admin;

--
-- TOC entry 9231 (class 0 OID 0)
-- Dependencies: 307
-- Name: TABLE incdtseverity; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE incdtseverity IS 'Incident Severity table';


--
-- TOC entry 313 (class 1259 OID 146567721)
-- Dependencies: 6176 6177 8
-- Name: classcode; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE classcode (
    classcode_id integer DEFAULT nextval(('classcode_classcode_id_seq'::text)::regclass) NOT NULL,
    classcode_code text NOT NULL,
    classcode_descrip text,
    classcode_mfg boolean,
    classcode_creator text,
    classcode_created timestamp without time zone,
    classcode_modifier text,
    classcode_modified timestamp without time zone,
    classcode_type text,
    CONSTRAINT classcode_classcode_code_check CHECK ((classcode_code <> ''::text))
);


ALTER TABLE public.classcode OWNER TO admin;

--
-- TOC entry 9243 (class 0 OID 0)
-- Dependencies: 313
-- Name: TABLE classcode; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE classcode IS 'Class Code information';


--
-- TOC entry 314 (class 1259 OID 146567729)
-- Dependencies: 6178 6179 8
-- Name: prodcat; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE prodcat (
    prodcat_id integer DEFAULT nextval(('prodcat_prodcat_id_seq'::text)::regclass) NOT NULL,
    prodcat_code text NOT NULL,
    prodcat_descrip text,
    CONSTRAINT prodcat_prodcat_code_check CHECK ((prodcat_code <> ''::text))
);


ALTER TABLE public.prodcat OWNER TO admin;

--
-- TOC entry 9245 (class 0 OID 0)
-- Dependencies: 314
-- Name: TABLE prodcat; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE prodcat IS 'Product Category information';


--
-- TOC entry 316 (class 1259 OID 146567742)
-- Dependencies: 6180 6181 8
-- Name: itemalias; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE itemalias (
    itemalias_id integer DEFAULT nextval(('"itemalias_itemalias_id_seq"'::text)::regclass) NOT NULL,
    itemalias_item_id integer NOT NULL,
    itemalias_number text NOT NULL,
    itemalias_comments text,
    itemalias_usedescrip boolean NOT NULL,
    itemalias_descrip1 text,
    itemalias_descrip2 text,
    itemalias_crmacct_id integer,
    CONSTRAINT itemalias_itemalias_number_check CHECK ((itemalias_number <> ''::text))
);


ALTER TABLE public.itemalias OWNER TO admin;


--
-- TOC entry 320 (class 1259 OID 146567762)
-- Dependencies: 6182 6183 8
-- Name: costelem; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE costelem (
    costelem_id integer DEFAULT nextval(('costelem_costelem_id_seq'::text)::regclass) NOT NULL,
    costelem_type text NOT NULL,
    costelem_sys boolean,
    costelem_po boolean,
    costelem_active boolean,
    costelem_exp_accnt_id integer,
    costelem_cost_item_id integer,
    CONSTRAINT costelem_costelem_type_check CHECK ((costelem_type <> ''::text))
);


ALTER TABLE public.costelem OWNER TO admin;

--
-- TOC entry 9258 (class 0 OID 0)
-- Dependencies: 320
-- Name: TABLE costelem; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE costelem IS 'Costing Element information';


--
-- TOC entry 321 (class 1259 OID 146567770)
-- Dependencies: 6184 6185 6186 6187 6188 8
-- Name: itemcost; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE itemcost (
    itemcost_id integer DEFAULT nextval(('itemcost_itemcost_id_seq'::text)::regclass) NOT NULL,
    itemcost_item_id integer NOT NULL,
    itemcost_costelem_id integer NOT NULL,
    itemcost_lowlevel boolean DEFAULT false NOT NULL,
    itemcost_stdcost numeric(16,6) DEFAULT 0 NOT NULL,
    itemcost_posted date,
    itemcost_actcost numeric(16,6) DEFAULT 0 NOT NULL,
    itemcost_updated date,
    itemcost_curr_id integer DEFAULT basecurrid() NOT NULL
);


ALTER TABLE public.itemcost OWNER TO admin;

--
-- TOC entry 9260 (class 0 OID 0)
-- Dependencies: 321
-- Name: TABLE itemcost; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE itemcost IS 'Item Cost information';


--
-- TOC entry 325 (class 1259 OID 146567792)
-- Dependencies: 6189 6190 8
-- Name: costcat; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE costcat (
    costcat_id integer DEFAULT nextval(('costcat_costcat_id_seq'::text)::regclass) NOT NULL,
    costcat_code text NOT NULL,
    costcat_descrip text,
    costcat_asset_accnt_id integer,
    costcat_liability_accnt_id integer,
    costcat_adjustment_accnt_id integer,
    costcat_matusage_accnt_id integer,
    costcat_purchprice_accnt_id integer,
    costcat_laboroverhead_accnt_id integer,
    costcat_scrap_accnt_id integer,
    costcat_invcost_accnt_id integer,
    costcat_wip_accnt_id integer,
    costcat_shipasset_accnt_id integer,
    costcat_mfgscrap_accnt_id integer,
    costcat_transform_accnt_id integer,
    costcat_freight_accnt_id integer,
    costcat_toliability_accnt_id integer,
    costcat_exp_accnt_id integer,
    CONSTRAINT costcat_costcat_code_check CHECK ((costcat_code <> ''::text))
);


ALTER TABLE public.costcat OWNER TO admin;

--
-- TOC entry 9268 (class 0 OID 0)
-- Dependencies: 325
-- Name: TABLE costcat; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE costcat IS 'Cost Category information';


--
-- TOC entry 326 (class 1259 OID 146567800)
-- Dependencies: 6191 6192 8
-- Name: plancode; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE plancode (
    plancode_id integer DEFAULT nextval(('plancode_plancode_id_seq'::text)::regclass) NOT NULL,
    plancode_code text NOT NULL,
    plancode_name text,
    plancode_mpsexplosion character(1),
    plancode_consumefcst boolean,
    plancode_mrpexcp_resched boolean,
    plancode_mrpexcp_delete boolean,
    CONSTRAINT plancode_plancode_code_check CHECK ((plancode_code <> ''::text))
);


ALTER TABLE public.plancode OWNER TO admin;

--
-- TOC entry 9270 (class 0 OID 0)
-- Dependencies: 326
-- Name: TABLE plancode; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE plancode IS 'Planner Code information';


--
-- TOC entry 329 (class 1259 OID 146567818)
-- Dependencies: 8
-- Name: contrct; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE contrct (
    contrct_id integer NOT NULL,
    contrct_number text NOT NULL,
    contrct_vend_id integer NOT NULL,
    contrct_descrip text,
    contrct_effective date NOT NULL,
    contrct_expires date NOT NULL,
    contrct_note text
);


ALTER TABLE public.contrct OWNER TO admin;

--
-- TOC entry 9276 (class 0 OID 0)
-- Dependencies: 329
-- Name: TABLE contrct; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE contrct IS 'Grouping of Item Sources for a Vendor with common effective and expiration dates.';


--
-- TOC entry 9277 (class 0 OID 0)
-- Dependencies: 329
-- Name: COLUMN contrct.contrct_id; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN contrct.contrct_id IS 'Sequence identifier for contract.';


--
-- TOC entry 9278 (class 0 OID 0)
-- Dependencies: 329
-- Name: COLUMN contrct.contrct_number; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN contrct.contrct_number IS 'User defined identifier for contract.';


--
-- TOC entry 9279 (class 0 OID 0)
-- Dependencies: 329
-- Name: COLUMN contrct.contrct_vend_id; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN contrct.contrct_vend_id IS 'Vendor associated with contract.';


--
-- TOC entry 9280 (class 0 OID 0)
-- Dependencies: 329
-- Name: COLUMN contrct.contrct_descrip; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN contrct.contrct_descrip IS 'Description for contract.';


--
-- TOC entry 9281 (class 0 OID 0)
-- Dependencies: 329
-- Name: COLUMN contrct.contrct_effective; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN contrct.contrct_effective IS 'Effective date for contract.  Constraint for overlap.';


--
-- TOC entry 9282 (class 0 OID 0)
-- Dependencies: 329
-- Name: COLUMN contrct.contrct_expires; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN contrct.contrct_expires IS 'Expiration date for contract.  Constraint for overlap.';


--
-- TOC entry 9283 (class 0 OID 0)
-- Dependencies: 329
-- Name: COLUMN contrct.contrct_note; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN contrct.contrct_note IS 'Notes for contract.';


--
-- TOC entry 330 (class 1259 OID 146567824)
-- Dependencies: 6194 6195 6196 6197 6198 6199 6200 8
-- Name: itemsrc; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE itemsrc (
    itemsrc_id integer DEFAULT nextval(('"itemsrc_itemsrc_id_seq"'::text)::regclass) NOT NULL,
    itemsrc_item_id integer NOT NULL,
    itemsrc_vend_id integer NOT NULL,
    itemsrc_vend_item_number text,
    itemsrc_vend_item_descrip text,
    itemsrc_comments text,
    itemsrc_vend_uom text NOT NULL,
    itemsrc_invvendoruomratio numeric(20,10) NOT NULL,
    itemsrc_minordqty numeric(18,6) NOT NULL,
    itemsrc_multordqty numeric(18,6) NOT NULL,
    itemsrc_leadtime integer NOT NULL,
    itemsrc_ranking integer NOT NULL,
    itemsrc_active boolean NOT NULL,
    itemsrc_manuf_name text DEFAULT ''::text NOT NULL,
    itemsrc_manuf_item_number text DEFAULT ''::text NOT NULL,
    itemsrc_manuf_item_descrip text,
    itemsrc_default boolean,
    itemsrc_upccode text,
    itemsrc_effective date DEFAULT startoftime() NOT NULL,
    itemsrc_expires date DEFAULT endoftime() NOT NULL,
    itemsrc_contrct_id integer,
    itemsrc_contrct_max numeric(18,6) DEFAULT 0.0 NOT NULL,
    itemsrc_contrct_min numeric(18,6) DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.itemsrc OWNER TO admin;

--
-- TOC entry 9285 (class 0 OID 0)
-- Dependencies: 330
-- Name: TABLE itemsrc; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE itemsrc IS 'Item Source information';


--
-- TOC entry 9286 (class 0 OID 0)
-- Dependencies: 330
-- Name: COLUMN itemsrc.itemsrc_effective; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN itemsrc.itemsrc_effective IS 'Effective date for item source.  Constraint for overlap.';


--
-- TOC entry 9287 (class 0 OID 0)
-- Dependencies: 330
-- Name: COLUMN itemsrc.itemsrc_expires; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN itemsrc.itemsrc_expires IS 'Expiration date for item source.  Constraint for overlap.';


--
-- TOC entry 9288 (class 0 OID 0)
-- Dependencies: 330
-- Name: COLUMN itemsrc.itemsrc_contrct_id; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN itemsrc.itemsrc_contrct_id IS 'Associated contract for item source.  Inherits effective, expiration dates.';


--
-- TOC entry 332 (class 1259 OID 146567842)
-- Dependencies: 6201 6202 6203 6204 6205 8
-- Name: itemsrcp; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE itemsrcp (
    itemsrcp_id integer DEFAULT nextval(('itemsrcp_itemsrcp_id_seq'::text)::regclass) NOT NULL,
    itemsrcp_itemsrc_id integer NOT NULL,
    itemsrcp_qtybreak numeric(18,6) NOT NULL,
    itemsrcp_price numeric(16,6),
    itemsrcp_updated date,
    itemsrcp_curr_id integer DEFAULT basecurrid() NOT NULL,
    itemsrcp_dropship boolean DEFAULT false NOT NULL,
    itemsrcp_warehous_id integer DEFAULT (-1) NOT NULL,
    itemsrcp_type character(1) NOT NULL,
    itemsrcp_discntprcnt numeric(16,6),
    itemsrcp_fixedamtdiscount numeric(16,6),
    CONSTRAINT valid_itemsrcp_type CHECK ((itemsrcp_type = ANY (ARRAY['N'::bpchar, 'D'::bpchar])))
);


ALTER TABLE public.itemsrcp OWNER TO admin;

--
-- TOC entry 9292 (class 0 OID 0)
-- Dependencies: 332
-- Name: TABLE itemsrcp; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE itemsrcp IS 'Item Source Price information';


--
-- TOC entry 9293 (class 0 OID 0)
-- Dependencies: 332
-- Name: COLUMN itemsrcp.itemsrcp_dropship; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN itemsrcp.itemsrcp_dropship IS 'Used to determine if item source price applies only to drop ship purchase orders.';


--
-- TOC entry 9294 (class 0 OID 0)
-- Dependencies: 332
-- Name: COLUMN itemsrcp.itemsrcp_warehous_id; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN itemsrcp.itemsrcp_warehous_id IS 'Used to determine if item source price applies only to specific site on purchase orders.';


--
-- TOC entry 9295 (class 0 OID 0)
-- Dependencies: 332
-- Name: COLUMN itemsrcp.itemsrcp_type; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN itemsrcp.itemsrcp_type IS 'Pricing type for item source price.  Valid values are N-nominal and D-discount.';


--
-- TOC entry 9296 (class 0 OID 0)
-- Dependencies: 332
-- Name: COLUMN itemsrcp.itemsrcp_discntprcnt; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN itemsrcp.itemsrcp_discntprcnt IS 'Discount percent for item source price.';


--
-- TOC entry 9297 (class 0 OID 0)
-- Dependencies: 332
-- Name: COLUMN itemsrcp.itemsrcp_fixedamtdiscount; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN itemsrcp.itemsrcp_fixedamtdiscount IS 'Fixed amount discount for item source price.';


--
-- TOC entry 334 (class 1259 OID 146567855)
-- Dependencies: 6206 8
-- Name: itemsub; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE itemsub (
    itemsub_id integer DEFAULT nextval(('itemsub_itemsub_id_seq'::text)::regclass) NOT NULL,
    itemsub_parent_item_id integer NOT NULL,
    itemsub_sub_item_id integer NOT NULL,
    itemsub_uomratio numeric(20,10) NOT NULL,
    itemsub_rank integer NOT NULL
);


ALTER TABLE public.itemsub OWNER TO admin;

--
-- TOC entry 9301 (class 0 OID 0)
-- Dependencies: 334
-- Name: TABLE itemsub; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE itemsub IS 'Item Substitutes information';


--
-- TOC entry 336 (class 1259 OID 146567863)
-- Dependencies: 8
-- Name: itemtax; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE itemtax (
    itemtax_id integer NOT NULL,
    itemtax_item_id integer NOT NULL,
    itemtax_taxtype_id integer NOT NULL,
    itemtax_taxzone_id integer
);


ALTER TABLE public.itemtax OWNER TO admin;

--
-- TOC entry 9305 (class 0 OID 0)
-- Dependencies: 336
-- Name: TABLE itemtax; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE itemtax IS 'This table associates tax types in a specified tax authority for the given item.';


--
-- TOC entry 338 (class 1259 OID 146567870)
-- Dependencies: 6209 6210 8
-- Name: itemuomconv; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE itemuomconv (
    itemuomconv_id integer NOT NULL,
    itemuomconv_item_id integer NOT NULL,
    itemuomconv_from_uom_id integer NOT NULL,
    itemuomconv_from_value numeric(20,10) NOT NULL,
    itemuomconv_to_uom_id integer NOT NULL,
    itemuomconv_to_value numeric(20,10) NOT NULL,
    itemuomconv_fractional boolean DEFAULT false NOT NULL,
    CONSTRAINT itemuomconv_uom CHECK ((itemuomconv_from_uom_id <> itemuomconv_to_uom_id))
);


ALTER TABLE public.itemuomconv OWNER TO admin;


--
-- TOC entry 340 (class 1259 OID 146567879)
-- Dependencies: 6211 6212 6213 6214 8
-- Name: gltrans; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE gltrans (
    gltrans_id integer DEFAULT nextval(('"gltrans_gltrans_id_seq"'::text)::regclass) NOT NULL,
    gltrans_exported boolean,
    gltrans_created timestamp with time zone,
    gltrans_date date NOT NULL,
    gltrans_sequence integer,
    gltrans_accnt_id integer NOT NULL,
    gltrans_source text,
    gltrans_docnumber text,
    gltrans_misc_id integer,
    gltrans_amount numeric(20,2) NOT NULL,
    gltrans_notes text,
    gltrans_journalnumber integer,
    gltrans_posted boolean NOT NULL,
    gltrans_doctype text,
    gltrans_rec boolean DEFAULT false NOT NULL,
    gltrans_username text DEFAULT geteffectivextuser() NOT NULL,
    gltrans_deleted boolean DEFAULT false
);


ALTER TABLE public.gltrans OWNER TO admin;

--
-- TOC entry 9313 (class 0 OID 0)
-- Dependencies: 340
-- Name: TABLE gltrans; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE gltrans IS 'General Ledger (G/L) transaction information';


--
-- TOC entry 342 (class 1259 OID 146567894)
-- Dependencies: 6215 8
-- Name: location; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE location (
    location_id integer DEFAULT nextval(('location_location_id_seq'::text)::regclass) NOT NULL,
    location_warehous_id integer NOT NULL,
    location_name text NOT NULL,
    location_descrip text,
    location_restrict boolean,
    location_netable boolean,
    location_whsezone_id integer,
    location_aisle text,
    location_rack text,
    location_bin text
);


ALTER TABLE public.location OWNER TO admin;


--
-- TOC entry 343 (class 1259 OID 146567901)
-- Dependencies: 8
-- Name: whsezone; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE whsezone (
    whsezone_id integer NOT NULL,
    whsezone_warehous_id integer NOT NULL,
    whsezone_name text NOT NULL,
    whsezone_descrip text
);


ALTER TABLE public.whsezone OWNER TO admin;

--
-- TOC entry 9319 (class 0 OID 0)
-- Dependencies: 343
-- Name: TABLE whsezone; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE whsezone IS 'Warehouse Zone information';


--
-- TOC entry 347 (class 1259 OID 146567920)
-- Dependencies: 6218 8
-- Name: ipsass; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE ipsass (
    ipsass_id integer NOT NULL,
    ipsass_ipshead_id integer NOT NULL,
    ipsass_cust_id integer,
    ipsass_custtype_id integer,
    ipsass_custtype_pattern text,
    ipsass_shipto_id integer DEFAULT (-1),
    ipsass_shipto_pattern text
);


ALTER TABLE public.ipsass OWNER TO admin;


--
-- TOC entry 349 (class 1259 OID 146567932)
-- Dependencies: 6219 6220 6221 6222 8
-- Name: ipsiteminfo; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE ipsiteminfo (
    ipsitem_id integer DEFAULT nextval(('"ipsitem_ipsitem_id_seq"'::text)::regclass) NOT NULL,
    ipsitem_ipshead_id integer,
    ipsitem_item_id integer,
    ipsitem_qtybreak numeric(18,6) NOT NULL,
    ipsitem_price numeric(16,4) NOT NULL,
    ipsitem_qty_uom_id integer,
    ipsitem_price_uom_id integer,
    ipsitem_discntprcnt numeric(10,6) DEFAULT 0.00 NOT NULL,
    ipsitem_fixedamtdiscount numeric(16,4) DEFAULT 0.00 NOT NULL,
    ipsitem_prodcat_id integer,
    ipsitem_type character(1) NOT NULL,
    ipsitem_warehous_id integer,
    CONSTRAINT valid_ipsitem_type CHECK ((ipsitem_type = ANY (ARRAY['N'::bpchar, 'D'::bpchar, 'M'::bpchar])))
);


ALTER TABLE public.ipsiteminfo OWNER TO admin;

--
-- TOC entry 9331 (class 0 OID 0)
-- Dependencies: 349
-- Name: TABLE ipsiteminfo; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE ipsiteminfo IS 'Pricing Schedule Item information';


--
-- TOC entry 9332 (class 0 OID 0)
-- Dependencies: 349
-- Name: COLUMN ipsiteminfo.ipsitem_prodcat_id; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN ipsiteminfo.ipsitem_prodcat_id IS 'Product category for pricing schedule item.';


--
-- TOC entry 9333 (class 0 OID 0)
-- Dependencies: 349
-- Name: COLUMN ipsiteminfo.ipsitem_type; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN ipsiteminfo.ipsitem_type IS 'Pricing type for pricing schedule item.  Valid values are N-nominal, D-discount, and M-markup';


--
-- TOC entry 9334 (class 0 OID 0)
-- Dependencies: 349
-- Name: COLUMN ipsiteminfo.ipsitem_warehous_id; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN ipsiteminfo.ipsitem_warehous_id IS 'Site for pricing schedule item which enables pricing by site.';


--
-- TOC entry 351 (class 1259 OID 146567944)
-- Dependencies: 8
-- Name: ipsitemchar; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE ipsitemchar (
    ipsitemchar_id integer NOT NULL,
    ipsitemchar_ipsitem_id integer NOT NULL,
    ipsitemchar_char_id integer NOT NULL,
    ipsitemchar_value text NOT NULL,
    ipsitemchar_price numeric(16,4)
);


ALTER TABLE public.ipsitemchar OWNER TO admin;

--
-- TOC entry 9338 (class 0 OID 0)
-- Dependencies: 351
-- Name: TABLE ipsitemchar; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE ipsitemchar IS 'Item Price Schedule Characteristic Prices.';


--
-- TOC entry 355 (class 1259 OID 146567963)
-- Dependencies: 8
-- Name: cust_cust_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE cust_cust_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.cust_cust_id_seq OWNER TO admin;

--
-- TOC entry 356 (class 1259 OID 146567965)
-- Dependencies: 6224 6225 6226 6227 8
-- Name: prospect; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE prospect (
    prospect_id integer DEFAULT nextval('cust_cust_id_seq'::regclass) NOT NULL,
    prospect_active boolean DEFAULT true NOT NULL,
    prospect_number text NOT NULL,
    prospect_name text NOT NULL,
    prospect_cntct_id integer,
    prospect_comments text,
    prospect_created date DEFAULT ('now'::text)::date NOT NULL,
    prospect_salesrep_id integer,
    prospect_warehous_id integer,
    prospect_taxzone_id integer,
    CONSTRAINT prospect_prospect_number_check CHECK ((prospect_number <> ''::text))
);


ALTER TABLE public.prospect OWNER TO admin;


--
-- TOC entry 358 (class 1259 OID 146567980)
-- Dependencies: 6229 8
-- Name: expcat; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE expcat (
    expcat_id integer NOT NULL,
    expcat_code text NOT NULL,
    expcat_descrip text,
    expcat_exp_accnt_id integer,
    expcat_liability_accnt_id integer,
    expcat_active boolean,
    expcat_purchprice_accnt_id integer,
    expcat_freight_accnt_id integer,
    CONSTRAINT expcat_expcat_code_check CHECK ((expcat_code <> ''::text))
);


ALTER TABLE public.expcat OWNER TO admin;

--
-- TOC entry 9351 (class 0 OID 0)
-- Dependencies: 358
-- Name: TABLE expcat; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE expcat IS 'Expense Category information';


--
-- TOC entry 359 (class 1259 OID 146567987)
-- Dependencies: 6230 6231 6232 6233 6234 6235 8
-- Name: womatl; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE womatl (
    womatl_id integer DEFAULT nextval(('womatl_womatl_id_seq'::text)::regclass) NOT NULL,
    womatl_wo_id integer,
    womatl_itemsite_id integer,
    womatl_qtyper numeric(20,8) NOT NULL,
    womatl_scrap numeric(8,4) NOT NULL,
    womatl_qtyreq numeric(18,6) NOT NULL,
    womatl_qtyiss numeric(18,6) NOT NULL,
    womatl_qtywipscrap numeric(18,6) NOT NULL,
    womatl_lastissue date,
    womatl_lastreturn date,
    womatl_cost numeric(16,6),
    womatl_picklist boolean,
    womatl_status character(1),
    womatl_imported boolean DEFAULT false,
    womatl_createwo boolean,
    womatl_issuemethod character(1),
    womatl_wooper_id integer,
    womatl_bomitem_id integer,
    womatl_duedate date,
    womatl_schedatwooper boolean,
    womatl_uom_id integer NOT NULL,
    womatl_notes text,
    womatl_ref text,
    womatl_scrapvalue numeric(16,6) DEFAULT 0,
    womatl_qtyfxd numeric(20,8) DEFAULT 0 NOT NULL,
    womatl_issuewo boolean DEFAULT false NOT NULL,
    womatl_price numeric(16,6) DEFAULT 0 NOT NULL
);


ALTER TABLE public.womatl OWNER TO admin;

--
-- TOC entry 9353 (class 0 OID 0)
-- Dependencies: 359
-- Name: TABLE womatl; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE womatl IS 'Work Order Material Requirements information';


--
-- TOC entry 9354 (class 0 OID 0)
-- Dependencies: 359
-- Name: COLUMN womatl.womatl_qtyfxd; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN womatl.womatl_qtyfxd IS 'The fixed quantity required';


--
-- TOC entry 363 (class 1259 OID 146568014)
-- Dependencies: 6236 6237 8
-- Name: tax; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE tax (
    tax_id integer DEFAULT nextval(('"tax_tax_id_seq"'::text)::regclass) NOT NULL,
    tax_code text NOT NULL,
    tax_descrip text,
    tax_sales_accnt_id integer,
    tax_taxclass_id integer,
    tax_taxauth_id integer,
    tax_basis_tax_id integer,
    CONSTRAINT tax_tax_code_check CHECK ((tax_code <> ''::text))
);


ALTER TABLE public.tax OWNER TO admin;


--
-- TOC entry 364 (class 1259 OID 146568022)
-- Dependencies: 6238 8
-- Name: vendaddrinfo; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE vendaddrinfo (
    vendaddr_id integer DEFAULT nextval(('vendaddr_vendaddr_id_seq'::text)::regclass) NOT NULL,
    vendaddr_vend_id integer,
    vendaddr_code text,
    vendaddr_name text,
    vendaddr_comments text,
    vendaddr_cntct_id integer,
    vendaddr_addr_id integer,
    vendaddr_taxzone_id integer
);


ALTER TABLE public.vendaddrinfo OWNER TO admin;

--
-- TOC entry 9365 (class 0 OID 0)
-- Dependencies: 364
-- Name: TABLE vendaddrinfo; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE vendaddrinfo IS 'Vendor Address information';


--
-- TOC entry 367 (class 1259 OID 146568038)
-- Dependencies: 6239 6240 6241 6242 6243 6244 6245 6246 8
-- Name: quhead; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE quhead (
    quhead_id integer DEFAULT nextval(('"quhead_quhead_id_seq"'::text)::regclass) NOT NULL,
    quhead_number text NOT NULL,
    quhead_cust_id integer NOT NULL,
    quhead_quotedate date,
    quhead_shipto_id integer,
    quhead_shiptoname text,
    quhead_shiptoaddress1 text,
    quhead_shiptoaddress2 text,
    quhead_shiptoaddress3 text,
    quhead_shiptocity text,
    quhead_shiptostate text,
    quhead_shiptozipcode text,
    quhead_shiptophone text,
    quhead_salesrep_id integer,
    quhead_terms_id integer,
    quhead_freight numeric(16,4),
    quhead_ordercomments text,
    quhead_shipcomments text,
    quhead_billtoname text,
    quhead_billtoaddress1 text,
    quhead_billtoaddress2 text,
    quhead_billtoaddress3 text,
    quhead_billtocity text,
    quhead_billtostate text,
    quhead_billtozip text,
    quhead_commission numeric(16,4),
    quhead_custponumber text,
    quhead_fob text,
    quhead_shipvia text,
    quhead_warehous_id integer,
    quhead_packdate date,
    quhead_prj_id integer,
    quhead_misc numeric(16,4) DEFAULT 0 NOT NULL,
    quhead_misc_accnt_id integer,
    quhead_misc_descrip text,
    quhead_billtocountry text,
    quhead_shiptocountry text,
    quhead_curr_id integer DEFAULT basecurrid(),
    quhead_imported boolean DEFAULT false,
    quhead_expire date,
    quhead_calcfreight boolean DEFAULT false NOT NULL,
    quhead_shipto_cntct_id integer,
    quhead_shipto_cntct_honorific text,
    quhead_shipto_cntct_first_name text,
    quhead_shipto_cntct_middle text,
    quhead_shipto_cntct_last_name text,
    quhead_shipto_cntct_suffix text,
    quhead_shipto_cntct_phone text,
    quhead_shipto_cntct_title text,
    quhead_shipto_cntct_fax text,
    quhead_shipto_cntct_email text,
    quhead_billto_cntct_id integer,
    quhead_billto_cntct_honorific text,
    quhead_billto_cntct_first_name text,
    quhead_billto_cntct_middle text,
    quhead_billto_cntct_last_name text,
    quhead_billto_cntct_suffix text,
    quhead_billto_cntct_phone text,
    quhead_billto_cntct_title text,
    quhead_billto_cntct_fax text,
    quhead_billto_cntct_email text,
    quhead_taxzone_id integer,
    quhead_taxtype_id integer,
    quhead_ophead_id integer,
    quhead_status text,
    quhead_saletype_id integer,
    quhead_shipzone_id integer,
    CONSTRAINT quhead_check CHECK ((((quhead_misc = (0)::numeric) AND (quhead_misc_accnt_id IS NULL)) OR ((quhead_misc <> (0)::numeric) AND (quhead_misc_accnt_id IS NOT NULL)))),
    CONSTRAINT quhead_quhead_number_check CHECK ((quhead_number <> ''::text)),
    CONSTRAINT quhead_quhead_status_check CHECK ((((quhead_status = 'O'::text) OR (quhead_status = 'C'::text)) OR (quhead_status = 'X'::text)))
);


ALTER TABLE public.quhead OWNER TO admin;


--
-- TOC entry 370 (class 1259 OID 146568061)
-- Dependencies: 6247 6248 6249 6250 6251 8
-- Name: quitem; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE quitem (
    quitem_id integer DEFAULT nextval(('"quitem_quitem_id_seq"'::text)::regclass) NOT NULL,
    quitem_quhead_id integer,
    quitem_linenumber integer,
    quitem_itemsite_id integer,
    quitem_scheddate date,
    quitem_qtyord numeric(18,6),
    quitem_unitcost numeric(16,6),
    quitem_price numeric(16,4),
    quitem_custprice numeric(16,4),
    quitem_memo text,
    quitem_custpn text,
    quitem_createorder boolean,
    quitem_order_warehous_id integer,
    quitem_item_id integer,
    quitem_prcost numeric(16,6),
    quitem_imported boolean DEFAULT false,
    quitem_qty_uom_id integer NOT NULL,
    quitem_qty_invuomratio numeric(20,10) NOT NULL,
    quitem_price_uom_id integer NOT NULL,
    quitem_price_invuomratio numeric(20,10) NOT NULL,
    quitem_promdate date,
    quitem_taxtype_id integer,
    quitem_dropship boolean DEFAULT false,
    quitem_itemsrc_id integer,
    quitem_pricemode character(1) DEFAULT 'D'::bpchar NOT NULL,
    CONSTRAINT valid_quitem_pricemode CHECK ((quitem_pricemode = ANY (ARRAY['D'::bpchar, 'M'::bpchar])))
);


ALTER TABLE public.quitem OWNER TO admin;


--
-- TOC entry 374 (class 1259 OID 146568087)
-- Dependencies: 6252 6253 8
-- Name: aropenalloc; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE aropenalloc (
    aropenalloc_aropen_id integer NOT NULL,
    aropenalloc_doctype character(1) NOT NULL,
    aropenalloc_doc_id integer NOT NULL,
    aropenalloc_amount numeric(20,2) DEFAULT 0.00 NOT NULL,
    aropenalloc_curr_id integer DEFAULT basecurrid()
);


ALTER TABLE public.aropenalloc OWNER TO admin;

--
-- TOC entry 376 (class 1259 OID 146568097)
-- Dependencies: 6254 6255 6256 8
-- Name: cohist; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE cohist (
    cohist_id integer DEFAULT nextval(('cohist_cohist_id_seq'::text)::regclass) NOT NULL,
    cohist_cust_id integer,
    cohist_itemsite_id integer,
    cohist_shipdate date,
    cohist_shipvia text,
    cohist_ordernumber text,
    cohist_orderdate date,
    cohist_invcnumber text,
    cohist_invcdate date,
    cohist_qtyshipped numeric(18,6),
    cohist_unitprice numeric(16,4),
    cohist_shipto_id integer,
    cohist_salesrep_id integer,
    cohist_duedate date,
    cohist_imported boolean DEFAULT false,
    cohist_billtoname text,
    cohist_billtoaddress1 text,
    cohist_billtoaddress2 text,
    cohist_billtoaddress3 text,
    cohist_billtocity text,
    cohist_billtostate text,
    cohist_billtozip text,
    cohist_shiptoname text,
    cohist_shiptoaddress1 text,
    cohist_shiptoaddress2 text,
    cohist_shiptoaddress3 text,
    cohist_shiptocity text,
    cohist_shiptostate text,
    cohist_shiptozip text,
    cohist_commission numeric(16,4),
    cohist_commissionpaid boolean,
    cohist_unitcost numeric(18,6),
    cohist_misc_type character(1),
    cohist_misc_descrip text,
    cohist_misc_id integer,
    cohist_doctype text,
    cohist_promisedate date,
    cohist_ponumber text,
    cohist_curr_id integer DEFAULT basecurrid(),
    cohist_sequence integer,
    cohist_taxtype_id integer,
    cohist_taxzone_id integer,
    cohist_cohead_ccpay_id integer,
    cohist_saletype_id integer,
    cohist_shipzone_id integer
);


ALTER TABLE public.cohist OWNER TO admin;

--
-- TOC entry 377 (class 1259 OID 146568106)
-- Dependencies: 8
-- Name: taxhist; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE taxhist (
    taxhist_id integer NOT NULL,
    taxhist_parent_id integer NOT NULL,
    taxhist_taxtype_id integer,
    taxhist_tax_id integer NOT NULL,
    taxhist_basis numeric(16,2) NOT NULL,
    taxhist_basis_tax_id integer,
    taxhist_sequence integer,
    taxhist_percent numeric(10,6) NOT NULL,
    taxhist_amount numeric(16,2) NOT NULL,
    taxhist_tax numeric(16,6) NOT NULL,
    taxhist_docdate date NOT NULL,
    taxhist_distdate date,
    taxhist_curr_id integer,
    taxhist_curr_rate numeric,
    taxhist_journalnumber integer
);


ALTER TABLE public.taxhist OWNER TO admin;


--
-- TOC entry 379 (class 1259 OID 146568114)
-- Dependencies: 377 8
-- Name: cohisttax; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE cohisttax (
)
INHERITS (taxhist);


ALTER TABLE public.cohisttax OWNER TO admin;

--
-- TOC entry 386 (class 1259 OID 146568150)
-- Dependencies: 6259 6260 8
-- Name: shipvia; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE shipvia (
    shipvia_id integer DEFAULT nextval(('shipvia_shipvia_id_seq'::text)::regclass) NOT NULL,
    shipvia_code text NOT NULL,
    shipvia_descrip text,
    CONSTRAINT shipvia_shipvia_code_check CHECK ((shipvia_code <> ''::text))
);


ALTER TABLE public.shipvia OWNER TO admin;

--
-- TOC entry 9421 (class 0 OID 0)
-- Dependencies: 386
-- Name: TABLE shipvia; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE shipvia IS 'Ship Via information';


--
-- TOC entry 387 (class 1259 OID 146568158)
-- Dependencies: 6262 8
-- Name: sitetype; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE sitetype (
    sitetype_id integer NOT NULL,
    sitetype_name text NOT NULL,
    sitetype_descrip text,
    CONSTRAINT sitetype_sitetype_name_check CHECK ((sitetype_name <> ''::text))
);


ALTER TABLE public.sitetype OWNER TO admin;

--
-- TOC entry 9423 (class 0 OID 0)
-- Dependencies: 387
-- Name: TABLE sitetype; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE sitetype IS 'This table is the different types of sites.';


--
-- TOC entry 393 (class 1259 OID 146568189)
-- Dependencies: 6264 8
-- Name: vendtype; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE vendtype (
    vendtype_id integer NOT NULL,
    vendtype_code text NOT NULL,
    vendtype_descrip text,
    CONSTRAINT vendtype_vendtype_code_check CHECK ((vendtype_code <> ''::text))
);


ALTER TABLE public.vendtype OWNER TO admin;

--
-- TOC entry 9435 (class 0 OID 0)
-- Dependencies: 393
-- Name: TABLE vendtype; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE vendtype IS 'Vendor Type information';


--
-- TOC entry 397 (class 1259 OID 146568210)
-- Dependencies: 8
-- Name: cmd; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE cmd (
    cmd_id integer NOT NULL,
    cmd_module text NOT NULL,
    cmd_title text NOT NULL,
    cmd_descrip text,
    cmd_privname text,
    cmd_executable text NOT NULL,
    cmd_name text
);


ALTER TABLE public.cmd OWNER TO admin;

--
-- TOC entry 9443 (class 0 OID 0)
-- Dependencies: 397
-- Name: TABLE cmd; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE cmd IS 'Custom menu command table.';


--
-- TOC entry 398 (class 1259 OID 146568216)
-- Dependencies: 397 8
-- Name: cmd_cmd_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE cmd_cmd_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.cmd_cmd_id_seq OWNER TO admin;

--
-- TOC entry 9445 (class 0 OID 0)
-- Dependencies: 398
-- Name: cmd_cmd_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE cmd_cmd_id_seq OWNED BY cmd.cmd_id;


--
-- TOC entry 400 (class 1259 OID 146568226)
-- Dependencies: 8
-- Name: cmdarg; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE cmdarg (
    cmdarg_id integer NOT NULL,
    cmdarg_cmd_id integer NOT NULL,
    cmdarg_order integer NOT NULL,
    cmdarg_arg text NOT NULL
);


ALTER TABLE public.cmdarg OWNER TO admin;

--
-- TOC entry 9448 (class 0 OID 0)
-- Dependencies: 400
-- Name: TABLE cmdarg; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE cmdarg IS 'Command argument for custom menu command table.';


--
-- TOC entry 401 (class 1259 OID 146568232)
-- Dependencies: 400 8
-- Name: cmdarg_cmdarg_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE cmdarg_cmdarg_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.cmdarg_cmdarg_id_seq OWNER TO admin;

--
-- TOC entry 9450 (class 0 OID 0)
-- Dependencies: 401
-- Name: cmdarg_cmdarg_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE cmdarg_cmdarg_id_seq OWNED BY cmdarg.cmdarg_id;


--
-- TOC entry 403 (class 1259 OID 146568242)
-- Dependencies: 8
-- Name: image_image_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE image_image_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.image_image_id_seq OWNER TO admin;

--
-- TOC entry 405 (class 1259 OID 146568251)
-- Dependencies: 6271 8
-- Name: metasql; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE metasql (
    metasql_id integer NOT NULL,
    metasql_group text,
    metasql_name text,
    metasql_notes text,
    metasql_query text,
    metasql_lastuser text,
    metasql_lastupdate date,
    metasql_grade integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.metasql OWNER TO admin;

--
-- TOC entry 9455 (class 0 OID 0)
-- Dependencies: 405
-- Name: TABLE metasql; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE metasql IS 'MetaSQL Table';


--
-- TOC entry 406 (class 1259 OID 146568258)
-- Dependencies: 405 8
-- Name: metasql_metasql_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE metasql_metasql_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.metasql_metasql_id_seq OWNER TO admin;

--
-- TOC entry 9457 (class 0 OID 0)
-- Dependencies: 406
-- Name: metasql_metasql_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE metasql_metasql_id_seq OWNED BY metasql.metasql_id;

--
-- TOC entry 408 (class 1259 OID 146568269)
-- Dependencies: 6274 8
-- Name: priv; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE priv (
    priv_id integer DEFAULT nextval(('priv_priv_id_seq'::text)::regclass) NOT NULL,
    priv_module text,
    priv_name text,
    priv_descrip text,
    priv_seq integer
);


ALTER TABLE public.priv OWNER TO admin;


--
-- TOC entry 409 (class 1259 OID 146568276)
-- Dependencies: 8
-- Name: priv_priv_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE priv_priv_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.priv_priv_id_seq OWNER TO admin;

--
-- TOC entry 411 (class 1259 OID 146568285)
-- Dependencies: 6276 8
-- Name: report; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE report (
    report_id integer DEFAULT nextval(('report_report_id_seq'::text)::regclass) NOT NULL,
    report_name text,
    report_sys boolean,
    report_source text,
    report_descrip text,
    report_grade integer NOT NULL,
    report_loaddate timestamp without time zone
);


ALTER TABLE public.report OWNER TO admin;

--
-- TOC entry 9464 (class 0 OID 0)
-- Dependencies: 411
-- Name: TABLE report; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE report IS 'Report definition information';


--
-- TOC entry 412 (class 1259 OID 146568292)
-- Dependencies: 8
-- Name: report_report_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE report_report_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.report_report_id_seq OWNER TO admin;

--
-- TOC entry 414 (class 1259 OID 146568301)
-- Dependencies: 6279 8
-- Name: script; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE script (
    script_id integer NOT NULL,
    script_name text NOT NULL,
    script_order integer NOT NULL,
    script_enabled boolean DEFAULT false NOT NULL,
    script_source text NOT NULL,
    script_notes text
);


ALTER TABLE public.script OWNER TO admin;

--
-- TOC entry 415 (class 1259 OID 146568308)
-- Dependencies: 414 8
-- Name: script_script_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE script_script_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.script_script_id_seq OWNER TO admin;

--
-- TOC entry 9469 (class 0 OID 0)
-- Dependencies: 415
-- Name: script_script_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE script_script_id_seq OWNED BY script.script_id;

--
-- TOC entry 417 (class 1259 OID 146568319)
-- Dependencies: 6283 8
-- Name: uiform; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE uiform (
    uiform_id integer NOT NULL,
    uiform_name text NOT NULL,
    uiform_order integer NOT NULL,
    uiform_enabled boolean DEFAULT false NOT NULL,
    uiform_source text NOT NULL,
    uiform_notes text
);


ALTER TABLE public.uiform OWNER TO admin;

--
-- TOC entry 418 (class 1259 OID 146568326)
-- Dependencies: 417 8
-- Name: uiform_uiform_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE uiform_uiform_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.uiform_uiform_id_seq OWNER TO admin;

--
-- TOC entry 9473 (class 0 OID 0)
-- Dependencies: 418
-- Name: uiform_uiform_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE uiform_uiform_id_seq OWNED BY uiform.uiform_id;


--
-- TOC entry 420 (class 1259 OID 146568337)
-- Dependencies: 6286 8
-- Name: acalitem; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE acalitem (
    acalitem_id integer DEFAULT nextval(('"xcalitem_xcalitem_id_seq"'::text)::regclass) NOT NULL,
    acalitem_calhead_id integer,
    acalitem_periodstart date,
    acalitem_periodlength integer,
    acalitem_name text
);


ALTER TABLE public.acalitem OWNER TO admin;

--
-- TOC entry 9476 (class 0 OID 0)
-- Dependencies: 420
-- Name: TABLE acalitem; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE acalitem IS 'Absolute Calendar Item information';


--
-- TOC entry 421 (class 1259 OID 146568344)
-- Dependencies: 8
-- Name: accnt_accnt_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE accnt_accnt_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.accnt_accnt_id_seq OWNER TO admin;

--
-- TOC entry 422 (class 1259 OID 146568346)
-- Dependencies: 234 8
-- Name: addr_addr_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE addr_addr_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.addr_addr_id_seq OWNER TO admin;

--
-- TOC entry 9479 (class 0 OID 0)
-- Dependencies: 422
-- Name: addr_addr_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE addr_addr_id_seq OWNED BY addr.addr_id;


--
-- TOC entry 424 (class 1259 OID 146568353)
-- Dependencies: 6287 6288 6289 8
-- Name: alarm; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE alarm (
    alarm_id integer NOT NULL,
    alarm_number text NOT NULL,
    alarm_event boolean DEFAULT false NOT NULL,
    alarm_email boolean DEFAULT false NOT NULL,
    alarm_sysmsg boolean DEFAULT false NOT NULL,
    alarm_trigger timestamp with time zone,
    alarm_time timestamp with time zone,
    alarm_time_offset integer,
    alarm_time_qualifier text,
    alarm_creator text,
    alarm_event_recipient text,
    alarm_email_recipient text,
    alarm_sysmsg_recipient text,
    alarm_source text,
    alarm_source_id integer
);


ALTER TABLE public.alarm OWNER TO admin;

--
-- TOC entry 9482 (class 0 OID 0)
-- Dependencies: 424
-- Name: TABLE alarm; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE alarm IS 'This table is the open alarms.';


--
-- TOC entry 425 (class 1259 OID 146568362)
-- Dependencies: 424 8
-- Name: alarm_alarm_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE alarm_alarm_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.alarm_alarm_id_seq OWNER TO admin;

--
-- TOC entry 9484 (class 0 OID 0)
-- Dependencies: 425
-- Name: alarm_alarm_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE alarm_alarm_id_seq OWNED BY alarm.alarm_id;


--
-- TOC entry 426 (class 1259 OID 146568364)
-- Dependencies: 8
-- Name: apaccnt; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE apaccnt (
    apaccnt_id integer NOT NULL,
    apaccnt_vendtype_id integer,
    apaccnt_vendtype text,
    apaccnt_ap_accnt_id integer NOT NULL,
    apaccnt_prepaid_accnt_id integer,
    apaccnt_discount_accnt_id integer
);


ALTER TABLE public.apaccnt OWNER TO admin;

--
-- TOC entry 9486 (class 0 OID 0)
-- Dependencies: 426
-- Name: TABLE apaccnt; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE apaccnt IS 'Accounts Payable (A/P) Account assignment information';


--
-- TOC entry 427 (class 1259 OID 146568370)
-- Dependencies: 426 8
-- Name: apaccnt_apaccnt_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE apaccnt_apaccnt_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.apaccnt_apaccnt_id_seq OWNER TO admin;

--
-- TOC entry 9488 (class 0 OID 0)
-- Dependencies: 427
-- Name: apaccnt_apaccnt_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE apaccnt_apaccnt_id_seq OWNED BY apaccnt.apaccnt_id;


--
-- TOC entry 428 (class 1259 OID 146568372)
-- Dependencies: 6293 8
-- Name: apapply; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE apapply (
    apapply_id integer NOT NULL,
    apapply_vend_id integer,
    apapply_postdate date,
    apapply_username text,
    apapply_source_apopen_id integer,
    apapply_source_doctype text,
    apapply_source_docnumber text,
    apapply_target_apopen_id integer,
    apapply_target_doctype text,
    apapply_target_docnumber text,
    apapply_journalnumber integer,
    apapply_amount numeric(20,2),
    apapply_curr_id integer DEFAULT basecurrid(),
    apapply_target_paid numeric(20,2),
    apapply_checkhead_id integer
);


ALTER TABLE public.apapply OWNER TO admin;


--
-- TOC entry 429 (class 1259 OID 146568379)
-- Dependencies: 428 8
-- Name: apapply_apapply_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE apapply_apapply_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.apapply_apapply_id_seq OWNER TO admin;

--
-- TOC entry 9493 (class 0 OID 0)
-- Dependencies: 429
-- Name: apapply_apapply_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE apapply_apapply_id_seq OWNED BY apapply.apapply_id;


--
-- TOC entry 430 (class 1259 OID 146568381)
-- Dependencies: 6294 6295 6296 6297 6298 6299 6300 6301 6303 6304 8
-- Name: checkhead; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE checkhead (
    checkhead_id integer NOT NULL,
    checkhead_recip_id integer NOT NULL,
    checkhead_recip_type text NOT NULL,
    checkhead_bankaccnt_id integer NOT NULL,
    checkhead_printed boolean DEFAULT false NOT NULL,
    checkhead_checkdate date NOT NULL,
    checkhead_number integer NOT NULL,
    checkhead_amount numeric(20,2) NOT NULL,
    checkhead_void boolean DEFAULT false NOT NULL,
    checkhead_replaced boolean DEFAULT false NOT NULL,
    checkhead_posted boolean DEFAULT false NOT NULL,
    checkhead_rec boolean DEFAULT false NOT NULL,
    checkhead_misc boolean DEFAULT false NOT NULL,
    checkhead_expcat_id integer,
    checkhead_for text NOT NULL,
    checkhead_notes text NOT NULL,
    checkhead_journalnumber integer,
    checkhead_curr_id integer DEFAULT basecurrid() NOT NULL,
    checkhead_deleted boolean DEFAULT false NOT NULL,
    checkhead_ach_batch text,
    checkhead_curr_rate numeric NOT NULL,
    CONSTRAINT checkhead_checkhead_amount_check CHECK ((checkhead_amount > (0)::numeric)),
    CONSTRAINT checkhead_checkhead_recip_type_check CHECK ((((checkhead_recip_type = 'C'::text) OR (checkhead_recip_type = 'V'::text)) OR (checkhead_recip_type = 'T'::text)))
);


ALTER TABLE public.checkhead OWNER TO admin;


--
-- TOC entry 432 (class 1259 OID 146568401)
-- Dependencies: 6305 6306 6307 6309 8
-- Name: checkitem; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE checkitem (
    checkitem_id integer NOT NULL,
    checkitem_checkhead_id integer NOT NULL,
    checkitem_amount numeric(20,2) DEFAULT 0.0 NOT NULL,
    checkitem_discount numeric(20,2) DEFAULT 0.0 NOT NULL,
    checkitem_ponumber text,
    checkitem_vouchernumber text,
    checkitem_invcnumber text,
    checkitem_apopen_id integer,
    checkitem_aropen_id integer,
    checkitem_docdate date,
    checkitem_curr_id integer DEFAULT basecurrid() NOT NULL,
    checkitem_cmnumber text,
    checkitem_ranumber text,
    checkitem_curr_rate numeric,
    CONSTRAINT checkitem_check CHECK ((NOT ((checkitem_apopen_id IS NOT NULL) AND (checkitem_aropen_id IS NOT NULL))))
);


ALTER TABLE public.checkitem OWNER TO admin;

--
-- TOC entry 9498 (class 0 OID 0)
-- Dependencies: 432
-- Name: TABLE checkitem; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE checkitem IS 'Accounts Payable Check Line Item Information';


--
-- TOC entry 434 (class 1259 OID 146568415)
-- Dependencies: 6311 8
-- Name: apcreditapply; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE apcreditapply (
    apcreditapply_id integer NOT NULL,
    apcreditapply_source_apopen_id integer,
    apcreditapply_target_apopen_id integer,
    apcreditapply_amount numeric(20,2),
    apcreditapply_curr_id integer DEFAULT basecurrid()
);


ALTER TABLE public.apcreditapply OWNER TO admin;

--
-- TOC entry 9501 (class 0 OID 0)
-- Dependencies: 434
-- Name: TABLE apcreditapply; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE apcreditapply IS 'Temporary table for storing details of Accounts Payable (A/P) Credit Memo applications before those applications are posted';


--
-- TOC entry 435 (class 1259 OID 146568419)
-- Dependencies: 434 8
-- Name: apcreditapply_apcreditapply_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE apcreditapply_apcreditapply_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.apcreditapply_apcreditapply_id_seq OWNER TO admin;

--
-- TOC entry 9503 (class 0 OID 0)
-- Dependencies: 435
-- Name: apcreditapply_apcreditapply_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE apcreditapply_apcreditapply_id_seq OWNED BY apcreditapply.apcreditapply_id;


--
-- TOC entry 437 (class 1259 OID 146568425)
-- Dependencies: 8
-- Name: apopen_apopen_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE apopen_apopen_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.apopen_apopen_id_seq OWNER TO admin;

--
-- TOC entry 438 (class 1259 OID 146568427)
-- Dependencies: 377 8
-- Name: apopentax; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE apopentax (
)
INHERITS (taxhist);


ALTER TABLE public.apopentax OWNER TO admin;

--
-- TOC entry 439 (class 1259 OID 146568433)
-- Dependencies: 6314 6315 8
-- Name: apselect; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE apselect (
    apselect_id integer NOT NULL,
    apselect_apopen_id integer NOT NULL,
    apselect_amount numeric(20,2) NOT NULL,
    apselect_bankaccnt_id integer,
    apselect_curr_id integer DEFAULT basecurrid(),
    apselect_date date,
    apselect_discount numeric(20,2) DEFAULT 0.0 NOT NULL
);


ALTER TABLE public.apselect OWNER TO admin;

--
-- TOC entry 9508 (class 0 OID 0)
-- Dependencies: 439
-- Name: TABLE apselect; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE apselect IS 'Temporary table for storing details of Accounts Payable (A/P) Payment selections';


--
-- TOC entry 440 (class 1259 OID 146568438)
-- Dependencies: 439 8
-- Name: apselect_apselect_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE apselect_apselect_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.apselect_apselect_id_seq OWNER TO admin;

--
-- TOC entry 9510 (class 0 OID 0)
-- Dependencies: 440
-- Name: apselect_apselect_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE apselect_apselect_id_seq OWNED BY apselect.apselect_id;


--
-- TOC entry 441 (class 1259 OID 146568440)
-- Dependencies: 6316 8
-- Name: araccnt; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE araccnt (
    araccnt_id integer DEFAULT nextval(('araccnt_araccnt_id_seq'::text)::regclass) NOT NULL,
    araccnt_custtype_id integer,
    araccnt_custtype text,
    araccnt_freight_accnt_id integer,
    araccnt_ar_accnt_id integer,
    araccnt_prepaid_accnt_id integer,
    araccnt_deferred_accnt_id integer,
    araccnt_discount_accnt_id integer
);


ALTER TABLE public.araccnt OWNER TO admin;

--
-- TOC entry 9512 (class 0 OID 0)
-- Dependencies: 441
-- Name: TABLE araccnt; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE araccnt IS 'Accounts Receivable (A/R) Account assignment information';


--
-- TOC entry 442 (class 1259 OID 146568447)
-- Dependencies: 8
-- Name: araccnt_araccnt_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE araccnt_araccnt_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.araccnt_araccnt_id_seq OWNER TO admin;

--
-- TOC entry 443 (class 1259 OID 146568449)
-- Dependencies: 6318 8
-- Name: arapply; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE arapply (
    arapply_id integer NOT NULL,
    arapply_postdate date,
    arapply_cust_id integer,
    arapply_source_doctype text,
    arapply_source_docnumber text,
    arapply_target_doctype text,
    arapply_target_docnumber text,
    arapply_fundstype text,
    arapply_refnumber text,
    arapply_applied numeric(20,2),
    arapply_closed boolean,
    arapply_journalnumber text,
    arapply_source_aropen_id integer,
    arapply_target_aropen_id integer,
    arapply_username text,
    arapply_curr_id integer DEFAULT basecurrid(),
    arapply_distdate date NOT NULL,
    arapply_target_paid numeric(20,2),
    arapply_reftype text,
    arapply_ref_id integer
);


ALTER TABLE public.arapply OWNER TO admin;


--
-- TOC entry 444 (class 1259 OID 146568456)
-- Dependencies: 443 8
-- Name: arapply_arapply_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE arapply_arapply_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.arapply_arapply_id_seq OWNER TO admin;

--
-- TOC entry 9517 (class 0 OID 0)
-- Dependencies: 444
-- Name: arapply_arapply_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE arapply_arapply_id_seq OWNED BY arapply.arapply_id;


--
-- TOC entry 445 (class 1259 OID 146568458)
-- Dependencies: 269 8
-- Name: cashrcptitem_cashrcptitem_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE cashrcptitem_cashrcptitem_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.cashrcptitem_cashrcptitem_id_seq OWNER TO admin;

--
-- TOC entry 9519 (class 0 OID 0)
-- Dependencies: 445
-- Name: cashrcptitem_cashrcptitem_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE cashrcptitem_cashrcptitem_id_seq OWNED BY cashrcptitem.cashrcptitem_id;


--
-- TOC entry 446 (class 1259 OID 146568460)
-- Dependencies: 6319 6320 8
-- Name: arcreditapply; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE arcreditapply (
    arcreditapply_id integer DEFAULT nextval('cashrcptitem_cashrcptitem_id_seq'::regclass) NOT NULL,
    arcreditapply_source_aropen_id integer,
    arcreditapply_target_aropen_id integer,
    arcreditapply_amount numeric(20,2),
    arcreditapply_curr_id integer DEFAULT basecurrid(),
    arcreditapply_reftype text,
    arcreditapply_ref_id integer
);


ALTER TABLE public.arcreditapply OWNER TO admin;

--
-- TOC entry 9521 (class 0 OID 0)
-- Dependencies: 446
-- Name: TABLE arcreditapply; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE arcreditapply IS 'Temporary table for storing details of Accounts Receivable (A/R) Credit Memo applications before those applications are posted';


--
-- TOC entry 447 (class 1259 OID 146568468)
-- Dependencies: 446 8
-- Name: arcreditapply_arcreditapply_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE arcreditapply_arcreditapply_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.arcreditapply_arcreditapply_id_seq OWNER TO admin;

--
-- TOC entry 9523 (class 0 OID 0)
-- Dependencies: 447
-- Name: arcreditapply_arcreditapply_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE arcreditapply_arcreditapply_id_seq OWNED BY arcreditapply.arcreditapply_id;


--
-- TOC entry 449 (class 1259 OID 146568474)
-- Dependencies: 8
-- Name: aropen_aropen_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE aropen_aropen_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.aropen_aropen_id_seq OWNER TO admin;

--
-- TOC entry 450 (class 1259 OID 146568476)
-- Dependencies: 377 8
-- Name: aropentax; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE aropentax (
)
INHERITS (taxhist);


ALTER TABLE public.aropentax OWNER TO admin;

--
-- TOC entry 451 (class 1259 OID 146568482)
-- Dependencies: 6323 8
-- Name: asohist; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE asohist (
    asohist_id integer NOT NULL,
    asohist_cust_id integer,
    asohist_itemsite_id integer,
    asohist_shipdate date,
    asohist_invcdate date,
    asohist_duedate date,
    asohist_promisedate date,
    asohist_ordernumber text,
    asohist_invcnumber text,
    asohist_qtyshipped numeric(18,6),
    asohist_unitprice numeric(16,4),
    asohist_unitcost numeric(16,6),
    asohist_billtoname text,
    asohist_billtoaddress1 text,
    asohist_billtoaddress2 text,
    asohist_billtoaddress3 text,
    asohist_billtocity text,
    asohist_billtostate text,
    asohist_billtozip text,
    asohist_shiptoname text,
    asohist_shiptoaddress1 text,
    asohist_shiptoaddress2 text,
    asohist_shiptoaddress3 text,
    asohist_shiptocity text,
    asohist_shiptostate text,
    asohist_shiptozip text,
    asohist_shipto_id integer,
    asohist_shipvia text,
    asohist_salesrep_id integer,
    asohist_misc_type character(1),
    asohist_misc_descrip text,
    asohist_misc_id integer,
    asohist_commission numeric(16,4),
    asohist_commissionpaid boolean,
    asohist_doctype text,
    asohist_orderdate date,
    asohist_imported boolean,
    asohist_ponumber text,
    asohist_curr_id integer DEFAULT basecurrid(),
    asohist_taxtype_id integer,
    asohist_taxzone_id integer
);


ALTER TABLE public.asohist OWNER TO admin;


--
-- TOC entry 452 (class 1259 OID 146568489)
-- Dependencies: 451 8
-- Name: asohist_asohist_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE asohist_asohist_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.asohist_asohist_id_seq OWNER TO admin;

--
-- TOC entry 9530 (class 0 OID 0)
-- Dependencies: 452
-- Name: asohist_asohist_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE asohist_asohist_id_seq OWNED BY asohist.asohist_id;


--
-- TOC entry 453 (class 1259 OID 146568491)
-- Dependencies: 377 8
-- Name: asohisttax; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE asohisttax (
)
INHERITS (taxhist);


ALTER TABLE public.asohisttax OWNER TO admin;

--
-- TOC entry 454 (class 1259 OID 146568497)
-- Dependencies: 6326 6327 8
-- Name: atlasmap; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE atlasmap (
    atlasmap_id integer NOT NULL,
    atlasmap_name text NOT NULL,
    atlasmap_filter text NOT NULL,
    atlasmap_filtertype text NOT NULL,
    atlasmap_atlas text NOT NULL,
    atlasmap_map text NOT NULL,
    atlasmap_headerline boolean DEFAULT false NOT NULL,
    CONSTRAINT atlasmap_atlasmap_name_check CHECK ((atlasmap_name <> ''::text))
);


ALTER TABLE public.atlasmap OWNER TO admin;

--
-- TOC entry 9533 (class 0 OID 0)
-- Dependencies: 454
-- Name: TABLE atlasmap; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE atlasmap IS 'Describes heuristics for finding a CSVImp atlas for a given CSV file. When looking for a CSV Atlas to use when importing a CSV file, the first atlasmap record found that matches the CSV file is used to select the Atlas file and Map in that Atlas to import the CSV file.';


--
-- TOC entry 9534 (class 0 OID 0)
-- Dependencies: 454
-- Name: COLUMN atlasmap.atlasmap_id; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN atlasmap.atlasmap_id IS 'The internal id of this CSVImp atlas mapping.';


--
-- TOC entry 9535 (class 0 OID 0)
-- Dependencies: 454
-- Name: COLUMN atlasmap.atlasmap_name; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN atlasmap.atlasmap_name IS 'The human-readable name of this atlas mapping.';


--
-- TOC entry 9536 (class 0 OID 0)
-- Dependencies: 454
-- Name: COLUMN atlasmap.atlasmap_filter; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN atlasmap.atlasmap_filter IS 'A regular expression that should match the CSV file. Which part of the file that matches is determined by the filter type.';


--
-- TOC entry 9537 (class 0 OID 0)
-- Dependencies: 454
-- Name: COLUMN atlasmap.atlasmap_filtertype; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN atlasmap.atlasmap_filtertype IS 'A description of what aspect of the CSV file the filter should be compared with. Handled values are: ''filename'' - the filter is matched against the name of the file; and ''firstline'' - the filter is matched against the first line of the file contents.';


--
-- TOC entry 9538 (class 0 OID 0)
-- Dependencies: 454
-- Name: COLUMN atlasmap.atlasmap_atlas; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN atlasmap.atlasmap_atlas IS 'The name of the CSVImp Atlas file. This should be a simple pathname, not an absolute or relative name if possible. The full path will be determined by concatenating the operating-system-specific CSV Atlas default directory with the value here unless this is an absolute pathname.';


--
-- TOC entry 9539 (class 0 OID 0)
-- Dependencies: 454
-- Name: COLUMN atlasmap.atlasmap_map; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN atlasmap.atlasmap_map IS 'The name of the Map inside the Atlas to use if the filter and filter type match the CVS file.';


--
-- TOC entry 9540 (class 0 OID 0)
-- Dependencies: 454
-- Name: COLUMN atlasmap.atlasmap_headerline; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN atlasmap.atlasmap_headerline IS 'An indicator of whether the first line of the CSV file should be treated as a header line or as data.';


--
-- TOC entry 455 (class 1259 OID 146568505)
-- Dependencies: 454 8
-- Name: atlasmap_atlasmap_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE atlasmap_atlasmap_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.atlasmap_atlasmap_id_seq OWNER TO admin;

--
-- TOC entry 9542 (class 0 OID 0)
-- Dependencies: 455
-- Name: atlasmap_atlasmap_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE atlasmap_atlasmap_id_seq OWNED BY atlasmap.atlasmap_id;


--
-- TOC entry 456 (class 1259 OID 146568507)
-- Dependencies: 8
-- Name: backup_usr; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE backup_usr (
    usr_id integer,
    usr_username text,
    usr_propername text,
    usr_passwd text,
    usr_locale_id integer,
    usr_initials text,
    usr_agent boolean,
    usr_active boolean,
    usr_email text,
    usr_dept_id integer,
    usr_shift_id integer,
    usr_window text
);


ALTER TABLE public.backup_usr OWNER TO admin;

--
-- TOC entry 457 (class 1259 OID 146568513)
-- Dependencies: 266 8
-- Name: bankaccnt_bankaccnt_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE bankaccnt_bankaccnt_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.bankaccnt_bankaccnt_id_seq OWNER TO admin;

--
-- TOC entry 9545 (class 0 OID 0)
-- Dependencies: 457
-- Name: bankaccnt_bankaccnt_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE bankaccnt_bankaccnt_id_seq OWNED BY bankaccnt.bankaccnt_id;


--
-- TOC entry 458 (class 1259 OID 146568515)
-- Dependencies: 6328 6329 6330 6331 8
-- Name: bankadj; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE bankadj (
    bankadj_id integer NOT NULL,
    bankadj_bankaccnt_id integer NOT NULL,
    bankadj_bankadjtype_id integer NOT NULL,
    bankadj_created timestamp without time zone DEFAULT now() NOT NULL,
    bankadj_username text DEFAULT geteffectivextuser() NOT NULL,
    bankadj_date date NOT NULL,
    bankadj_docnumber text,
    bankadj_amount numeric(10,2) NOT NULL,
    bankadj_notes text,
    bankadj_sequence integer,
    bankadj_posted boolean DEFAULT false NOT NULL,
    bankadj_curr_id integer DEFAULT basecurrid(),
    bankadj_curr_rate numeric
);


ALTER TABLE public.bankadj OWNER TO admin;

--
-- TOC entry 9547 (class 0 OID 0)
-- Dependencies: 458
-- Name: TABLE bankadj; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE bankadj IS 'Bank Adjustments information';


--
-- TOC entry 459 (class 1259 OID 146568525)
-- Dependencies: 458 8
-- Name: bankadj_bankadj_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE bankadj_bankadj_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.bankadj_bankadj_id_seq OWNER TO admin;

--
-- TOC entry 9549 (class 0 OID 0)
-- Dependencies: 459
-- Name: bankadj_bankadj_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE bankadj_bankadj_id_seq OWNED BY bankadj.bankadj_id;


--
-- TOC entry 460 (class 1259 OID 146568527)
-- Dependencies: 6334 6335 8
-- Name: bankadjtype; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE bankadjtype (
    bankadjtype_id integer NOT NULL,
    bankadjtype_name text NOT NULL,
    bankadjtype_descrip text,
    bankadjtype_accnt_id integer NOT NULL,
    bankadjtype_iscredit boolean DEFAULT false NOT NULL,
    CONSTRAINT bankadjtype_bankadjtype_name_check CHECK ((bankadjtype_name <> ''::text))
);


ALTER TABLE public.bankadjtype OWNER TO admin;

--
-- TOC entry 9551 (class 0 OID 0)
-- Dependencies: 460
-- Name: TABLE bankadjtype; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE bankadjtype IS 'Bank Adjustment Types information';


--
-- TOC entry 461 (class 1259 OID 146568535)
-- Dependencies: 460 8
-- Name: bankadjtype_bankadjtype_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE bankadjtype_bankadjtype_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.bankadjtype_bankadjtype_id_seq OWNER TO admin;

--
-- TOC entry 9553 (class 0 OID 0)
-- Dependencies: 461
-- Name: bankadjtype_bankadjtype_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE bankadjtype_bankadjtype_id_seq OWNED BY bankadjtype.bankadjtype_id;


--
-- TOC entry 462 (class 1259 OID 146568537)
-- Dependencies: 6336 6337 6338 8
-- Name: bankrec; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE bankrec (
    bankrec_id integer NOT NULL,
    bankrec_created timestamp without time zone DEFAULT ('now'::text)::timestamp(6) with time zone NOT NULL,
    bankrec_username text DEFAULT geteffectivextuser() NOT NULL,
    bankrec_bankaccnt_id integer,
    bankrec_opendate date,
    bankrec_enddate date,
    bankrec_openbal numeric(20,2),
    bankrec_endbal numeric(20,2),
    bankrec_posted boolean DEFAULT false,
    bankrec_postdate timestamp without time zone
);


ALTER TABLE public.bankrec OWNER TO admin;

--
-- TOC entry 9555 (class 0 OID 0)
-- Dependencies: 462
-- Name: TABLE bankrec; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE bankrec IS 'Bank Reconciliation posting history';


--
-- TOC entry 463 (class 1259 OID 146568546)
-- Dependencies: 462 8
-- Name: bankrec_bankrec_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE bankrec_bankrec_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.bankrec_bankrec_id_seq OWNER TO admin;

--
-- TOC entry 9557 (class 0 OID 0)
-- Dependencies: 463
-- Name: bankrec_bankrec_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE bankrec_bankrec_id_seq OWNED BY bankrec.bankrec_id;


--
-- TOC entry 464 (class 1259 OID 146568548)
-- Dependencies: 6341 8
-- Name: bankrecitem; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE bankrecitem (
    bankrecitem_id integer NOT NULL,
    bankrecitem_bankrec_id integer NOT NULL,
    bankrecitem_source text NOT NULL,
    bankrecitem_source_id integer NOT NULL,
    bankrecitem_cleared boolean DEFAULT false,
    bankrecitem_curr_rate numeric,
    bankrecitem_amount numeric
);


ALTER TABLE public.bankrecitem OWNER TO admin;


--
-- TOC entry 465 (class 1259 OID 146568555)
-- Dependencies: 464 8
-- Name: bankrecitem_bankrecitem_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE bankrecitem_bankrecitem_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.bankrecitem_bankrecitem_id_seq OWNER TO admin;

--
-- TOC entry 9561 (class 0 OID 0)
-- Dependencies: 465
-- Name: bankrecitem_bankrecitem_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE bankrecitem_bankrecitem_id_seq OWNED BY bankrecitem.bankrecitem_id;


--
-- TOC entry 466 (class 1259 OID 146568557)
-- Dependencies: 8
-- Name: bomhead_bomhead_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE bomhead_bomhead_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.bomhead_bomhead_id_seq OWNER TO admin;

--
-- TOC entry 467 (class 1259 OID 146568559)
-- Dependencies: 8
-- Name: bomitem_bomitem_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE bomitem_bomitem_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.bomitem_bomitem_id_seq OWNER TO admin;

--
-- TOC entry 468 (class 1259 OID 146568561)
-- Dependencies: 6342 6343 6344 6345 8
-- Name: bomitemcost; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE bomitemcost (
    bomitemcost_id integer NOT NULL,
    bomitemcost_bomitem_id integer NOT NULL,
    bomitemcost_costelem_id integer NOT NULL,
    bomitemcost_lowlevel boolean DEFAULT false NOT NULL,
    bomitemcost_stdcost numeric(16,6) DEFAULT 0 NOT NULL,
    bomitemcost_posted date,
    bomitemcost_actcost numeric(16,6) DEFAULT 0 NOT NULL,
    bomitemcost_updated date,
    bomitemcost_curr_id integer DEFAULT basecurrid() NOT NULL
);


ALTER TABLE public.bomitemcost OWNER TO admin;

--
-- TOC entry 9565 (class 0 OID 0)
-- Dependencies: 468
-- Name: TABLE bomitemcost; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE bomitemcost IS 'Bomitem Cost information';


--
-- TOC entry 469 (class 1259 OID 146568568)
-- Dependencies: 468 8
-- Name: bomitemcost_bomitemcost_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE bomitemcost_bomitemcost_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.bomitemcost_bomitemcost_id_seq OWNER TO admin;

--
-- TOC entry 9567 (class 0 OID 0)
-- Dependencies: 469
-- Name: bomitemcost_bomitemcost_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE bomitemcost_bomitemcost_id_seq OWNED BY bomitemcost.bomitemcost_id;


--
-- TOC entry 470 (class 1259 OID 146568570)
-- Dependencies: 258 8
-- Name: bomitemsub_bomitemsub_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE bomitemsub_bomitemsub_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.bomitemsub_bomitemsub_id_seq OWNER TO admin;

--
-- TOC entry 9569 (class 0 OID 0)
-- Dependencies: 470
-- Name: bomitemsub_bomitemsub_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE bomitemsub_bomitemsub_id_seq OWNED BY bomitemsub.bomitemsub_id;


--
-- TOC entry 471 (class 1259 OID 146568572)
-- Dependencies: 6348 6349 8
-- Name: bomwork; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE bomwork (
    bomwork_id integer NOT NULL,
    bomwork_set_id integer,
    bomwork_seqnumber integer,
    bomwork_item_id integer,
    bomwork_item_type character(1),
    bomwork_qtyper numeric(20,8),
    bomwork_scrap numeric(20,10),
    bomwork_status character(1),
    bomwork_level integer,
    bomwork_parent_id integer,
    bomwork_effective date,
    bomwork_expires date,
    bomwork_stdunitcost numeric(16,6),
    bomwork_actunitcost numeric(16,6),
    bomwork_parent_seqnumber integer,
    bomwork_createwo boolean,
    bomwork_issuemethod character(1),
    bomwork_char_id integer,
    bomwork_value text,
    bomwork_notes text,
    bomwork_ref text,
    bomwork_bomitem_id integer,
    bomwork_ecn text,
    bomwork_qtyfxd numeric(20,8) DEFAULT 0 NOT NULL,
    bomwork_qtyreq numeric(20,8) DEFAULT 0 NOT NULL
);


ALTER TABLE public.bomwork OWNER TO admin;

--
-- TOC entry 9571 (class 0 OID 0)
-- Dependencies: 471
-- Name: TABLE bomwork; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE bomwork IS 'Temporary table for storing information requested by Bill of Materials (BOM) displays and reports';


--
-- TOC entry 9572 (class 0 OID 0)
-- Dependencies: 471
-- Name: COLUMN bomwork.bomwork_qtyfxd; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN bomwork.bomwork_qtyfxd IS 'The fixed quantity required';


--
-- TOC entry 9573 (class 0 OID 0)
-- Dependencies: 471
-- Name: COLUMN bomwork.bomwork_qtyreq; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN bomwork.bomwork_qtyreq IS 'The total quantity required';


--
-- TOC entry 472 (class 1259 OID 146568580)
-- Dependencies: 471 8
-- Name: bomwork_bomwork_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE bomwork_bomwork_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.bomwork_bomwork_id_seq OWNER TO admin;

--
-- TOC entry 9575 (class 0 OID 0)
-- Dependencies: 472
-- Name: bomwork_bomwork_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE bomwork_bomwork_id_seq OWNED BY bomwork.bomwork_id;


--
-- TOC entry 474 (class 1259 OID 146568586)
-- Dependencies: 260 8
-- Name: budghead_budghead_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE budghead_budghead_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.budghead_budghead_id_seq OWNER TO admin;

--
-- TOC entry 9578 (class 0 OID 0)
-- Dependencies: 474
-- Name: budghead_budghead_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE budghead_budghead_id_seq OWNED BY budghead.budghead_id;


--
-- TOC entry 475 (class 1259 OID 146568588)
-- Dependencies: 263 8
-- Name: budgitem_budgitem_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE budgitem_budgitem_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.budgitem_budgitem_id_seq OWNER TO admin;

--
-- TOC entry 9580 (class 0 OID 0)
-- Dependencies: 475
-- Name: budgitem_budgitem_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE budgitem_budgitem_id_seq OWNED BY budgitem.budgitem_id;


--
-- TOC entry 476 (class 1259 OID 146568590)
-- Dependencies: 6350 6351 8
-- Name: calhead; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE calhead (
    calhead_id integer DEFAULT nextval(('"calhead_calhead_id_seq"'::text)::regclass) NOT NULL,
    calhead_type character(1),
    calhead_name text NOT NULL,
    calhead_descrip text,
    calhead_origin character(1),
    CONSTRAINT calhead_calhead_name_check CHECK ((calhead_name <> ''::text))
);


ALTER TABLE public.calhead OWNER TO admin;

--
-- TOC entry 9582 (class 0 OID 0)
-- Dependencies: 476
-- Name: TABLE calhead; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE calhead IS 'Calendar header information';


--
-- TOC entry 477 (class 1259 OID 146568598)
-- Dependencies: 8
-- Name: calhead_calhead_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE calhead_calhead_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.calhead_calhead_id_seq OWNER TO admin;

--
-- TOC entry 478 (class 1259 OID 146568600)
-- Dependencies: 8
-- Name: carrier_carrier_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE carrier_carrier_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.carrier_carrier_id_seq OWNER TO admin;

--
-- TOC entry 479 (class 1259 OID 146568602)
-- Dependencies: 267 8
-- Name: cashrcpt_cashrcpt_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE cashrcpt_cashrcpt_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.cashrcpt_cashrcpt_id_seq OWNER TO admin;

--
-- TOC entry 9586 (class 0 OID 0)
-- Dependencies: 479
-- Name: cashrcpt_cashrcpt_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE cashrcpt_cashrcpt_id_seq OWNED BY cashrcpt.cashrcpt_id;


--
-- TOC entry 480 (class 1259 OID 146568604)
-- Dependencies: 271 8
-- Name: cashrcptmisc_cashrcptmisc_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE cashrcptmisc_cashrcptmisc_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.cashrcptmisc_cashrcptmisc_id_seq OWNER TO admin;

--
-- TOC entry 9588 (class 0 OID 0)
-- Dependencies: 480
-- Name: cashrcptmisc_cashrcptmisc_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE cashrcptmisc_cashrcptmisc_id_seq OWNED BY cashrcptmisc.cashrcptmisc_id;


--
-- TOC entry 481 (class 1259 OID 146568606)
-- Dependencies: 278 8
-- Name: ccard_ccard_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE ccard_ccard_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ccard_ccard_id_seq OWNER TO admin;

--
-- TOC entry 9590 (class 0 OID 0)
-- Dependencies: 481
-- Name: ccard_ccard_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE ccard_ccard_id_seq OWNED BY ccard.ccard_id;


--
-- TOC entry 482 (class 1259 OID 146568608)
-- Dependencies: 6353 6354 8
-- Name: ccardaud; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE ccardaud (
    ccardaud_id integer NOT NULL,
    ccardaud_ccard_id integer,
    ccardaud_ccard_seq_old integer,
    ccardaud_ccard_seq_new integer,
    ccardaud_ccard_cust_id_old integer,
    ccardaud_ccard_cust_id_new integer,
    ccardaud_ccard_active_old boolean,
    ccardaud_ccard_active_new boolean,
    ccardaud_ccard_name_old bytea,
    ccardaud_ccard_name_new bytea,
    ccardaud_ccard_address1_old bytea,
    ccardaud_ccard_address1_new bytea,
    ccardaud_ccard_address2_old bytea,
    ccardaud_ccard_address2_new bytea,
    ccardaud_ccard_city_old bytea,
    ccardaud_ccard_city_new bytea,
    ccardaud_ccard_state_old bytea,
    ccardaud_ccard_state_new bytea,
    ccardaud_ccard_zip_old bytea,
    ccardaud_ccard_zip_new bytea,
    ccardaud_ccard_country_old bytea,
    ccardaud_ccard_country_new bytea,
    ccardaud_ccard_number_old bytea,
    ccardaud_ccard_number_new bytea,
    ccardaud_ccard_debit_old boolean,
    ccardaud_ccard_debit_new boolean,
    ccardaud_ccard_month_expired_old bytea,
    ccardaud_ccard_month_expired_new bytea,
    ccardaud_ccard_year_expired_old bytea,
    ccardaud_ccard_year_expired_new bytea,
    ccardaud_ccard_type_old character(1),
    ccardaud_ccard_type_new character(1),
    ccardaud_ccard_last_updated timestamp without time zone DEFAULT ('now'::text)::timestamp(6) with time zone NOT NULL,
    ccardaud_ccard_last_updated_by_username text DEFAULT geteffectivextuser() NOT NULL
);


ALTER TABLE public.ccardaud OWNER TO admin;

--
-- TOC entry 9592 (class 0 OID 0)
-- Dependencies: 482
-- Name: TABLE ccardaud; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE ccardaud IS 'Credit Card Information tracking data';


--
-- TOC entry 483 (class 1259 OID 146568616)
-- Dependencies: 482 8
-- Name: ccardaud_ccardaud_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE ccardaud_ccardaud_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ccardaud_ccardaud_id_seq OWNER TO admin;

--
-- TOC entry 9594 (class 0 OID 0)
-- Dependencies: 483
-- Name: ccardaud_ccardaud_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE ccardaud_ccardaud_id_seq OWNED BY ccardaud.ccardaud_id;


--
-- TOC entry 484 (class 1259 OID 146568618)
-- Dependencies: 6356 8
-- Name: ccbank; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE ccbank (
    ccbank_id integer NOT NULL,
    ccbank_ccard_type text NOT NULL,
    ccbank_bankaccnt_id integer,
    CONSTRAINT ccbank_ccbank_ccard_type_check CHECK ((ccbank_ccard_type = ANY (ARRAY['A'::text, 'D'::text, 'M'::text, 'P'::text, 'V'::text])))
);


ALTER TABLE public.ccbank OWNER TO admin;

--
-- TOC entry 485 (class 1259 OID 146568625)
-- Dependencies: 484 8
-- Name: ccbank_ccbank_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE ccbank_ccbank_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ccbank_ccbank_id_seq OWNER TO admin;

--
-- TOC entry 9597 (class 0 OID 0)
-- Dependencies: 485
-- Name: ccbank_ccbank_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE ccbank_ccbank_id_seq OWNED BY ccbank.ccbank_id;


--
-- TOC entry 486 (class 1259 OID 146568627)
-- Dependencies: 6357 6358 6359 6360 6361 8
-- Name: ccpay; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE ccpay (
    ccpay_id integer NOT NULL,
    ccpay_ccard_id integer,
    ccpay_cust_id integer,
    ccpay_amount numeric(20,2) DEFAULT 0.00 NOT NULL,
    ccpay_auth boolean DEFAULT true NOT NULL,
    ccpay_status character(1) NOT NULL,
    ccpay_type character(1) NOT NULL,
    ccpay_auth_charge character(1) NOT NULL,
    ccpay_order_number text,
    ccpay_order_number_seq integer,
    ccpay_r_avs text,
    ccpay_r_ordernum text,
    ccpay_r_error text,
    ccpay_r_approved text,
    ccpay_r_code text,
    ccpay_r_message text,
    ccpay_yp_r_time timestamp without time zone,
    ccpay_r_ref text,
    ccpay_yp_r_tdate text,
    ccpay_r_tax text,
    ccpay_r_shipping text,
    ccpay_yp_r_score integer,
    ccpay_transaction_datetime timestamp without time zone DEFAULT ('now'::text)::timestamp(6) with time zone NOT NULL,
    ccpay_by_username text DEFAULT geteffectivextuser() NOT NULL,
    ccpay_curr_id integer DEFAULT basecurrid(),
    ccpay_ccpay_id integer
);


ALTER TABLE public.ccpay OWNER TO admin;


--
-- TOC entry 487 (class 1259 OID 146568638)
-- Dependencies: 486 8
-- Name: ccpay_ccpay_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE ccpay_ccpay_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ccpay_ccpay_id_seq OWNER TO admin;

--
-- TOC entry 9627 (class 0 OID 0)
-- Dependencies: 487
-- Name: ccpay_ccpay_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE ccpay_ccpay_id_seq OWNED BY ccpay.ccpay_id;


--
-- TOC entry 488 (class 1259 OID 146568640)
-- Dependencies: 236 8
-- Name: char_char_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE char_char_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.char_char_id_seq OWNER TO admin;

--
-- TOC entry 9629 (class 0 OID 0)
-- Dependencies: 488
-- Name: char_char_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE char_char_id_seq OWNED BY "char".char_id;


--
-- TOC entry 489 (class 1259 OID 146568642)
-- Dependencies: 237 8
-- Name: charass_charass_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE charass_charass_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.charass_charass_id_seq OWNER TO admin;

--
-- TOC entry 9631 (class 0 OID 0)
-- Dependencies: 489
-- Name: charass_charass_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE charass_charass_id_seq OWNED BY charass.charass_id;


--
-- TOC entry 490 (class 1259 OID 146568644)
-- Dependencies: 6364 8
-- Name: charopt; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE charopt (
    charopt_id integer NOT NULL,
    charopt_char_id integer,
    charopt_value text NOT NULL,
    charopt_order integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.charopt OWNER TO admin;

--
-- TOC entry 9633 (class 0 OID 0)
-- Dependencies: 490
-- Name: TABLE charopt; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE charopt IS 'Stores list options for characteristics';


--
-- TOC entry 9634 (class 0 OID 0)
-- Dependencies: 490
-- Name: COLUMN charopt.charopt_id; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN charopt.charopt_id IS 'Primary key';


--
-- TOC entry 9635 (class 0 OID 0)
-- Dependencies: 490
-- Name: COLUMN charopt.charopt_char_id; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN charopt.charopt_char_id IS 'Reference to char table';


--
-- TOC entry 9636 (class 0 OID 0)
-- Dependencies: 490
-- Name: COLUMN charopt.charopt_value; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN charopt.charopt_value IS 'Option value';


--
-- TOC entry 9637 (class 0 OID 0)
-- Dependencies: 490
-- Name: COLUMN charopt.charopt_order; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN charopt.charopt_order IS 'Option sort order';


--
-- TOC entry 491 (class 1259 OID 146568651)
-- Dependencies: 490 8
-- Name: charopt_charopt_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE charopt_charopt_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.charopt_charopt_id_seq OWNER TO admin;

--
-- TOC entry 9639 (class 0 OID 0)
-- Dependencies: 491
-- Name: charopt_charopt_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE charopt_charopt_id_seq OWNED BY charopt.charopt_id;


--
-- TOC entry 492 (class 1259 OID 146568653)
-- Dependencies: 430 8
-- Name: checkhead_checkhead_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE checkhead_checkhead_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.checkhead_checkhead_id_seq OWNER TO admin;

--
-- TOC entry 9641 (class 0 OID 0)
-- Dependencies: 492
-- Name: checkhead_checkhead_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE checkhead_checkhead_id_seq OWNED BY checkhead.checkhead_id;


--
-- TOC entry 493 (class 1259 OID 146568655)
-- Dependencies: 432 8
-- Name: checkitem_checkitem_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE checkitem_checkitem_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.checkitem_checkitem_id_seq OWNER TO admin;

--
-- TOC entry 9643 (class 0 OID 0)
-- Dependencies: 493
-- Name: checkitem_checkitem_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE checkitem_checkitem_id_seq OWNED BY checkitem.checkitem_id;


--
-- TOC entry 495 (class 1259 OID 146568662)
-- Dependencies: 8
-- Name: classcode_classcode_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE classcode_classcode_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.classcode_classcode_id_seq OWNER TO admin;

--
-- TOC entry 496 (class 1259 OID 146568664)
-- Dependencies: 8
-- Name: cmhead_cmhead_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE cmhead_cmhead_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.cmhead_cmhead_id_seq OWNER TO admin;

--
-- TOC entry 497 (class 1259 OID 146568666)
-- Dependencies: 377 8
-- Name: cmheadtax; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE cmheadtax (
)
INHERITS (taxhist);


ALTER TABLE public.cmheadtax OWNER TO admin;

--
-- TOC entry 498 (class 1259 OID 146568672)
-- Dependencies: 8
-- Name: cmitem_cmitem_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE cmitem_cmitem_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.cmitem_cmitem_id_seq OWNER TO admin;

--
-- TOC entry 499 (class 1259 OID 146568674)
-- Dependencies: 377 8
-- Name: cmitemtax; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE cmitemtax (
)
INHERITS (taxhist);


ALTER TABLE public.cmitemtax OWNER TO admin;

--
-- TOC entry 500 (class 1259 OID 146568680)
-- Dependencies: 239 8
-- Name: cmnttype_cmnttype_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE cmnttype_cmnttype_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.cmnttype_cmnttype_id_seq OWNER TO admin;

--
-- TOC entry 9651 (class 0 OID 0)
-- Dependencies: 500
-- Name: cmnttype_cmnttype_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE cmnttype_cmnttype_id_seq OWNED BY cmnttype.cmnttype_id;


--
-- TOC entry 501 (class 1259 OID 146568682)
-- Dependencies: 8
-- Name: cmnttypesource; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE cmnttypesource (
    cmnttypesource_id integer NOT NULL,
    cmnttypesource_cmnttype_id integer,
    cmnttypesource_source_id integer
);


ALTER TABLE public.cmnttypesource OWNER TO admin;


--
-- TOC entry 502 (class 1259 OID 146568685)
-- Dependencies: 501 8
-- Name: cmnttypesource_cmnttypesource_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE cmnttypesource_cmnttypesource_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.cmnttypesource_cmnttypesource_id_seq OWNER TO admin;

--
-- TOC entry 9655 (class 0 OID 0)
-- Dependencies: 502
-- Name: cmnttypesource_cmnttypesource_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE cmnttypesource_cmnttypesource_id_seq OWNED BY cmnttypesource.cmnttypesource_id;


--
-- TOC entry 503 (class 1259 OID 146568687)
-- Dependencies: 204 8
-- Name: cntct_cntct_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE cntct_cntct_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.cntct_cntct_id_seq OWNER TO admin;

--
-- TOC entry 9657 (class 0 OID 0)
-- Dependencies: 503
-- Name: cntct_cntct_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE cntct_cntct_id_seq OWNED BY cntct.cntct_id;


--
-- TOC entry 504 (class 1259 OID 146568689)
-- Dependencies: 8
-- Name: cntctaddr; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE cntctaddr (
    cntctaddr_id integer NOT NULL,
    cntctaddr_cntct_id integer,
    cntctaddr_primary boolean NOT NULL,
    cntctaddr_addr_id integer NOT NULL,
    cntctaddr_type character(2) NOT NULL
);


ALTER TABLE public.cntctaddr OWNER TO admin;

--
-- TOC entry 505 (class 1259 OID 146568692)
-- Dependencies: 504 8
-- Name: cntctaddr_cntctaddr_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE cntctaddr_cntctaddr_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.cntctaddr_cntctaddr_id_seq OWNER TO admin;

--
-- TOC entry 9660 (class 0 OID 0)
-- Dependencies: 505
-- Name: cntctaddr_cntctaddr_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE cntctaddr_cntctaddr_id_seq OWNED BY cntctaddr.cntctaddr_id;


--
-- TOC entry 506 (class 1259 OID 146568694)
-- Dependencies: 8
-- Name: cntctdata; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE cntctdata (
    cntctdata_id integer NOT NULL,
    cntctdata_cntct_id integer,
    cntctdata_primary boolean NOT NULL,
    cntctdata_text text NOT NULL,
    cntctdata_type character(2) NOT NULL
);


ALTER TABLE public.cntctdata OWNER TO admin;

--
-- TOC entry 507 (class 1259 OID 146568700)
-- Dependencies: 506 8
-- Name: cntctdata_cntctdata_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE cntctdata_cntctdata_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.cntctdata_cntctdata_id_seq OWNER TO admin;

--
-- TOC entry 9663 (class 0 OID 0)
-- Dependencies: 507
-- Name: cntctdata_cntctdata_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE cntctdata_cntctdata_id_seq OWNED BY cntctdata.cntctdata_id;


--
-- TOC entry 508 (class 1259 OID 146568702)
-- Dependencies: 6371 8
-- Name: cntcteml; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE cntcteml (
    cntcteml_id integer NOT NULL,
    cntcteml_cntct_id integer,
    cntcteml_primary boolean DEFAULT false NOT NULL,
    cntcteml_email text NOT NULL
);


ALTER TABLE public.cntcteml OWNER TO admin;

--
-- TOC entry 9665 (class 0 OID 0)
-- Dependencies: 508
-- Name: TABLE cntcteml; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE cntcteml IS 'Stores email addresses for contacts';


--
-- TOC entry 9666 (class 0 OID 0)
-- Dependencies: 508
-- Name: COLUMN cntcteml.cntcteml_id; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN cntcteml.cntcteml_id IS 'Primary key';


--
-- TOC entry 9667 (class 0 OID 0)
-- Dependencies: 508
-- Name: COLUMN cntcteml.cntcteml_cntct_id; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN cntcteml.cntcteml_cntct_id IS 'Reference to contact table';


--
-- TOC entry 9668 (class 0 OID 0)
-- Dependencies: 508
-- Name: COLUMN cntcteml.cntcteml_primary; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN cntcteml.cntcteml_primary IS 'Flags whether this is the primary email address';


--
-- TOC entry 9669 (class 0 OID 0)
-- Dependencies: 508
-- Name: COLUMN cntcteml.cntcteml_email; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN cntcteml.cntcteml_email IS 'Alternate information';


--
-- TOC entry 509 (class 1259 OID 146568709)
-- Dependencies: 508 8
-- Name: cntcteml_cntcteml_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE cntcteml_cntcteml_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.cntcteml_cntcteml_id_seq OWNER TO admin;

--
-- TOC entry 9671 (class 0 OID 0)
-- Dependencies: 509
-- Name: cntcteml_cntcteml_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE cntcteml_cntcteml_id_seq OWNED BY cntcteml.cntcteml_id;


--
-- TOC entry 510 (class 1259 OID 146568711)
-- Dependencies: 6372 8
-- Name: cntctmrgd; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE cntctmrgd (
    cntctmrgd_cntct_id integer NOT NULL,
    cntctmrgd_error boolean DEFAULT false
);


ALTER TABLE public.cntctmrgd OWNER TO admin;

--
-- TOC entry 511 (class 1259 OID 146568715)
-- Dependencies: 6373 6374 6375 6376 6377 6378 6379 6380 6381 6382 6383 6384 6385 6386 6387 6388 8
-- Name: cntctsel; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE cntctsel (
    cntctsel_cntct_id integer NOT NULL,
    cntctsel_target boolean,
    cntctsel_mrg_crmacct_id boolean DEFAULT false,
    cntctsel_mrg_addr_id boolean DEFAULT false,
    cntctsel_mrg_first_name boolean DEFAULT false,
    cntctsel_mrg_last_name boolean DEFAULT false,
    cntctsel_mrg_honorific boolean DEFAULT false,
    cntctsel_mrg_initials boolean DEFAULT false,
    cntctsel_mrg_phone boolean DEFAULT false,
    cntctsel_mrg_phone2 boolean DEFAULT false,
    cntctsel_mrg_fax boolean DEFAULT false,
    cntctsel_mrg_email boolean DEFAULT false,
    cntctsel_mrg_webaddr boolean DEFAULT false,
    cntctsel_mrg_notes boolean DEFAULT false,
    cntctsel_mrg_title boolean DEFAULT false,
    cntctsel_mrg_middle boolean DEFAULT false,
    cntctsel_mrg_suffix boolean DEFAULT false,
    cntctsel_mrg_owner_username boolean DEFAULT false
);


ALTER TABLE public.cntctsel OWNER TO admin;

--
-- TOC entry 512 (class 1259 OID 146568734)
-- Dependencies: 8
-- Name: cntslip_cntslip_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE cntslip_cntslip_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.cntslip_cntslip_id_seq OWNER TO admin;

--
-- TOC entry 513 (class 1259 OID 146568736)
-- Dependencies: 6389 8
-- Name: cobill; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE cobill (
    cobill_id integer DEFAULT nextval(('cobill_cobill_id_seq'::text)::regclass) NOT NULL,
    cobill_coitem_id integer,
    cobill_selectdate timestamp with time zone,
    cobill_qty numeric(18,6),
    cobill_invcnum integer,
    cobill_toclose boolean,
    cobill_cobmisc_id integer,
    cobill_select_username text,
    cobill_invcitem_id integer,
    cobill_taxtype_id integer
);


ALTER TABLE public.cobill OWNER TO admin;

--
-- TOC entry 9676 (class 0 OID 0)
-- Dependencies: 513
-- Name: TABLE cobill; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE cobill IS 'Billing Selection Line Item information';


--
-- TOC entry 514 (class 1259 OID 146568743)
-- Dependencies: 8
-- Name: cobill_cobill_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE cobill_cobill_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.cobill_cobill_id_seq OWNER TO admin;

--
-- TOC entry 515 (class 1259 OID 146568745)
-- Dependencies: 377 8
-- Name: cobilltax; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE cobilltax (
)
INHERITS (taxhist);


ALTER TABLE public.cobilltax OWNER TO admin;

--
-- TOC entry 516 (class 1259 OID 146568751)
-- Dependencies: 6391 6392 8
-- Name: cobmisc; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE cobmisc (
    cobmisc_id integer DEFAULT nextval(('cobmisc_cobmisc_id_seq'::text)::regclass) NOT NULL,
    cobmisc_cohead_id integer,
    cobmisc_shipvia text,
    cobmisc_freight numeric(16,4),
    cobmisc_misc numeric(16,4),
    cobmisc_payment numeric(16,4),
    cobmisc_paymentref text,
    cobmisc_notes text,
    cobmisc_shipdate date,
    cobmisc_invcnumber integer,
    cobmisc_invcdate date,
    cobmisc_posted boolean,
    cobmisc_misc_accnt_id integer,
    cobmisc_misc_descrip text,
    cobmisc_closeorder boolean,
    cobmisc_curr_id integer DEFAULT basecurrid(),
    cobmisc_invchead_id integer,
    cobmisc_taxzone_id integer,
    cobmisc_taxtype_id integer
);


ALTER TABLE public.cobmisc OWNER TO admin;

--
-- TOC entry 9680 (class 0 OID 0)
-- Dependencies: 516
-- Name: TABLE cobmisc; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE cobmisc IS 'General information about Billing Selections';


--
-- TOC entry 517 (class 1259 OID 146568759)
-- Dependencies: 8
-- Name: cobmisc_cobmisc_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE cobmisc_cobmisc_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.cobmisc_cobmisc_id_seq OWNER TO admin;

--
-- TOC entry 518 (class 1259 OID 146568761)
-- Dependencies: 377 8
-- Name: cobmisctax; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE cobmisctax (
)
INHERITS (taxhist);


ALTER TABLE public.cobmisctax OWNER TO admin;

--
-- TOC entry 519 (class 1259 OID 146568767)
-- Dependencies: 8
-- Name: cohead_cohead_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE cohead_cohead_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.cohead_cohead_id_seq OWNER TO admin;

--
-- TOC entry 520 (class 1259 OID 146568769)
-- Dependencies: 8
-- Name: cohist_cohist_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE cohist_cohist_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.cohist_cohist_id_seq OWNER TO admin;

--
-- TOC entry 521 (class 1259 OID 146568771)
-- Dependencies: 8
-- Name: coitem_coitem_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE coitem_coitem_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.coitem_coitem_id_seq OWNER TO admin;

--
-- TOC entry 522 (class 1259 OID 146568773)
-- Dependencies: 8
-- Name: comment_comment_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE comment_comment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.comment_comment_id_seq OWNER TO admin;

--
-- TOC entry 523 (class 1259 OID 146568775)
-- Dependencies: 6395 6396 8
-- Name: company; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE company (
    company_id integer NOT NULL,
    company_number text NOT NULL,
    company_descrip text,
    company_external boolean DEFAULT false NOT NULL,
    company_server text,
    company_port integer,
    company_database text,
    company_curr_id integer,
    company_yearend_accnt_id integer,
    company_gainloss_accnt_id integer,
    company_dscrp_accnt_id integer,
    company_unrlzgainloss_accnt_id integer,
    CONSTRAINT company_company_number_check CHECK ((company_number <> ''::text))
);


ALTER TABLE public.company OWNER TO admin;


--
-- TOC entry 524 (class 1259 OID 146568783)
-- Dependencies: 523 8
-- Name: company_company_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE company_company_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.company_company_id_seq OWNER TO admin;

--
-- TOC entry 9690 (class 0 OID 0)
-- Dependencies: 524
-- Name: company_company_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE company_company_id_seq OWNED BY company.company_id;


--
-- TOC entry 525 (class 1259 OID 146568785)
-- Dependencies: 329 8
-- Name: contrct_contrct_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE contrct_contrct_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.contrct_contrct_id_seq OWNER TO admin;

--
-- TOC entry 9692 (class 0 OID 0)
-- Dependencies: 525
-- Name: contrct_contrct_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE contrct_contrct_id_seq OWNED BY contrct.contrct_id;


--
-- TOC entry 526 (class 1259 OID 146568787)
-- Dependencies: 6397 6398 6399 6401 6402 6403 8
-- Name: shiphead; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE shiphead (
    shiphead_id integer NOT NULL,
    shiphead_order_id integer NOT NULL,
    shiphead_order_type text NOT NULL,
    shiphead_number text NOT NULL,
    shiphead_shipvia text,
    shiphead_freight numeric(16,4) DEFAULT 0.0 NOT NULL,
    shiphead_freight_curr_id integer DEFAULT basecurrid() NOT NULL,
    shiphead_notes text,
    shiphead_shipped boolean DEFAULT false NOT NULL,
    shiphead_shipdate date,
    shiphead_shipchrg_id integer,
    shiphead_shipform_id integer,
    shiphead_sfstatus character(1) NOT NULL,
    shiphead_tracknum text,
    CONSTRAINT shiphead_shiphead_number_check CHECK ((shiphead_number <> ''::text)),
    CONSTRAINT shiphead_shiphead_order_type_check CHECK (((shiphead_order_type = 'SO'::text) OR (shiphead_order_type = 'TO'::text))),
    CONSTRAINT shiphead_shiphead_sfstatus_check CHECK ((((shiphead_sfstatus = 'D'::bpchar) OR (shiphead_sfstatus = 'N'::bpchar)) OR (shiphead_sfstatus = 'P'::bpchar)))
);


ALTER TABLE public.shiphead OWNER TO admin;


--
-- TOC entry 527 (class 1259 OID 146568799)
-- Dependencies: 6405 6406 8
-- Name: shipitem; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE shipitem (
    shipitem_id integer NOT NULL,
    shipitem_orderitem_id integer NOT NULL,
    shipitem_shiphead_id integer NOT NULL,
    shipitem_qty numeric(18,6) NOT NULL,
    shipitem_shipped boolean DEFAULT false NOT NULL,
    shipitem_shipdate timestamp with time zone,
    shipitem_transdate timestamp with time zone,
    shipitem_trans_username text,
    shipitem_invoiced boolean DEFAULT false NOT NULL,
    shipitem_invcitem_id integer,
    shipitem_value numeric(18,6),
    shipitem_invhist_id integer
);


ALTER TABLE public.shipitem OWNER TO admin;

--
-- TOC entry 9696 (class 0 OID 0)
-- Dependencies: 527
-- Name: TABLE shipitem; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE shipitem IS 'Information about Shipment Line Items';


--
-- TOC entry 529 (class 1259 OID 146568811)
-- Dependencies: 8
-- Name: coship_coship_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE coship_coship_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.coship_coship_id_seq OWNER TO admin;


--
-- TOC entry 531 (class 1259 OID 146568817)
-- Dependencies: 8
-- Name: cosmisc_cosmisc_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE cosmisc_cosmisc_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.cosmisc_cosmisc_id_seq OWNER TO admin;

--
-- TOC entry 532 (class 1259 OID 146568819)
-- Dependencies: 8
-- Name: cosrc_cosrc_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE cosrc_cosrc_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.cosrc_cosrc_id_seq OWNER TO admin;

--
-- TOC entry 533 (class 1259 OID 146568821)
-- Dependencies: 8
-- Name: costcat_costcat_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE costcat_costcat_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.costcat_costcat_id_seq OWNER TO admin;

--
-- TOC entry 534 (class 1259 OID 146568823)
-- Dependencies: 8
-- Name: costelem_costelem_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE costelem_costelem_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.costelem_costelem_id_seq OWNER TO admin;

--
-- TOC entry 535 (class 1259 OID 146568825)
-- Dependencies: 6407 6408 6409 8
-- Name: costhist; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE costhist (
    costhist_id integer DEFAULT nextval(('"costhist_costhist_id_seq"'::text)::regclass) NOT NULL,
    costhist_item_id integer,
    costhist_costelem_id integer,
    costhist_type character(1),
    costhist_date timestamp with time zone,
    costhist_oldcost numeric(16,6),
    costhist_newcost numeric(16,6),
    costhist_lowlevel boolean,
    costhist_oldcurr_id integer DEFAULT basecurrid(),
    costhist_newcurr_id integer DEFAULT basecurrid(),
    costhist_username text
);


ALTER TABLE public.costhist OWNER TO admin;

--
-- TOC entry 9705 (class 0 OID 0)
-- Dependencies: 535
-- Name: TABLE costhist; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE costhist IS 'Item Cost history';


--
-- TOC entry 536 (class 1259 OID 146568834)
-- Dependencies: 8
-- Name: costhist_costhist_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE costhist_costhist_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.costhist_costhist_id_seq OWNER TO admin;

--
-- TOC entry 537 (class 1259 OID 146568836)
-- Dependencies: 6410 8
-- Name: costupdate; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE costupdate (
    costupdate_item_id integer,
    costupdate_lowlevel_code integer DEFAULT 1 NOT NULL,
    costupdate_item_type character(1)
);


ALTER TABLE public.costupdate OWNER TO admin;

--
-- TOC entry 9708 (class 0 OID 0)
-- Dependencies: 537
-- Name: TABLE costupdate; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE costupdate IS 'Scratch area for sequencing the updating of item costs';


--
-- TOC entry 538 (class 1259 OID 146568840)
-- Dependencies: 6412 6413 8
-- Name: country; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE country (
    country_id integer NOT NULL,
    country_abbr character(2),
    country_name text,
    country_curr_abbr character(3),
    country_curr_name text,
    country_curr_number character(3),
    country_curr_symbol character varying(9),
    country_qt_number integer,
    CONSTRAINT country_country_abbr_check CHECK ((country_abbr <> ''::bpchar)),
    CONSTRAINT country_country_name_check CHECK ((country_name <> ''::text))
);


ALTER TABLE public.country OWNER TO admin;

--
-- TOC entry 9710 (class 0 OID 0)
-- Dependencies: 538
-- Name: TABLE country; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE country IS 'Basic information and properties about countries.';


--
-- TOC entry 539 (class 1259 OID 146568848)
-- Dependencies: 538 8
-- Name: country_country_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE country_country_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.country_country_id_seq OWNER TO admin;

--
-- TOC entry 9712 (class 0 OID 0)
-- Dependencies: 539
-- Name: country_country_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE country_country_id_seq OWNED BY country.country_id;


--
-- TOC entry 540 (class 1259 OID 146568850)
-- Dependencies: 6414 8
-- Name: salesaccnt; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE salesaccnt (
    salesaccnt_id integer DEFAULT nextval(('"salesaccnt_salesaccnt_id_seq"'::text)::regclass) NOT NULL,
    salesaccnt_custtype_id integer,
    salesaccnt_prodcat_id integer,
    salesaccnt_warehous_id integer,
    salesaccnt_sales_accnt_id integer,
    salesaccnt_credit_accnt_id integer,
    salesaccnt_cos_accnt_id integer,
    salesaccnt_custtype text,
    salesaccnt_prodcat text,
    salesaccnt_returns_accnt_id integer,
    salesaccnt_cor_accnt_id integer,
    salesaccnt_cow_accnt_id integer,
    salesaccnt_saletype_id integer,
    salesaccnt_shipzone_id integer
);


ALTER TABLE public.salesaccnt OWNER TO admin;

--
-- TOC entry 9714 (class 0 OID 0)
-- Dependencies: 540
-- Name: TABLE salesaccnt; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE salesaccnt IS 'Sales Account assignment information';


--
-- TOC entry 9715 (class 0 OID 0)
-- Dependencies: 540
-- Name: COLUMN salesaccnt.salesaccnt_saletype_id; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN salesaccnt.salesaccnt_saletype_id IS 'Associated sale type for sales account.';


--
-- TOC entry 9716 (class 0 OID 0)
-- Dependencies: 540
-- Name: COLUMN salesaccnt.salesaccnt_shipzone_id; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN salesaccnt.salesaccnt_shipzone_id IS 'Associated shipping zone for sales account.';


--
-- TOC entry 543 (class 1259 OID 146568867)
-- Dependencies: 205 8
-- Name: crmacct_crmacct_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE crmacct_crmacct_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.crmacct_crmacct_id_seq OWNER TO admin;

--
-- TOC entry 9721 (class 0 OID 0)
-- Dependencies: 543
-- Name: crmacct_crmacct_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE crmacct_crmacct_id_seq OWNED BY crmacct.crmacct_id;


--
-- TOC entry 544 (class 1259 OID 146568869)
-- Dependencies: 6415 6416 6417 6418 6419 6420 6421 6422 6423 6424 6425 6426 6427 6428 6429 6430 6431 6432 8
-- Name: crmacctsel; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE crmacctsel (
    crmacctsel_src_crmacct_id integer NOT NULL,
    crmacctsel_dest_crmacct_id integer,
    crmacctsel_mrg_crmacct_active boolean DEFAULT false NOT NULL,
    crmacctsel_mrg_crmacct_cntct_id_1 boolean DEFAULT false NOT NULL,
    crmacctsel_mrg_crmacct_cntct_id_2 boolean DEFAULT false NOT NULL,
    crmacctsel_mrg_crmacct_competitor_id boolean DEFAULT false NOT NULL,
    crmacctsel_mrg_crmacct_cust_id boolean DEFAULT false NOT NULL,
    crmacctsel_mrg_crmacct_emp_id boolean DEFAULT false NOT NULL,
    crmacctsel_mrg_crmacct_name boolean DEFAULT false NOT NULL,
    crmacctsel_mrg_crmacct_notes boolean DEFAULT false NOT NULL,
    crmacctsel_mrg_crmacct_owner_username boolean DEFAULT false NOT NULL,
    crmacctsel_mrg_crmacct_parent_id boolean DEFAULT false NOT NULL,
    crmacctsel_mrg_crmacct_partner_id boolean DEFAULT false NOT NULL,
    crmacctsel_mrg_crmacct_prospect_id boolean DEFAULT false NOT NULL,
    crmacctsel_mrg_crmacct_salesrep_id boolean DEFAULT false NOT NULL,
    crmacctsel_mrg_crmacct_taxauth_id boolean DEFAULT false NOT NULL,
    crmacctsel_mrg_crmacct_type boolean DEFAULT false NOT NULL,
    crmacctsel_mrg_crmacct_usr_username boolean DEFAULT false NOT NULL,
    crmacctsel_mrg_crmacct_vend_id boolean DEFAULT false NOT NULL,
    crmacctsel_mrg_crmacct_number boolean DEFAULT false NOT NULL
);


ALTER TABLE public.crmacctsel OWNER TO admin;

--
-- TOC entry 9723 (class 0 OID 0)
-- Dependencies: 544
-- Name: TABLE crmacctsel; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE crmacctsel IS 'This table records the proposed conditions of a CRM Account merge. When this merge is performed, the BOOLEAN columns in this table indicate which values in the crmacct table will be copied to the target record. Data in this table are temporary and will be removed by a purge.';


--
-- TOC entry 9724 (class 0 OID 0)
-- Dependencies: 544
-- Name: COLUMN crmacctsel.crmacctsel_src_crmacct_id; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN crmacctsel.crmacctsel_src_crmacct_id IS 'This is the internal ID of the CRM Account record the data will come from during the merge.';


--
-- TOC entry 9725 (class 0 OID 0)
-- Dependencies: 544
-- Name: COLUMN crmacctsel.crmacctsel_dest_crmacct_id; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN crmacctsel.crmacctsel_dest_crmacct_id IS 'This is the internal ID of the CRM Account record the data will go to during the merge. If crmacctsel_src_crmacct_id = crmacctsel_dest_crmacct_id, they indicate which crmacct record is the destination of the merge, meaning this is the record that will remain in the database after the merge has been completed and the intermediate data have been purged.';


--
-- TOC entry 545 (class 1259 OID 146568890)
-- Dependencies: 6434 8
-- Name: curr_rate; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE curr_rate (
    curr_rate_id integer NOT NULL,
    curr_id integer NOT NULL,
    curr_rate numeric(16,8) NOT NULL,
    curr_effective date NOT NULL,
    curr_expires date NOT NULL,
    CONSTRAINT curr_rate_curr_rate_check CHECK ((curr_rate > (0)::numeric))
);


ALTER TABLE public.curr_rate OWNER TO admin;


--
-- TOC entry 546 (class 1259 OID 146568894)
-- Dependencies: 545 8
-- Name: curr_rate_curr_rate_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE curr_rate_curr_rate_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.curr_rate_curr_rate_id_seq OWNER TO admin;

--
-- TOC entry 9729 (class 0 OID 0)
-- Dependencies: 546
-- Name: curr_rate_curr_rate_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE curr_rate_curr_rate_id_seq OWNED BY curr_rate.curr_rate_id;


--
-- TOC entry 547 (class 1259 OID 146568896)
-- Dependencies: 208 8
-- Name: curr_symbol_curr_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE curr_symbol_curr_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.curr_symbol_curr_id_seq OWNER TO admin;

--
-- TOC entry 9731 (class 0 OID 0)
-- Dependencies: 547
-- Name: curr_symbol_curr_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE curr_symbol_curr_id_seq OWNED BY curr_symbol.curr_id;


--
-- TOC entry 549 (class 1259 OID 146568903)
-- Dependencies: 8
-- Name: cust_serial_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE cust_serial_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.cust_serial_seq OWNER TO admin;

--
-- TOC entry 550 (class 1259 OID 146568905)
-- Dependencies: 6435 8
-- Name: custform; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE custform (
    custform_id integer DEFAULT nextval(('"custform_custform_id_seq"'::text)::regclass) NOT NULL,
    custform_custtype_id integer,
    custform_custtype text,
    custform_invoice_report_id integer,
    custform_creditmemo_report_id integer,
    custform_quote_report_id integer,
    custform_packinglist_report_id integer,
    custform_statement_report_id integer,
    custform_sopicklist_report_id integer,
    custform_invoice_report_name text,
    custform_creditmemo_report_name text,
    custform_quote_report_name text,
    custform_packinglist_report_name text,
    custform_statement_report_name text,
    custform_sopicklist_report_name text
);


ALTER TABLE public.custform OWNER TO admin;

--
-- TOC entry 9735 (class 0 OID 0)
-- Dependencies: 550
-- Name: TABLE custform; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE custform IS 'Customer Form assignment information';


--
-- TOC entry 9736 (class 0 OID 0)
-- Dependencies: 550
-- Name: COLUMN custform.custform_invoice_report_id; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN custform.custform_invoice_report_id IS 'Obsolete -- reference custform_invoice_report_name instead.';


--
-- TOC entry 9737 (class 0 OID 0)
-- Dependencies: 550
-- Name: COLUMN custform.custform_creditmemo_report_id; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN custform.custform_creditmemo_report_id IS 'Obsolete -- reference custform_creditmemo_report_name instead.';


--
-- TOC entry 9738 (class 0 OID 0)
-- Dependencies: 550
-- Name: COLUMN custform.custform_quote_report_id; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN custform.custform_quote_report_id IS 'Obsolete -- reference custform_quote_report_name instead.';


--
-- TOC entry 9739 (class 0 OID 0)
-- Dependencies: 550
-- Name: COLUMN custform.custform_packinglist_report_id; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN custform.custform_packinglist_report_id IS 'Obsolete -- reference custform_packinglist_report_name instead.';


--
-- TOC entry 9740 (class 0 OID 0)
-- Dependencies: 550
-- Name: COLUMN custform.custform_statement_report_id; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN custform.custform_statement_report_id IS 'Obsolete -- reference custform_statement_report_name instead.';


--
-- TOC entry 9741 (class 0 OID 0)
-- Dependencies: 550
-- Name: COLUMN custform.custform_sopicklist_report_id; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN custform.custform_sopicklist_report_id IS 'Obsolete -- reference custform_sopicklist_report_name instead.';


--
-- TOC entry 551 (class 1259 OID 146568912)
-- Dependencies: 8
-- Name: custform_custform_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE custform_custform_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.custform_custform_id_seq OWNER TO admin;

--
-- TOC entry 552 (class 1259 OID 146568914)
-- Dependencies: 6436 6437 8
-- Name: custgrp; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE custgrp (
    custgrp_id integer DEFAULT nextval(('"custgrp_custgrp_id_seq"'::text)::regclass) NOT NULL,
    custgrp_name text NOT NULL,
    custgrp_descrip text,
    CONSTRAINT custgrp_custgrp_name_check CHECK ((custgrp_name <> ''::text))
);


ALTER TABLE public.custgrp OWNER TO admin;

--
-- TOC entry 9744 (class 0 OID 0)
-- Dependencies: 552
-- Name: TABLE custgrp; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE custgrp IS 'Customer Group information';


--
-- TOC entry 553 (class 1259 OID 146568922)
-- Dependencies: 8
-- Name: custgrp_custgrp_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE custgrp_custgrp_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.custgrp_custgrp_id_seq OWNER TO admin;

--
-- TOC entry 554 (class 1259 OID 146568924)
-- Dependencies: 6438 8
-- Name: custgrpitem; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE custgrpitem (
    custgrpitem_id integer DEFAULT nextval(('"custgrpitem_custgrpitem_id_seq"'::text)::regclass) NOT NULL,
    custgrpitem_custgrp_id integer,
    custgrpitem_cust_id integer
);


ALTER TABLE public.custgrpitem OWNER TO admin;

--
-- TOC entry 9747 (class 0 OID 0)
-- Dependencies: 554
-- Name: TABLE custgrpitem; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE custgrpitem IS 'Customer Group Item information';


--
-- TOC entry 555 (class 1259 OID 146568928)
-- Dependencies: 8
-- Name: custgrpitem_custgrpitem_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE custgrpitem_custgrpitem_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.custgrpitem_custgrpitem_id_seq OWNER TO admin;

--
-- TOC entry 556 (class 1259 OID 146568930)
-- Dependencies: 8
-- Name: custtype_custtype_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE custtype_custtype_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.custtype_custtype_id_seq OWNER TO admin;

--
-- TOC entry 557 (class 1259 OID 146568932)
-- Dependencies: 291 8
-- Name: dept_dept_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE dept_dept_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.dept_dept_id_seq OWNER TO admin;

--
-- TOC entry 9751 (class 0 OID 0)
-- Dependencies: 557
-- Name: dept_dept_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE dept_dept_id_seq OWNED BY dept.dept_id;


--
-- TOC entry 558 (class 1259 OID 146568934)
-- Dependencies: 6439 8
-- Name: destination; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE destination (
    destination_id integer DEFAULT nextval(('"destination_destination_id_seq"'::text)::regclass) NOT NULL,
    destination_name text,
    destination_city text,
    destination_state text,
    destination_comments text
);


ALTER TABLE public.destination OWNER TO admin;

--
-- TOC entry 9753 (class 0 OID 0)
-- Dependencies: 558
-- Name: TABLE destination; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE destination IS 'Destination information';


--
-- TOC entry 559 (class 1259 OID 146568941)
-- Dependencies: 8
-- Name: destination_destination_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE destination_destination_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.destination_destination_id_seq OWNER TO admin;

--
-- TOC entry 560 (class 1259 OID 146568943)
-- Dependencies: 6440 6441 6442 6443 6444 6445 6446 6447 6448 8
-- Name: wo; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE wo (
    wo_id integer DEFAULT nextval(('wo_wo_id_seq'::text)::regclass) NOT NULL,
    wo_number integer,
    wo_subnumber integer,
    wo_status character(1),
    wo_itemsite_id integer,
    wo_startdate date,
    wo_duedate date,
    wo_ordtype character(1),
    wo_ordid integer,
    wo_qtyord numeric(18,6),
    wo_qtyrcv numeric(18,6),
    wo_adhoc boolean,
    wo_itemcfg_series integer,
    wo_imported boolean,
    wo_wipvalue numeric(16,6) DEFAULT 0,
    wo_postedvalue numeric(16,6) DEFAULT 0,
    wo_prodnotes text,
    wo_prj_id integer,
    wo_priority integer DEFAULT 1 NOT NULL,
    wo_brdvalue numeric(16,6) DEFAULT 0,
    wo_bom_rev_id integer DEFAULT (-1),
    wo_boo_rev_id integer DEFAULT (-1),
    wo_cosmethod character(1),
    wo_womatl_id integer,
    wo_username text DEFAULT geteffectivextuser(),
    CONSTRAINT chk_wo_cosmethod CHECK ((((wo_cosmethod = NULL::bpchar) OR (wo_cosmethod = 'D'::bpchar)) OR (wo_cosmethod = 'P'::bpchar)))
);


ALTER TABLE public.wo OWNER TO admin;


--
-- TOC entry 562 (class 1259 OID 146568963)
-- Dependencies: 292 8
-- Name: emp_emp_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE emp_emp_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.emp_emp_id_seq OWNER TO admin;

--
-- TOC entry 9759 (class 0 OID 0)
-- Dependencies: 562
-- Name: emp_emp_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE emp_emp_id_seq OWNED BY emp.emp_id;


--
-- TOC entry 563 (class 1259 OID 146568965)
-- Dependencies: 6450 8
-- Name: empgrp; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE empgrp (
    empgrp_id integer NOT NULL,
    empgrp_name text NOT NULL,
    empgrp_descrip text NOT NULL,
    CONSTRAINT empgrp_empgrp_name_check CHECK ((empgrp_name <> ''::text))
);


ALTER TABLE public.empgrp OWNER TO admin;

--
-- TOC entry 564 (class 1259 OID 146568972)
-- Dependencies: 563 8
-- Name: empgrp_empgrp_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE empgrp_empgrp_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.empgrp_empgrp_id_seq OWNER TO admin;

--
-- TOC entry 9762 (class 0 OID 0)
-- Dependencies: 564
-- Name: empgrp_empgrp_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE empgrp_empgrp_id_seq OWNED BY empgrp.empgrp_id;


--
-- TOC entry 565 (class 1259 OID 146568974)
-- Dependencies: 8
-- Name: empgrpitem; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE empgrpitem (
    empgrpitem_id integer NOT NULL,
    empgrpitem_empgrp_id integer NOT NULL,
    empgrpitem_emp_id integer NOT NULL
);


ALTER TABLE public.empgrpitem OWNER TO admin;

--
-- TOC entry 566 (class 1259 OID 146568977)
-- Dependencies: 565 8
-- Name: empgrpitem_empgrpitem_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE empgrpitem_empgrpitem_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.empgrpitem_empgrpitem_id_seq OWNER TO admin;

--
-- TOC entry 9765 (class 0 OID 0)
-- Dependencies: 566
-- Name: empgrpitem_empgrpitem_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE empgrpitem_empgrpitem_id_seq OWNED BY empgrpitem.empgrpitem_id;


--
-- TOC entry 567 (class 1259 OID 146568979)
-- Dependencies: 6452 8
-- Name: evntlog; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE evntlog (
    evntlog_id integer DEFAULT nextval(('evntlog_evntlog_id_seq'::text)::regclass) NOT NULL,
    evntlog_evnttime timestamp with time zone,
    evntlog_evnttype_id integer,
    evntlog_ord_id integer,
    evntlog_dispatched timestamp with time zone,
    evntlog_action text,
    evntlog_warehous_id integer,
    evntlog_number text,
    evntlog_newvalue numeric(20,10),
    evntlog_oldvalue numeric(20,10),
    evntlog_newdate date,
    evntlog_olddate date,
    evntlog_ordtype character(2),
    evntlog_username text
);


ALTER TABLE public.evntlog OWNER TO admin;

--
-- TOC entry 9767 (class 0 OID 0)
-- Dependencies: 567
-- Name: TABLE evntlog; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE evntlog IS 'Event Notification history';


--
-- TOC entry 568 (class 1259 OID 146568986)
-- Dependencies: 8
-- Name: evntlog_evntlog_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE evntlog_evntlog_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.evntlog_evntlog_id_seq OWNER TO admin;

--
-- TOC entry 569 (class 1259 OID 146568988)
-- Dependencies: 6453 8
-- Name: evntnot; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE evntnot (
    evntnot_id integer DEFAULT nextval(('evntnot_evntnot_id_seq'::text)::regclass) NOT NULL,
    evntnot_evnttype_id integer,
    evntnot_warehous_id integer,
    evntnot_username text
);


ALTER TABLE public.evntnot OWNER TO admin;

--
-- TOC entry 9770 (class 0 OID 0)
-- Dependencies: 569
-- Name: TABLE evntnot; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE evntnot IS 'Temporary table for storing information about user Event Notification selections';


--
-- TOC entry 570 (class 1259 OID 146568995)
-- Dependencies: 8
-- Name: evntnot_evntnot_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE evntnot_evntnot_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.evntnot_evntnot_id_seq OWNER TO admin;

--
-- TOC entry 571 (class 1259 OID 146568997)
-- Dependencies: 6454 6455 8
-- Name: evnttype; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE evnttype (
    evnttype_id integer DEFAULT nextval(('evnttype_evnttype_id_seq'::text)::regclass) NOT NULL,
    evnttype_name text NOT NULL,
    evnttype_descrip text,
    evnttype_module text,
    CONSTRAINT evnttype_evnttype_name_check CHECK ((evnttype_name <> ''::text))
);


ALTER TABLE public.evnttype OWNER TO admin;

--
-- TOC entry 9773 (class 0 OID 0)
-- Dependencies: 571
-- Name: TABLE evnttype; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE evnttype IS 'Event Type information';


--
-- TOC entry 572 (class 1259 OID 146569005)
-- Dependencies: 8
-- Name: evnttype_evnttype_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE evnttype_evnttype_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.evnttype_evnttype_id_seq OWNER TO admin;

--
-- TOC entry 573 (class 1259 OID 146569007)
-- Dependencies: 358 8
-- Name: expcat_expcat_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE expcat_expcat_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.expcat_expcat_id_seq OWNER TO admin;

--
-- TOC entry 9776 (class 0 OID 0)
-- Dependencies: 573
-- Name: expcat_expcat_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE expcat_expcat_id_seq OWNED BY expcat.expcat_id;


--
-- TOC entry 574 (class 1259 OID 146569009)
-- Dependencies: 243 8
-- Name: file_file_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE file_file_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.file_file_id_seq OWNER TO admin;

--
-- TOC entry 9778 (class 0 OID 0)
-- Dependencies: 574
-- Name: file_file_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE file_file_id_seq OWNED BY file.file_id;


--
-- TOC entry 575 (class 1259 OID 146569011)
-- Dependencies: 6457 8
-- Name: filter; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE filter (
    filter_id integer NOT NULL,
    filter_screen text NOT NULL,
    filter_value text NOT NULL,
    filter_username text,
    filter_name text NOT NULL,
    filter_selected boolean DEFAULT false
);


ALTER TABLE public.filter OWNER TO admin;

--
-- TOC entry 576 (class 1259 OID 146569018)
-- Dependencies: 575 8
-- Name: filter_filter_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE filter_filter_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.filter_filter_id_seq OWNER TO admin;

--
-- TOC entry 9781 (class 0 OID 0)
-- Dependencies: 576
-- Name: filter_filter_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE filter_filter_id_seq OWNED BY filter.filter_id;


--
-- TOC entry 577 (class 1259 OID 146569020)
-- Dependencies: 8
-- Name: fincharg; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE fincharg (
    fincharg_id integer NOT NULL,
    fincharg_mincharg numeric NOT NULL,
    fincharg_graceperiod integer NOT NULL,
    fincharg_assessoverdue boolean NOT NULL,
    fincharg_calcfrom integer NOT NULL,
    fincharg_markoninvoice text NOT NULL,
    fincharg_air numeric NOT NULL,
    fincharg_accnt_id integer NOT NULL,
    fincharg_salescat_id integer NOT NULL,
    fincharg_lastfc_statementcyclefrom text,
    fincharg_lastfc_custidfrom text,
    fincharg_lastfc_custidto text,
    fincharg_lastfc_statementcycleto text
);


ALTER TABLE public.fincharg OWNER TO admin;

--
-- TOC entry 9783 (class 0 OID 0)
-- Dependencies: 577
-- Name: TABLE fincharg; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE fincharg IS 'Finance Charge configuration information';


--
-- TOC entry 578 (class 1259 OID 146569026)
-- Dependencies: 577 8
-- Name: fincharg_fincharg_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE fincharg_fincharg_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.fincharg_fincharg_id_seq OWNER TO admin;

--
-- TOC entry 9785 (class 0 OID 0)
-- Dependencies: 578
-- Name: fincharg_fincharg_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE fincharg_fincharg_id_seq OWNED BY fincharg.fincharg_id;


--
-- TOC entry 579 (class 1259 OID 146569028)
-- Dependencies: 6459 6460 6461 6462 6463 6464 6465 6466 6467 6468 6469 6470 6471 6472 6473 6474 6475 6476 6478 8
-- Name: flhead; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE flhead (
    flhead_id integer NOT NULL,
    flhead_name text NOT NULL,
    flhead_descrip text,
    flhead_showtotal boolean DEFAULT false NOT NULL,
    flhead_showstart boolean DEFAULT true NOT NULL,
    flhead_showend boolean DEFAULT true NOT NULL,
    flhead_showdelta boolean DEFAULT true NOT NULL,
    flhead_showbudget boolean DEFAULT true NOT NULL,
    flhead_showdiff boolean DEFAULT false NOT NULL,
    flhead_showcustom boolean DEFAULT false NOT NULL,
    flhead_custom_label text,
    flhead_usealttotal boolean DEFAULT false NOT NULL,
    flhead_alttotal text,
    flhead_usealtbegin boolean DEFAULT false NOT NULL,
    flhead_altbegin text,
    flhead_usealtend boolean DEFAULT false NOT NULL,
    flhead_altend text,
    flhead_usealtdebits boolean DEFAULT false NOT NULL,
    flhead_altdebits text,
    flhead_usealtcredits boolean DEFAULT false NOT NULL,
    flhead_altcredits text,
    flhead_usealtbudget boolean DEFAULT false NOT NULL,
    flhead_altbudget text,
    flhead_usealtdiff boolean DEFAULT false NOT NULL,
    flhead_altdiff text,
    flhead_type character(1) DEFAULT 'A'::bpchar NOT NULL,
    flhead_active boolean DEFAULT true NOT NULL,
    flhead_sys boolean DEFAULT false,
    flhead_notes text DEFAULT ''::text,
    CONSTRAINT flhead_flhead_name_check CHECK ((flhead_name <> ''::text))
);


ALTER TABLE public.flhead OWNER TO admin;

--
-- TOC entry 9787 (class 0 OID 0)
-- Dependencies: 579
-- Name: TABLE flhead; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE flhead IS 'Financial Layout header information';


--
-- TOC entry 580 (class 1259 OID 146569053)
-- Dependencies: 6479 6480 6481 6482 6483 6484 6485 6486 6487 6488 6489 8
-- Name: flitem; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE flitem (
    flitem_id integer NOT NULL,
    flitem_flhead_id integer,
    flitem_flgrp_id integer,
    flitem_order integer,
    flitem_accnt_id integer,
    flitem_showstart boolean,
    flitem_showend boolean,
    flitem_showdelta boolean,
    flitem_showbudget boolean DEFAULT false NOT NULL,
    flitem_subtract boolean DEFAULT false NOT NULL,
    flitem_showstartprcnt boolean DEFAULT false NOT NULL,
    flitem_showendprcnt boolean DEFAULT false NOT NULL,
    flitem_showdeltaprcnt boolean DEFAULT false NOT NULL,
    flitem_showbudgetprcnt boolean DEFAULT false NOT NULL,
    flitem_prcnt_flgrp_id integer DEFAULT (-1) NOT NULL,
    flitem_showdiff boolean DEFAULT false NOT NULL,
    flitem_showdiffprcnt boolean DEFAULT false NOT NULL,
    flitem_showcustom boolean DEFAULT false NOT NULL,
    flitem_showcustomprcnt boolean DEFAULT false NOT NULL,
    flitem_custom_source character(1),
    flitem_company text,
    flitem_profit text,
    flitem_number text,
    flitem_sub text,
    flitem_type character(1),
    flitem_subaccnttype_code text
);


ALTER TABLE public.flitem OWNER TO admin;

--
-- TOC entry 9789 (class 0 OID 0)
-- Dependencies: 580
-- Name: TABLE flitem; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE flitem IS 'Financial Layout Account information';


--
-- TOC entry 582 (class 1259 OID 146569075)
-- Dependencies: 8
-- Name: flcol; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE flcol (
    flcol_id integer NOT NULL,
    flcol_flhead_id integer NOT NULL,
    flcol_name text,
    flcol_descrip text,
    flcol_report_id integer,
    flcol_month boolean,
    flcol_quarter boolean,
    flcol_year boolean,
    flcol_showdb boolean,
    flcol_prcnt boolean,
    flcol_priortype character(1),
    flcol_priormonth boolean,
    flcol_priorquarter boolean,
    flcol_prioryear character(1),
    flcol_priorprcnt boolean,
    flcol_priordiff boolean,
    flcol_priordiffprcnt boolean,
    flcol_budget boolean,
    flcol_budgetprcnt boolean,
    flcol_budgetdiff boolean,
    flcol_budgetdiffprcnt boolean
);


ALTER TABLE public.flcol OWNER TO admin;

--
-- TOC entry 583 (class 1259 OID 146569081)
-- Dependencies: 582 8
-- Name: flcol_flcol_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE flcol_flcol_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.flcol_flcol_id_seq OWNER TO admin;

--
-- TOC entry 9793 (class 0 OID 0)
-- Dependencies: 583
-- Name: flcol_flcol_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE flcol_flcol_id_seq OWNED BY flcol.flcol_id;


--
-- TOC entry 584 (class 1259 OID 146569083)
-- Dependencies: 6492 6493 6494 6495 6496 6497 6498 6499 6500 6501 6502 6503 6504 6505 6506 6507 6508 8
-- Name: flgrp; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE flgrp (
    flgrp_id integer NOT NULL,
    flgrp_flhead_id integer,
    flgrp_flgrp_id integer,
    flgrp_order integer,
    flgrp_name text,
    flgrp_descrip text,
    flgrp_subtotal boolean DEFAULT false NOT NULL,
    flgrp_summarize boolean DEFAULT false NOT NULL,
    flgrp_subtract boolean DEFAULT false NOT NULL,
    flgrp_showstart boolean DEFAULT true NOT NULL,
    flgrp_showend boolean DEFAULT true NOT NULL,
    flgrp_showdelta boolean DEFAULT true NOT NULL,
    flgrp_showbudget boolean DEFAULT true NOT NULL,
    flgrp_showstartprcnt boolean DEFAULT false NOT NULL,
    flgrp_showendprcnt boolean DEFAULT false NOT NULL,
    flgrp_showdeltaprcnt boolean DEFAULT false NOT NULL,
    flgrp_showbudgetprcnt boolean DEFAULT false NOT NULL,
    flgrp_prcnt_flgrp_id integer DEFAULT (-1) NOT NULL,
    flgrp_showdiff boolean DEFAULT false NOT NULL,
    flgrp_showdiffprcnt boolean DEFAULT false NOT NULL,
    flgrp_showcustom boolean DEFAULT false NOT NULL,
    flgrp_showcustomprcnt boolean DEFAULT false NOT NULL,
    flgrp_usealtsubtotal boolean DEFAULT false NOT NULL,
    flgrp_altsubtotal text
);


ALTER TABLE public.flgrp OWNER TO admin;

--
-- TOC entry 9795 (class 0 OID 0)
-- Dependencies: 584
-- Name: TABLE flgrp; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE flgrp IS 'Financial Layout Group information';


--
-- TOC entry 585 (class 1259 OID 146569106)
-- Dependencies: 584 8
-- Name: flgrp_flgrp_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE flgrp_flgrp_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.flgrp_flgrp_id_seq OWNER TO admin;

--
-- TOC entry 9797 (class 0 OID 0)
-- Dependencies: 585
-- Name: flgrp_flgrp_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE flgrp_flgrp_id_seq OWNED BY flgrp.flgrp_id;


--
-- TOC entry 586 (class 1259 OID 146569108)
-- Dependencies: 579 8
-- Name: flhead_flhead_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE flhead_flhead_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.flhead_flhead_id_seq OWNER TO admin;

--
-- TOC entry 9799 (class 0 OID 0)
-- Dependencies: 586
-- Name: flhead_flhead_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE flhead_flhead_id_seq OWNED BY flhead.flhead_id;


--
-- TOC entry 587 (class 1259 OID 146569110)
-- Dependencies: 580 8
-- Name: flitem_flitem_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE flitem_flitem_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.flitem_flitem_id_seq OWNER TO admin;

--
-- TOC entry 9801 (class 0 OID 0)
-- Dependencies: 587
-- Name: flitem_flitem_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE flitem_flitem_id_seq OWNED BY flitem.flitem_id;


--
-- TOC entry 588 (class 1259 OID 146569112)
-- Dependencies: 6511 8
-- Name: flnotes; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE flnotes (
    flnotes_id integer NOT NULL,
    flnotes_flhead_id integer,
    flnotes_period_id integer,
    flnotes_notes text DEFAULT ''::text
);


ALTER TABLE public.flnotes OWNER TO admin;

--
-- TOC entry 589 (class 1259 OID 146569119)
-- Dependencies: 588 8
-- Name: flnotes_flnotes_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE flnotes_flnotes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.flnotes_flnotes_id_seq OWNER TO admin;

--
-- TOC entry 9804 (class 0 OID 0)
-- Dependencies: 589
-- Name: flnotes_flnotes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE flnotes_flnotes_id_seq OWNED BY flnotes.flnotes_id;


--
-- TOC entry 590 (class 1259 OID 146569121)
-- Dependencies: 8
-- Name: flrpt; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE flrpt (
    flrpt_flhead_id integer NOT NULL,
    flrpt_period_id integer NOT NULL,
    flrpt_username text NOT NULL,
    flrpt_order integer NOT NULL,
    flrpt_level integer NOT NULL,
    flrpt_type text NOT NULL,
    flrpt_type_id integer NOT NULL,
    flrpt_beginning numeric,
    flrpt_ending numeric,
    flrpt_debits numeric,
    flrpt_credits numeric,
    flrpt_budget numeric,
    flrpt_beginningprcnt numeric,
    flrpt_endingprcnt numeric,
    flrpt_debitsprcnt numeric,
    flrpt_creditsprcnt numeric,
    flrpt_budgetprcnt numeric,
    flrpt_parent_id integer,
    flrpt_diff numeric,
    flrpt_diffprcnt numeric,
    flrpt_custom numeric,
    flrpt_customprcnt numeric,
    flrpt_altname text,
    flrpt_accnt_id integer,
    flrpt_interval character(1),
    flrpt_id integer NOT NULL
);


ALTER TABLE public.flrpt OWNER TO admin;

--
-- TOC entry 9806 (class 0 OID 0)
-- Dependencies: 590
-- Name: TABLE flrpt; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE flrpt IS 'Scratch table where financial reporting information is processed before being displayed.';


--
-- TOC entry 591 (class 1259 OID 146569127)
-- Dependencies: 590 8
-- Name: flrpt_flrpt_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE flrpt_flrpt_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.flrpt_flrpt_id_seq OWNER TO admin;

--
-- TOC entry 9808 (class 0 OID 0)
-- Dependencies: 591
-- Name: flrpt_flrpt_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE flrpt_flrpt_id_seq OWNED BY flrpt.flrpt_id;


--
-- TOC entry 592 (class 1259 OID 146569129)
-- Dependencies: 6513 6514 6515 6516 6517 6518 6519 6520 6521 6522 6523 6524 6525 6526 8
-- Name: flspec; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE flspec (
    flspec_id integer NOT NULL,
    flspec_flhead_id integer NOT NULL,
    flspec_flgrp_id integer NOT NULL,
    flspec_order integer NOT NULL,
    flspec_name text,
    flspec_type text,
    flspec_showstart boolean DEFAULT true NOT NULL,
    flspec_showend boolean DEFAULT true NOT NULL,
    flspec_showdelta boolean DEFAULT true NOT NULL,
    flspec_showbudget boolean DEFAULT false NOT NULL,
    flspec_subtract boolean DEFAULT false NOT NULL,
    flspec_showstartprcnt boolean DEFAULT false NOT NULL,
    flspec_showendprcnt boolean DEFAULT false NOT NULL,
    flspec_showdeltaprcnt boolean DEFAULT false NOT NULL,
    flspec_showbudgetprcnt boolean DEFAULT false NOT NULL,
    flspec_showdiff boolean DEFAULT false NOT NULL,
    flspec_showdiffprcnt boolean DEFAULT false NOT NULL,
    flspec_prcnt_flgrp_id integer DEFAULT (-1) NOT NULL,
    flspec_showcustom boolean DEFAULT false NOT NULL,
    flspec_showcustomprcnt boolean DEFAULT false NOT NULL,
    flspec_custom_source character(1)
);


ALTER TABLE public.flspec OWNER TO admin;

--
-- TOC entry 9810 (class 0 OID 0)
-- Dependencies: 592
-- Name: TABLE flspec; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE flspec IS 'Financial Layout Special entries.';


--
-- TOC entry 593 (class 1259 OID 146569149)
-- Dependencies: 592 8
-- Name: flspec_flspec_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE flspec_flspec_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.flspec_flspec_id_seq OWNER TO admin;

--
-- TOC entry 9812 (class 0 OID 0)
-- Dependencies: 593
-- Name: flspec_flspec_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE flspec_flspec_id_seq OWNED BY flspec.flspec_id;


--
-- TOC entry 594 (class 1259 OID 146569151)
-- Dependencies: 6528 6529 8
-- Name: form; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE form (
    form_id integer DEFAULT nextval(('"form_form_id_seq"'::text)::regclass) NOT NULL,
    form_name text NOT NULL,
    form_descrip text,
    form_report_id integer,
    form_key character varying(4),
    form_report_name text,
    CONSTRAINT form_form_name_check CHECK ((form_name <> ''::text))
);


ALTER TABLE public.form OWNER TO admin;

--
-- TOC entry 9814 (class 0 OID 0)
-- Dependencies: 594
-- Name: TABLE form; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE form IS 'Form information';


--
-- TOC entry 9815 (class 0 OID 0)
-- Dependencies: 594
-- Name: COLUMN form.form_report_id; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN form.form_report_id IS 'Obsolete -- reference form_report_name instead.';


--
-- TOC entry 595 (class 1259 OID 146569159)
-- Dependencies: 8
-- Name: form_form_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE form_form_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.form_form_id_seq OWNER TO admin;

--
-- TOC entry 596 (class 1259 OID 146569161)
-- Dependencies: 299 8
-- Name: freightclass_freightclass_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE freightclass_freightclass_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.freightclass_freightclass_id_seq OWNER TO admin;

--
-- TOC entry 9818 (class 0 OID 0)
-- Dependencies: 596
-- Name: freightclass_freightclass_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE freightclass_freightclass_id_seq OWNED BY freightclass.freightclass_id;


--
-- TOC entry 597 (class 1259 OID 146569163)
-- Dependencies: 6530 8
-- Name: glseries; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE glseries (
    glseries_id integer DEFAULT nextval(('"glseries_glseries_id_seq"'::text)::regclass) NOT NULL,
    glseries_sequence integer,
    glseries_doctype character(2),
    glseries_docnumber text,
    glseries_accnt_id integer,
    glseries_amount numeric(20,2),
    glseries_source text,
    glseries_distdate date,
    glseries_notes text,
    glseries_misc_id integer
);


ALTER TABLE public.glseries OWNER TO admin;

--
-- TOC entry 9820 (class 0 OID 0)
-- Dependencies: 597
-- Name: TABLE glseries; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE glseries IS 'Temporary table for storing information about General Ledger (G/L) Series Entries before Series Entries are posted';


--
-- TOC entry 598 (class 1259 OID 146569170)
-- Dependencies: 8
-- Name: glseries_glseries_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE glseries_glseries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.glseries_glseries_id_seq OWNER TO admin;

--
-- TOC entry 599 (class 1259 OID 146569172)
-- Dependencies: 8
-- Name: gltrans_gltrans_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE gltrans_gltrans_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.gltrans_gltrans_id_seq OWNER TO admin;

--
-- TOC entry 600 (class 1259 OID 146569174)
-- Dependencies: 8
-- Name: gltrans_sequence_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE gltrans_sequence_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.gltrans_sequence_seq OWNER TO admin;

--
-- TOC entry 601 (class 1259 OID 146569176)
-- Dependencies: 6532 8
-- Name: grp; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE grp (
    grp_id integer NOT NULL,
    grp_name text NOT NULL,
    grp_descrip text,
    CONSTRAINT grp_grp_name_check CHECK ((grp_name <> ''::text))
);


ALTER TABLE public.grp OWNER TO admin;

--
-- TOC entry 9825 (class 0 OID 0)
-- Dependencies: 601
-- Name: TABLE grp; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE grp IS 'This table is the basic group information.';


--
-- TOC entry 602 (class 1259 OID 146569183)
-- Dependencies: 601 8
-- Name: grp_grp_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE grp_grp_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.grp_grp_id_seq OWNER TO admin;

--
-- TOC entry 9827 (class 0 OID 0)
-- Dependencies: 602
-- Name: grp_grp_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE grp_grp_id_seq OWNED BY grp.grp_id;


--
-- TOC entry 603 (class 1259 OID 146569185)
-- Dependencies: 8
-- Name: grppriv; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE grppriv (
    grppriv_id integer NOT NULL,
    grppriv_grp_id integer NOT NULL,
    grppriv_priv_id integer NOT NULL
);


ALTER TABLE public.grppriv OWNER TO admin;

--
-- TOC entry 9829 (class 0 OID 0)
-- Dependencies: 603
-- Name: TABLE grppriv; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE grppriv IS 'This is a specific priv for a specific group.';


--
-- TOC entry 604 (class 1259 OID 146569188)
-- Dependencies: 603 8
-- Name: grppriv_grppriv_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE grppriv_grppriv_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.grppriv_grppriv_id_seq OWNER TO admin;

--
-- TOC entry 9831 (class 0 OID 0)
-- Dependencies: 604
-- Name: grppriv_grppriv_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE grppriv_grppriv_id_seq OWNED BY grppriv.grppriv_id;


--
-- TOC entry 605 (class 1259 OID 146569190)
-- Dependencies: 6535 8
-- Name: hnfc; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE hnfc (
    hnfc_id integer NOT NULL,
    hnfc_code text NOT NULL,
    CONSTRAINT hnfc_hnfc_code_check CHECK ((hnfc_code <> ''::text))
);


ALTER TABLE public.hnfc OWNER TO admin;

--
-- TOC entry 9833 (class 0 OID 0)
-- Dependencies: 605
-- Name: TABLE hnfc; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE hnfc IS 'List of personal titles/honorifics used in cntct table.';


--
-- TOC entry 606 (class 1259 OID 146569197)
-- Dependencies: 605 8
-- Name: hnfc_hnfc_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE hnfc_hnfc_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.hnfc_hnfc_id_seq OWNER TO admin;

--
-- TOC entry 9835 (class 0 OID 0)
-- Dependencies: 606
-- Name: hnfc_hnfc_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE hnfc_hnfc_id_seq OWNED BY hnfc.hnfc_id;


--
-- TOC entry 607 (class 1259 OID 146569199)
-- Dependencies: 206 8
-- Name: incdt_incdt_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE incdt_incdt_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.incdt_incdt_id_seq OWNER TO admin;

--
-- TOC entry 9837 (class 0 OID 0)
-- Dependencies: 607
-- Name: incdt_incdt_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE incdt_incdt_id_seq OWNED BY incdt.incdt_id;


--
-- TOC entry 608 (class 1259 OID 146569201)
-- Dependencies: 304 8
-- Name: incdtcat_incdtcat_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE incdtcat_incdtcat_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.incdtcat_incdtcat_id_seq OWNER TO admin;

--
-- TOC entry 9839 (class 0 OID 0)
-- Dependencies: 608
-- Name: incdtcat_incdtcat_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE incdtcat_incdtcat_id_seq OWNED BY incdtcat.incdtcat_id;


--
-- TOC entry 609 (class 1259 OID 146569203)
-- Dependencies: 6537 6538 8
-- Name: incdthist; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE incdthist (
    incdthist_id integer NOT NULL,
    incdthist_incdt_id integer NOT NULL,
    incdthist_change character(1),
    incdthist_target_id integer,
    incdthist_timestamp timestamp without time zone DEFAULT now() NOT NULL,
    incdthist_username text DEFAULT geteffectivextuser() NOT NULL,
    incdthist_descrip text
);


ALTER TABLE public.incdthist OWNER TO admin;

--
-- TOC entry 9841 (class 0 OID 0)
-- Dependencies: 609
-- Name: TABLE incdthist; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE incdthist IS 'Incident history changes';


--
-- TOC entry 610 (class 1259 OID 146569211)
-- Dependencies: 609 8
-- Name: incdthist_incdthist_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE incdthist_incdthist_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.incdthist_incdthist_id_seq OWNER TO admin;

--
-- TOC entry 9843 (class 0 OID 0)
-- Dependencies: 610
-- Name: incdthist_incdthist_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE incdthist_incdthist_id_seq OWNED BY incdthist.incdthist_id;


--
-- TOC entry 611 (class 1259 OID 146569213)
-- Dependencies: 305 8
-- Name: incdtpriority_incdtpriority_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE incdtpriority_incdtpriority_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.incdtpriority_incdtpriority_id_seq OWNER TO admin;

--
-- TOC entry 9845 (class 0 OID 0)
-- Dependencies: 611
-- Name: incdtpriority_incdtpriority_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE incdtpriority_incdtpriority_id_seq OWNED BY incdtpriority.incdtpriority_id;


--
-- TOC entry 612 (class 1259 OID 146569215)
-- Dependencies: 306 8
-- Name: incdtresolution_incdtresolution_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE incdtresolution_incdtresolution_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.incdtresolution_incdtresolution_id_seq OWNER TO admin;

--
-- TOC entry 9847 (class 0 OID 0)
-- Dependencies: 612
-- Name: incdtresolution_incdtresolution_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE incdtresolution_incdtresolution_id_seq OWNED BY incdtresolution.incdtresolution_id;


--
-- TOC entry 613 (class 1259 OID 146569217)
-- Dependencies: 307 8
-- Name: incdtseverity_incdtseverity_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE incdtseverity_incdtseverity_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.incdtseverity_incdtseverity_id_seq OWNER TO admin;

--
-- TOC entry 9849 (class 0 OID 0)
-- Dependencies: 613
-- Name: incdtseverity_incdtseverity_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE incdtseverity_incdtseverity_id_seq OWNED BY incdtseverity.incdtseverity_id;


--
-- TOC entry 614 (class 1259 OID 146569219)
-- Dependencies: 202 8
-- Name: invbal_invbal_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE invbal_invbal_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.invbal_invbal_id_seq OWNER TO admin;

--
-- TOC entry 9851 (class 0 OID 0)
-- Dependencies: 614
-- Name: invbal_invbal_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE invbal_invbal_id_seq OWNED BY invbal.invbal_id;


--
-- TOC entry 615 (class 1259 OID 146569221)
-- Dependencies: 8
-- Name: invc_invc_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE invc_invc_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.invc_invc_id_seq OWNER TO admin;

--
-- TOC entry 616 (class 1259 OID 146569223)
-- Dependencies: 224 8
-- Name: invchead_invchead_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE invchead_invchead_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.invchead_invchead_id_seq OWNER TO admin;

--
-- TOC entry 9854 (class 0 OID 0)
-- Dependencies: 616
-- Name: invchead_invchead_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE invchead_invchead_id_seq OWNED BY invchead.invchead_id;


--
-- TOC entry 617 (class 1259 OID 146569225)
-- Dependencies: 377 8
-- Name: invcheadtax; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE invcheadtax (
)
INHERITS (taxhist);


ALTER TABLE public.invcheadtax OWNER TO admin;

--
-- TOC entry 618 (class 1259 OID 146569231)
-- Dependencies: 229 8
-- Name: invcitem_invcitem_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE invcitem_invcitem_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.invcitem_invcitem_id_seq OWNER TO admin;

--
-- TOC entry 9857 (class 0 OID 0)
-- Dependencies: 618
-- Name: invcitem_invcitem_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE invcitem_invcitem_id_seq OWNED BY invcitem.invcitem_id;


--
-- TOC entry 619 (class 1259 OID 146569233)
-- Dependencies: 377 8
-- Name: invcitemtax; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE invcitemtax (
)
INHERITS (taxhist);


ALTER TABLE public.invcitemtax OWNER TO admin;

--
-- TOC entry 620 (class 1259 OID 146569239)
-- Dependencies: 8
-- Name: invcnt_invcnt_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE invcnt_invcnt_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.invcnt_invcnt_id_seq OWNER TO admin;

--
-- TOC entry 621 (class 1259 OID 146569241)
-- Dependencies: 6541 8
-- Name: invdetail; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE invdetail (
    invdetail_id integer DEFAULT nextval(('"invdetail_invdetail_id_seq"'::text)::regclass) NOT NULL,
    invdetail_transtype character(2),
    invdetail_invhist_id integer,
    invdetail_location_id integer,
    invdetail_qty numeric(18,6),
    invdetail_comments text,
    invdetail_qty_before numeric(18,6),
    invdetail_qty_after numeric(18,6),
    invdetail_invcitem_id integer,
    invdetail_expiration date,
    invdetail_warrpurc date,
    invdetail_ls_id integer
);


ALTER TABLE public.invdetail OWNER TO admin;

--
-- TOC entry 9861 (class 0 OID 0)
-- Dependencies: 621
-- Name: TABLE invdetail; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE invdetail IS 'Detailed Inventory transaction information for Lot/Serial and Multiple Location Control (MLC) Items';


--
-- TOC entry 622 (class 1259 OID 146569248)
-- Dependencies: 8
-- Name: invdetail_invdetail_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE invdetail_invdetail_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.invdetail_invdetail_id_seq OWNER TO admin;

--
-- TOC entry 623 (class 1259 OID 146569250)
-- Dependencies: 6542 6543 6544 6545 6546 6547 6548 8
-- Name: invhist; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE invhist (
    invhist_id integer DEFAULT nextval(('invhist_invhist_id_seq'::text)::regclass) NOT NULL,
    invhist_itemsite_id integer,
    invhist_transdate timestamp with time zone DEFAULT ('now'::text)::timestamp(6) with time zone,
    invhist_transtype character(2),
    invhist_invqty numeric(18,6),
    invhist_invuom text,
    invhist_ordnumber text,
    invhist_docnumber text,
    invhist_qoh_before numeric(18,6),
    invhist_qoh_after numeric(18,6),
    invhist_unitcost numeric(16,6),
    invhist_acct_id integer,
    invhist_xfer_warehous_id integer,
    invhist_comments text,
    invhist_posted boolean DEFAULT true,
    invhist_imported boolean,
    invhist_hasdetail boolean DEFAULT false,
    invhist_ordtype text,
    invhist_analyze boolean DEFAULT true,
    invhist_user text DEFAULT geteffectivextuser(),
    invhist_created timestamp with time zone DEFAULT now() NOT NULL,
    invhist_costmethod character(1) NOT NULL,
    invhist_value_before numeric(12,2) NOT NULL,
    invhist_value_after numeric(12,2) NOT NULL,
    invhist_series integer
);


ALTER TABLE public.invhist OWNER TO admin;

--
-- TOC entry 9864 (class 0 OID 0)
-- Dependencies: 623
-- Name: TABLE invhist; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE invhist IS 'Inventory transaction history';


--
-- TOC entry 624 (class 1259 OID 146569263)
-- Dependencies: 8
-- Name: invhist_invhist_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE invhist_invhist_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.invhist_invhist_id_seq OWNER TO admin;

--
-- TOC entry 625 (class 1259 OID 146569265)
-- Dependencies: 8
-- Name: invhistexpcat; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE invhistexpcat (
    invhistexpcat_id integer NOT NULL,
    invhistexpcat_invhist_id integer NOT NULL,
    invhistexpcat_expcat_id integer NOT NULL
);


ALTER TABLE public.invhistexpcat OWNER TO admin;

--
-- TOC entry 9867 (class 0 OID 0)
-- Dependencies: 625
-- Name: TABLE invhistexpcat; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE invhistexpcat IS 'Track the relationship between an EX transaction in the invhist table and the corresponding Expense Category.';


--
-- TOC entry 626 (class 1259 OID 146569268)
-- Dependencies: 625 8
-- Name: invhistexpcat_invhistexpcat_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE invhistexpcat_invhistexpcat_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.invhistexpcat_invhistexpcat_id_seq OWNER TO admin;

--
-- TOC entry 9869 (class 0 OID 0)
-- Dependencies: 626
-- Name: invhistexpcat_invhistexpcat_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE invhistexpcat_invhistexpcat_id_seq OWNED BY invhistexpcat.invhistexpcat_id;


--
-- TOC entry 628 (class 1259 OID 146569275)
-- Dependencies: 347 8
-- Name: ipsass_ipsass_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE ipsass_ipsass_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ipsass_ipsass_id_seq OWNER TO admin;

--
-- TOC entry 9873 (class 0 OID 0)
-- Dependencies: 628
-- Name: ipsass_ipsass_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE ipsass_ipsass_id_seq OWNED BY ipsass.ipsass_id;


--
-- TOC entry 629 (class 1259 OID 146569277)
-- Dependencies: 8
-- Name: ipsctyp_ipsctyp_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE ipsctyp_ipsctyp_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ipsctyp_ipsctyp_id_seq OWNER TO admin;

--
-- TOC entry 630 (class 1259 OID 146569279)
-- Dependencies: 8
-- Name: ipscust_ipscust_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE ipscust_ipscust_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ipscust_ipscust_id_seq OWNER TO admin;

--
-- TOC entry 631 (class 1259 OID 146569281)
-- Dependencies: 300 8
-- Name: ipsfreight_ipsfreight_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE ipsfreight_ipsfreight_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ipsfreight_ipsfreight_id_seq OWNER TO admin;

--
-- TOC entry 9877 (class 0 OID 0)
-- Dependencies: 631
-- Name: ipsfreight_ipsfreight_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE ipsfreight_ipsfreight_id_seq OWNED BY ipsfreight.ipsfreight_id;


--
-- TOC entry 632 (class 1259 OID 146569283)
-- Dependencies: 8
-- Name: ipshead_ipshead_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE ipshead_ipshead_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ipshead_ipshead_id_seq OWNER TO admin;

--
-- TOC entry 633 (class 1259 OID 146569285)
-- Dependencies: 8
-- Name: ipsitem_ipsitem_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE ipsitem_ipsitem_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ipsitem_ipsitem_id_seq OWNER TO admin;

--
-- TOC entry 634 (class 1259 OID 146569287)
-- Dependencies: 351 8
-- Name: ipsitemchar_ipsitemchar_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE ipsitemchar_ipsitemchar_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ipsitemchar_ipsitemchar_id_seq OWNER TO admin;

--
-- TOC entry 9881 (class 0 OID 0)
-- Dependencies: 634
-- Name: ipsitemchar_ipsitemchar_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE ipsitemchar_ipsitemchar_id_seq OWNED BY ipsitemchar.ipsitemchar_id;


--
-- TOC entry 636 (class 1259 OID 146569294)
-- Dependencies: 6551 8
-- Name: ipsprodcat_bak; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE ipsprodcat_bak (
    ipsprodcat_id integer NOT NULL,
    ipsprodcat_ipshead_id integer NOT NULL,
    ipsprodcat_prodcat_id integer NOT NULL,
    ipsprodcat_qtybreak numeric(18,6) NOT NULL,
    ipsprodcat_discntprcnt numeric(10,6) NOT NULL,
    ipsprodcat_fixedamtdiscount numeric(16,4) DEFAULT 0.00 NOT NULL
);


ALTER TABLE public.ipsprodcat_bak OWNER TO admin;

--
-- TOC entry 9884 (class 0 OID 0)
-- Dependencies: 636
-- Name: TABLE ipsprodcat_bak; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE ipsprodcat_bak IS 'Pricing Schedule Product Category information.';


--
-- TOC entry 637 (class 1259 OID 146569298)
-- Dependencies: 636 8
-- Name: ipsprodcat_ipsprodcat_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE ipsprodcat_ipsprodcat_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ipsprodcat_ipsprodcat_id_seq OWNER TO admin;

--
-- TOC entry 9886 (class 0 OID 0)
-- Dependencies: 637
-- Name: ipsprodcat_ipsprodcat_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE ipsprodcat_ipsprodcat_id_seq OWNED BY ipsprodcat_bak.ipsprodcat_id;


--
-- TOC entry 638 (class 1259 OID 146569300)
-- Dependencies: 8
-- Name: item_item_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE item_item_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.item_item_id_seq OWNER TO admin;

--
-- TOC entry 639 (class 1259 OID 146569302)
-- Dependencies: 8
-- Name: itemalias_itemalias_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE itemalias_itemalias_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.itemalias_itemalias_id_seq OWNER TO admin;

--
-- TOC entry 640 (class 1259 OID 146569304)
-- Dependencies: 8
-- Name: itematr_itematr_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE itematr_itematr_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.itematr_itematr_id_seq OWNER TO admin;

--
-- TOC entry 641 (class 1259 OID 146569306)
-- Dependencies: 8
-- Name: itemcost_itemcost_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE itemcost_itemcost_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.itemcost_itemcost_id_seq OWNER TO admin;

--
-- TOC entry 642 (class 1259 OID 146569308)
-- Dependencies: 8
-- Name: itemfrez_itemfrez_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE itemfrez_itemfrez_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.itemfrez_itemfrez_seq OWNER TO admin;

--
-- TOC entry 643 (class 1259 OID 146569310)
-- Dependencies: 6552 6553 6554 8
-- Name: itemgrp; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE itemgrp (
    itemgrp_id integer DEFAULT nextval(('"itemgrp_itemgrp_id_seq"'::text)::regclass) NOT NULL,
    itemgrp_name text NOT NULL,
    itemgrp_descrip text,
    itemgrp_catalog boolean DEFAULT false NOT NULL,
    CONSTRAINT itemgrp_itemgrp_name_check CHECK ((itemgrp_name <> ''::text))
);


ALTER TABLE public.itemgrp OWNER TO admin;

--
-- TOC entry 9893 (class 0 OID 0)
-- Dependencies: 643
-- Name: TABLE itemgrp; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE itemgrp IS 'Item Group information';


--
-- TOC entry 644 (class 1259 OID 146569319)
-- Dependencies: 8
-- Name: itemgrp_itemgrp_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE itemgrp_itemgrp_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.itemgrp_itemgrp_id_seq OWNER TO admin;

--
-- TOC entry 645 (class 1259 OID 146569321)
-- Dependencies: 6555 6556 6557 8
-- Name: itemgrpitem; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE itemgrpitem (
    itemgrpitem_id integer DEFAULT nextval(('"itemgrpitem_itemgrpitem_id_seq"'::text)::regclass) NOT NULL,
    itemgrpitem_itemgrp_id integer,
    itemgrpitem_item_id integer,
    itemgrpitem_item_type character(1) DEFAULT 'I'::bpchar NOT NULL,
    CONSTRAINT itemgrpitem_valid_item_type CHECK ((itemgrpitem_item_type = ANY (ARRAY['I'::bpchar, 'G'::bpchar])))
);


ALTER TABLE public.itemgrpitem OWNER TO admin;

--
-- TOC entry 9896 (class 0 OID 0)
-- Dependencies: 645
-- Name: TABLE itemgrpitem; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE itemgrpitem IS 'Item Group Item information';


--
-- TOC entry 646 (class 1259 OID 146569327)
-- Dependencies: 8
-- Name: itemgrpitem_itemgrpitem_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE itemgrpitem_itemgrpitem_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.itemgrpitem_itemgrpitem_id_seq OWNER TO admin;


--
-- TOC entry 648 (class 1259 OID 146569333)
-- Dependencies: 8
-- Name: itemimage_itemimage_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE itemimage_itemimage_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.itemimage_itemimage_id_seq OWNER TO admin;

--
-- TOC entry 649 (class 1259 OID 146569335)
-- Dependencies: 6558 8
-- Name: itemloc; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE itemloc (
    itemloc_id integer DEFAULT nextval(('"itemloc_itemloc_id_seq"'::text)::regclass) NOT NULL,
    itemloc_itemsite_id integer NOT NULL,
    itemloc_location_id integer NOT NULL,
    itemloc_qty numeric(18,6) NOT NULL,
    itemloc_expiration date NOT NULL,
    itemloc_consolflag boolean,
    itemloc_ls_id integer,
    itemloc_warrpurc date
);


ALTER TABLE public.itemloc OWNER TO admin;

--
-- TOC entry 9902 (class 0 OID 0)
-- Dependencies: 649
-- Name: TABLE itemloc; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE itemloc IS 'Detailed Location information for Lot/Serial and Multiple Location Control (MLC) Items';


--
-- TOC entry 650 (class 1259 OID 146569339)
-- Dependencies: 8
-- Name: itemloc_itemloc_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE itemloc_itemloc_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.itemloc_itemloc_id_seq OWNER TO admin;

--
-- TOC entry 651 (class 1259 OID 146569341)
-- Dependencies: 8
-- Name: itemloc_series_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE itemloc_series_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.itemloc_series_seq OWNER TO admin;

--
-- TOC entry 652 (class 1259 OID 146569343)
-- Dependencies: 6559 6560 6561 8
-- Name: itemlocdist; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE itemlocdist (
    itemlocdist_id integer DEFAULT nextval(('"itemlocdist_itemlocdist_id_seq"'::text)::regclass) NOT NULL,
    itemlocdist_itemlocdist_id integer,
    itemlocdist_source_type character(1),
    itemlocdist_source_id integer,
    itemlocdist_qty numeric(18,6),
    itemlocdist_series integer,
    itemlocdist_invhist_id integer,
    itemlocdist_itemsite_id integer,
    itemlocdist_reqlotserial boolean DEFAULT false,
    itemlocdist_flush boolean DEFAULT false,
    itemlocdist_expiration date,
    itemlocdist_distlotserial boolean,
    itemlocdist_warranty date,
    itemlocdist_ls_id integer,
    itemlocdist_order_type text,
    itemlocdist_order_id integer
);


ALTER TABLE public.itemlocdist OWNER TO admin;


--
-- TOC entry 653 (class 1259 OID 146569352)
-- Dependencies: 8
-- Name: itemlocdist_itemlocdist_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE itemlocdist_itemlocdist_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.itemlocdist_itemlocdist_id_seq OWNER TO admin;

--
-- TOC entry 654 (class 1259 OID 146569354)
-- Dependencies: 8
-- Name: itemlocpost; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE itemlocpost (
    itemlocpost_id integer NOT NULL,
    itemlocpost_itemlocseries integer,
    itemlocpost_glseq integer
);


ALTER TABLE public.itemlocpost OWNER TO admin;

--
-- TOC entry 9909 (class 0 OID 0)
-- Dependencies: 654
-- Name: TABLE itemlocpost; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE itemlocpost IS 'Temporary table for storing information about Inventory distribution G/L postings involving Lot/Serial and Multiple Location Control (MLC) Items';


--
-- TOC entry 655 (class 1259 OID 146569357)
-- Dependencies: 654 8
-- Name: itemlocpost_itemlocpost_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE itemlocpost_itemlocpost_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.itemlocpost_itemlocpost_id_seq OWNER TO admin;

--
-- TOC entry 9911 (class 0 OID 0)
-- Dependencies: 655
-- Name: itemlocpost_itemlocpost_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE itemlocpost_itemlocpost_id_seq OWNED BY itemlocpost.itemlocpost_id;


--
-- TOC entry 656 (class 1259 OID 146569359)
-- Dependencies: 8
-- Name: itemopn_itemopn_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE itemopn_itemopn_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.itemopn_itemopn_id_seq OWNER TO admin;

--
-- TOC entry 657 (class 1259 OID 146569361)
-- Dependencies: 8
-- Name: itemsite_itemsite_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE itemsite_itemsite_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.itemsite_itemsite_id_seq OWNER TO admin;

--
-- TOC entry 658 (class 1259 OID 146569363)
-- Dependencies: 8
-- Name: itemsrc_itemsrc_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE itemsrc_itemsrc_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.itemsrc_itemsrc_id_seq OWNER TO admin;

--
-- TOC entry 659 (class 1259 OID 146569365)
-- Dependencies: 8
-- Name: itemsrcp_itemsrcp_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE itemsrcp_itemsrcp_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.itemsrcp_itemsrcp_id_seq OWNER TO admin;

--
-- TOC entry 660 (class 1259 OID 146569367)
-- Dependencies: 8
-- Name: itemsub_itemsub_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE itemsub_itemsub_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.itemsub_itemsub_id_seq OWNER TO admin;

--
-- TOC entry 661 (class 1259 OID 146569369)
-- Dependencies: 336 8
-- Name: itemtax_itemtax_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE itemtax_itemtax_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.itemtax_itemtax_id_seq OWNER TO admin;

--
-- TOC entry 9918 (class 0 OID 0)
-- Dependencies: 661
-- Name: itemtax_itemtax_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE itemtax_itemtax_id_seq OWNED BY itemtax.itemtax_id;


--
-- TOC entry 662 (class 1259 OID 146569371)
-- Dependencies: 8
-- Name: itemtrans; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE itemtrans (
    itemtrans_id integer NOT NULL,
    itemtrans_source_item_id integer,
    itemtrans_target_item_id integer
);


ALTER TABLE public.itemtrans OWNER TO admin;

--
-- TOC entry 9920 (class 0 OID 0)
-- Dependencies: 662
-- Name: TABLE itemtrans; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE itemtrans IS 'Item Transformation information';


--
-- TOC entry 663 (class 1259 OID 146569374)
-- Dependencies: 662 8
-- Name: itemtrans_itemtrans_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE itemtrans_itemtrans_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.itemtrans_itemtrans_id_seq OWNER TO admin;

--
-- TOC entry 9922 (class 0 OID 0)
-- Dependencies: 663
-- Name: itemtrans_itemtrans_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE itemtrans_itemtrans_id_seq OWNED BY itemtrans.itemtrans_id;


--
-- TOC entry 664 (class 1259 OID 146569376)
-- Dependencies: 8
-- Name: itemuom; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE itemuom (
    itemuom_id integer NOT NULL,
    itemuom_itemuomconv_id integer NOT NULL,
    itemuom_uomtype_id integer NOT NULL
);


ALTER TABLE public.itemuom OWNER TO admin;

--
-- TOC entry 9924 (class 0 OID 0)
-- Dependencies: 664
-- Name: TABLE itemuom; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE itemuom IS 'A UOM type relation for a specific conversion.';


--
-- TOC entry 665 (class 1259 OID 146569379)
-- Dependencies: 664 8
-- Name: itemuom_itemuom_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE itemuom_itemuom_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.itemuom_itemuom_id_seq OWNER TO admin;

--
-- TOC entry 9926 (class 0 OID 0)
-- Dependencies: 665
-- Name: itemuom_itemuom_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE itemuom_itemuom_id_seq OWNED BY itemuom.itemuom_id;


--
-- TOC entry 666 (class 1259 OID 146569381)
-- Dependencies: 338 8
-- Name: itemuomconv_itemuomconv_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE itemuomconv_itemuomconv_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.itemuomconv_itemuomconv_id_seq OWNER TO admin;

--
-- TOC entry 9928 (class 0 OID 0)
-- Dependencies: 666
-- Name: itemuomconv_itemuomconv_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE itemuomconv_itemuomconv_id_seq OWNED BY itemuomconv.itemuomconv_id;


--
-- TOC entry 667 (class 1259 OID 146569383)
-- Dependencies: 8
-- Name: journal_number_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE journal_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.journal_number_seq OWNER TO admin;

--
-- TOC entry 668 (class 1259 OID 146569385)
-- Dependencies: 6565 8
-- Name: jrnluse; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE jrnluse (
    jrnluse_id integer DEFAULT nextval(('"jrnluse_jrnluse_id_seq"'::text)::regclass) NOT NULL,
    jrnluse_date timestamp without time zone,
    jrnluse_number integer,
    jrnluse_use text
);


ALTER TABLE public.jrnluse OWNER TO admin;

--
-- TOC entry 9931 (class 0 OID 0)
-- Dependencies: 668
-- Name: TABLE jrnluse; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE jrnluse IS 'Journal entry and use information';


--
-- TOC entry 669 (class 1259 OID 146569392)
-- Dependencies: 8
-- Name: jrnluse_jrnluse_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE jrnluse_jrnluse_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.jrnluse_jrnluse_id_seq OWNER TO admin;

--
-- TOC entry 670 (class 1259 OID 146569394)
-- Dependencies: 8
-- Name: labeldef; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE labeldef (
    labeldef_id integer NOT NULL,
    labeldef_name text NOT NULL,
    labeldef_papersize text NOT NULL,
    labeldef_columns integer NOT NULL,
    labeldef_rows integer NOT NULL,
    labeldef_width integer NOT NULL,
    labeldef_height integer NOT NULL,
    labeldef_start_offset_x integer NOT NULL,
    labeldef_start_offset_y integer NOT NULL,
    labeldef_horizontal_gap integer NOT NULL,
    labeldef_vertical_gap integer NOT NULL
);


ALTER TABLE public.labeldef OWNER TO admin;

--
-- TOC entry 671 (class 1259 OID 146569400)
-- Dependencies: 670 8
-- Name: labeldef_labeldef_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE labeldef_labeldef_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.labeldef_labeldef_id_seq OWNER TO admin;

--
-- TOC entry 9935 (class 0 OID 0)
-- Dependencies: 671
-- Name: labeldef_labeldef_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE labeldef_labeldef_id_seq OWNED BY labeldef.labeldef_id;


--
-- TOC entry 672 (class 1259 OID 146569402)
-- Dependencies: 6567 6568 8
-- Name: labelform; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE labelform (
    labelform_id integer DEFAULT nextval(('"labelform_labelform_id_seq"'::text)::regclass) NOT NULL,
    labelform_name text NOT NULL,
    labelform_report_id integer,
    labelform_perpage integer,
    labelform_report_name text,
    CONSTRAINT labelform_labelform_name_check CHECK ((labelform_name <> ''::text))
);


ALTER TABLE public.labelform OWNER TO admin;

--
-- TOC entry 9937 (class 0 OID 0)
-- Dependencies: 672
-- Name: TABLE labelform; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE labelform IS 'Label Form information';


--
-- TOC entry 9938 (class 0 OID 0)
-- Dependencies: 672
-- Name: COLUMN labelform.labelform_report_id; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN labelform.labelform_report_id IS 'Obsolete -- reference labelform_report_name instead.';


--
-- TOC entry 673 (class 1259 OID 146569410)
-- Dependencies: 8
-- Name: labelform_labelform_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE labelform_labelform_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.labelform_labelform_id_seq OWNER TO admin;

--
-- TOC entry 674 (class 1259 OID 146569412)
-- Dependencies: 8
-- Name: lang; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE lang (
    lang_id integer NOT NULL,
    lang_qt_number integer,
    lang_abbr3 text,
    lang_abbr2 text,
    lang_name text NOT NULL
);


ALTER TABLE public.lang OWNER TO admin;

--
-- TOC entry 9941 (class 0 OID 0)
-- Dependencies: 674
-- Name: TABLE lang; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE lang IS 'Table mapping ISO 639-1 and 639-2 language codes to Qt''s enum QLocale::Language integer values. See http://www.loc.gov/standards/iso639-2/php/code_list.php and the QLocale documentation..';


--
-- TOC entry 9942 (class 0 OID 0)
-- Dependencies: 674
-- Name: COLUMN lang.lang_abbr3; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN lang.lang_abbr3 IS 'ISO 639-2 code for language. Where there is a choice between bibliographic (B) and terminology (T) usage, this value is the T code';


--
-- TOC entry 9943 (class 0 OID 0)
-- Dependencies: 674
-- Name: COLUMN lang.lang_abbr2; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN lang.lang_abbr2 IS 'ISO 639-1 code for language';


--
-- TOC entry 9944 (class 0 OID 0)
-- Dependencies: 674
-- Name: COLUMN lang.lang_name; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN lang.lang_name IS 'Name of a human language, taken from the ISO 639-2 documentation';


--
-- TOC entry 675 (class 1259 OID 146569418)
-- Dependencies: 674 8
-- Name: lang_lang_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE lang_lang_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.lang_lang_id_seq OWNER TO admin;

--
-- TOC entry 9946 (class 0 OID 0)
-- Dependencies: 675
-- Name: lang_lang_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE lang_lang_id_seq OWNED BY lang.lang_id;


--
-- TOC entry 676 (class 1259 OID 146569420)
-- Dependencies: 6570 6571 6572 6573 8
-- Name: locale; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE locale (
    locale_id integer DEFAULT nextval(('locale_locale_id_seq'::text)::regclass) NOT NULL,
    locale_code text NOT NULL,
    locale_descrip text,
    locale_lang_file text,
    locale_dateformat text,
    locale_currformat text,
    locale_qtyformat text,
    locale_comments text,
    locale_qtyperformat text,
    locale_salespriceformat text,
    locale_extpriceformat text,
    locale_timeformat text,
    locale_timestampformat text,
    local_costformat text,
    locale_costformat text,
    locale_purchpriceformat text,
    locale_uomratioformat text,
    locale_intervalformat text,
    locale_lang_id integer,
    locale_country_id integer,
    locale_error_color text,
    locale_warning_color text,
    locale_emphasis_color text,
    locale_altemphasis_color text,
    locale_expired_color text,
    locale_future_color text,
    locale_curr_scale integer,
    locale_salesprice_scale integer,
    locale_purchprice_scale integer,
    locale_extprice_scale integer,
    locale_cost_scale integer,
    locale_qty_scale integer,
    locale_qtyper_scale integer,
    locale_uomratio_scale integer,
    locale_percent_scale integer DEFAULT 2,
    locale_weight_scale integer DEFAULT 2 NOT NULL,
    CONSTRAINT locale_locale_code_check CHECK ((locale_code <> ''::text))
);


ALTER TABLE public.locale OWNER TO admin;

--
-- TOC entry 9948 (class 0 OID 0)
-- Dependencies: 676
-- Name: TABLE locale; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE locale IS 'The locale table holds information required to show data to the user in a localized format. Colors are either names documented by the WWW Consortium or RGB colors. Format for RGB colors is #RGB, #RRGGBB, or #RRRGGGBBB, where the letters R, G, and B stand for hexidecimal digits.';


--
-- TOC entry 9949 (class 0 OID 0)
-- Dependencies: 676
-- Name: COLUMN locale.locale_lang_file; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN locale.locale_lang_file IS 'Deprecated';


--
-- TOC entry 9950 (class 0 OID 0)
-- Dependencies: 676
-- Name: COLUMN locale.locale_dateformat; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN locale.locale_dateformat IS 'Deprecated';


--
-- TOC entry 9951 (class 0 OID 0)
-- Dependencies: 676
-- Name: COLUMN locale.locale_currformat; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN locale.locale_currformat IS 'Deprecated';


--
-- TOC entry 9952 (class 0 OID 0)
-- Dependencies: 676
-- Name: COLUMN locale.locale_qtyformat; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN locale.locale_qtyformat IS 'Deprecated';


--
-- TOC entry 9953 (class 0 OID 0)
-- Dependencies: 676
-- Name: COLUMN locale.locale_qtyperformat; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN locale.locale_qtyperformat IS 'Deprecated';


--
-- TOC entry 9954 (class 0 OID 0)
-- Dependencies: 676
-- Name: COLUMN locale.locale_salespriceformat; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN locale.locale_salespriceformat IS 'Deprecated';


--
-- TOC entry 9955 (class 0 OID 0)
-- Dependencies: 676
-- Name: COLUMN locale.locale_extpriceformat; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN locale.locale_extpriceformat IS 'Deprecated';


--
-- TOC entry 9956 (class 0 OID 0)
-- Dependencies: 676
-- Name: COLUMN locale.locale_timeformat; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN locale.locale_timeformat IS 'Deprecated';


--
-- TOC entry 9957 (class 0 OID 0)
-- Dependencies: 676
-- Name: COLUMN locale.locale_timestampformat; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN locale.locale_timestampformat IS 'Deprecated';


--
-- TOC entry 9958 (class 0 OID 0)
-- Dependencies: 676
-- Name: COLUMN locale.local_costformat; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN locale.local_costformat IS 'Deprecated';


--
-- TOC entry 9959 (class 0 OID 0)
-- Dependencies: 676
-- Name: COLUMN locale.locale_costformat; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN locale.locale_costformat IS 'Deprecated';


--
-- TOC entry 9960 (class 0 OID 0)
-- Dependencies: 676
-- Name: COLUMN locale.locale_purchpriceformat; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN locale.locale_purchpriceformat IS 'Deprecated';


--
-- TOC entry 9961 (class 0 OID 0)
-- Dependencies: 676
-- Name: COLUMN locale.locale_uomratioformat; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN locale.locale_uomratioformat IS 'Deprecated';


--
-- TOC entry 9962 (class 0 OID 0)
-- Dependencies: 676
-- Name: COLUMN locale.locale_intervalformat; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN locale.locale_intervalformat IS 'Deprecated';


--
-- TOC entry 9963 (class 0 OID 0)
-- Dependencies: 676
-- Name: COLUMN locale.locale_error_color; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN locale.locale_error_color IS 'Color to use to mark data that require immediate attention.';


--
-- TOC entry 9964 (class 0 OID 0)
-- Dependencies: 676
-- Name: COLUMN locale.locale_warning_color; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN locale.locale_warning_color IS 'Color to use to mark data that require attention soon.';


--
-- TOC entry 9965 (class 0 OID 0)
-- Dependencies: 676
-- Name: COLUMN locale.locale_emphasis_color; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN locale.locale_emphasis_color IS 'Color to use to mark data that need to stand out but are not in error.';


--
-- TOC entry 9966 (class 0 OID 0)
-- Dependencies: 676
-- Name: COLUMN locale.locale_altemphasis_color; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN locale.locale_altemphasis_color IS 'Color to use to mark data that need to stand out and be differentiated from other emphasized data.';


--
-- TOC entry 9967 (class 0 OID 0)
-- Dependencies: 676
-- Name: COLUMN locale.locale_expired_color; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN locale.locale_expired_color IS 'Color to use to mark data that are no longer current.';


--
-- TOC entry 9968 (class 0 OID 0)
-- Dependencies: 676
-- Name: COLUMN locale.locale_future_color; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN locale.locale_future_color IS 'Color to use to mark data that will not be effective until some point in the future.';


--
-- TOC entry 9969 (class 0 OID 0)
-- Dependencies: 676
-- Name: COLUMN locale.locale_curr_scale; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN locale.locale_curr_scale IS 'Number of decimal places to show when displaying Currency values.';


--
-- TOC entry 9970 (class 0 OID 0)
-- Dependencies: 676
-- Name: COLUMN locale.locale_salesprice_scale; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN locale.locale_salesprice_scale IS 'Number of decimal places to show when displaying Sales Prices.';


--
-- TOC entry 9971 (class 0 OID 0)
-- Dependencies: 676
-- Name: COLUMN locale.locale_purchprice_scale; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN locale.locale_purchprice_scale IS 'Number of decimal places to show when displaying Purchase Prices.';


--
-- TOC entry 9972 (class 0 OID 0)
-- Dependencies: 676
-- Name: COLUMN locale.locale_extprice_scale; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN locale.locale_extprice_scale IS 'Number of decimal places to show when displaying Extended Prices.';


--
-- TOC entry 9973 (class 0 OID 0)
-- Dependencies: 676
-- Name: COLUMN locale.locale_cost_scale; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN locale.locale_cost_scale IS 'Number of decimal places to show when displaying Costs.';


--
-- TOC entry 9974 (class 0 OID 0)
-- Dependencies: 676
-- Name: COLUMN locale.locale_qty_scale; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN locale.locale_qty_scale IS 'Number of decimal places to show when displaying Quantities.';


--
-- TOC entry 9975 (class 0 OID 0)
-- Dependencies: 676
-- Name: COLUMN locale.locale_qtyper_scale; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN locale.locale_qtyper_scale IS 'Number of decimal places to show when displaying Quantities Per.';


--
-- TOC entry 9976 (class 0 OID 0)
-- Dependencies: 676
-- Name: COLUMN locale.locale_uomratio_scale; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN locale.locale_uomratio_scale IS 'Number of decimal places to show when displaying UOM Ratios.';


--
-- TOC entry 677 (class 1259 OID 146569430)
-- Dependencies: 8
-- Name: locale_locale_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE locale_locale_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.locale_locale_id_seq OWNER TO admin;

--
-- TOC entry 678 (class 1259 OID 146569432)
-- Dependencies: 8
-- Name: location_location_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE location_location_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.location_location_id_seq OWNER TO admin;

--
-- TOC entry 679 (class 1259 OID 146569434)
-- Dependencies: 6574 8
-- Name: locitem; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE locitem (
    locitem_id integer DEFAULT nextval(('"locitem_locitem_id_seq"'::text)::regclass) NOT NULL,
    locitem_location_id integer,
    locitem_item_id integer
);


ALTER TABLE public.locitem OWNER TO admin;

--
-- TOC entry 9980 (class 0 OID 0)
-- Dependencies: 679
-- Name: TABLE locitem; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE locitem IS 'Restricted Warehouse Location Allowable Items information';


--
-- TOC entry 680 (class 1259 OID 146569438)
-- Dependencies: 8
-- Name: locitem_locitem_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE locitem_locitem_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.locitem_locitem_id_seq OWNER TO admin;

--
-- TOC entry 681 (class 1259 OID 146569440)
-- Dependencies: 8
-- Name: log_log_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE log_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.log_log_id_seq OWNER TO admin;

--
-- TOC entry 682 (class 1259 OID 146569442)
-- Dependencies: 6575 6576 8
-- Name: metric; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE metric (
    metric_id integer DEFAULT nextval(('metric_metric_id_seq'::text)::regclass) NOT NULL,
    metric_name text NOT NULL,
    metric_value text,
    metric_module text,
    CONSTRAINT metric_metric_name_check CHECK ((metric_name <> ''::text))
);


ALTER TABLE public.metric OWNER TO admin;

--
-- TOC entry 9984 (class 0 OID 0)
-- Dependencies: 682
-- Name: TABLE metric; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE metric IS 'Application-wide settings information';


--
-- TOC entry 683 (class 1259 OID 146569450)
-- Dependencies: 8
-- Name: metric_metric_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE metric_metric_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.metric_metric_id_seq OWNER TO admin;

--
-- TOC entry 684 (class 1259 OID 146569452)
-- Dependencies: 6578 8
-- Name: metricenc; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE metricenc (
    metricenc_id integer NOT NULL,
    metricenc_name text NOT NULL,
    metricenc_value bytea,
    metricenc_module text,
    CONSTRAINT metricenc_metricenc_name_check CHECK ((metricenc_name <> ''::text))
);


ALTER TABLE public.metricenc OWNER TO admin;

--
-- TOC entry 9987 (class 0 OID 0)
-- Dependencies: 684
-- Name: TABLE metricenc; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE metricenc IS 'Application-wide settings information encrypted data';


--
-- TOC entry 685 (class 1259 OID 146569459)
-- Dependencies: 684 8
-- Name: metricenc_metricenc_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE metricenc_metricenc_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.metricenc_metricenc_id_seq OWNER TO admin;

--
-- TOC entry 9989 (class 0 OID 0)
-- Dependencies: 685
-- Name: metricenc_metricenc_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE metricenc_metricenc_id_seq OWNED BY metricenc.metricenc_id;


--
-- TOC entry 686 (class 1259 OID 146569461)
-- Dependencies: 8
-- Name: misc_index_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE misc_index_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.misc_index_seq OWNER TO admin;

--
-- TOC entry 687 (class 1259 OID 146569463)
-- Dependencies: 8
-- Name: mrghist; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE mrghist (
    mrghist_cntct_id integer NOT NULL,
    mrghist_table text NOT NULL,
    mrghist_pkey_col text NOT NULL,
    mrghist_pkey_id integer NOT NULL,
    mrghist_cntct_col text NOT NULL
);


ALTER TABLE public.mrghist OWNER TO admin;

--
-- TOC entry 688 (class 1259 OID 146569469)
-- Dependencies: 8
-- Name: mrgundo; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE mrgundo (
    mrgundo_base_schema text,
    mrgundo_base_table text,
    mrgundo_base_id integer,
    mrgundo_schema text,
    mrgundo_table text,
    mrgundo_pkey_col text,
    mrgundo_pkey_id integer,
    mrgundo_col text,
    mrgundo_value text,
    mrgundo_type text
);


ALTER TABLE public.mrgundo OWNER TO admin;

--
-- TOC entry 9993 (class 0 OID 0)
-- Dependencies: 688
-- Name: TABLE mrgundo; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE mrgundo IS 'This table keeps track of the original values of changes made while merging two records. It is a generalization of mrghist and trgthist, which are specific to merging contacts. The schema, table, and pkey_id columns uniquely identify the record that was changed while the _base_ columns identify the merge target. The _base_ columns are required to allow finding all of the records that pertain to a particular merge (e.g. find changes to the comment table that pertain to a crmacct merge).';


--
-- TOC entry 9994 (class 0 OID 0)
-- Dependencies: 688
-- Name: COLUMN mrgundo.mrgundo_base_schema; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN mrgundo.mrgundo_base_schema IS 'The schema in which the merge target resides.';


--
-- TOC entry 9995 (class 0 OID 0)
-- Dependencies: 688
-- Name: COLUMN mrgundo.mrgundo_base_table; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN mrgundo.mrgundo_base_table IS 'The table in which the merge target resides.';


--
-- TOC entry 9996 (class 0 OID 0)
-- Dependencies: 688
-- Name: COLUMN mrgundo.mrgundo_base_id; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN mrgundo.mrgundo_base_id IS 'The internal id of the merge target record.';


--
-- TOC entry 9997 (class 0 OID 0)
-- Dependencies: 688
-- Name: COLUMN mrgundo.mrgundo_schema; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN mrgundo.mrgundo_schema IS 'The name of the schema in which the modified table resides.';


--
-- TOC entry 9998 (class 0 OID 0)
-- Dependencies: 688
-- Name: COLUMN mrgundo.mrgundo_table; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN mrgundo.mrgundo_table IS 'The name of the table that was modified during a merge.';


--
-- TOC entry 9999 (class 0 OID 0)
-- Dependencies: 688
-- Name: COLUMN mrgundo.mrgundo_pkey_col; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN mrgundo.mrgundo_pkey_col IS 'The name of the primary key column in the modified table. This could be derived during the undo processing but it is simpler just to store it during the merge.';


--
-- TOC entry 10000 (class 0 OID 0)
-- Dependencies: 688
-- Name: COLUMN mrgundo.mrgundo_pkey_id; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN mrgundo.mrgundo_pkey_id IS 'The primary key of the modified record.';


--
-- TOC entry 10001 (class 0 OID 0)
-- Dependencies: 688
-- Name: COLUMN mrgundo.mrgundo_col; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN mrgundo.mrgundo_col IS 'The column that was modified.';


--
-- TOC entry 10002 (class 0 OID 0)
-- Dependencies: 688
-- Name: COLUMN mrgundo.mrgundo_value; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN mrgundo.mrgundo_value IS 'The value of the column before the change.';


--
-- TOC entry 10003 (class 0 OID 0)
-- Dependencies: 688
-- Name: COLUMN mrgundo.mrgundo_type; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN mrgundo.mrgundo_type IS 'The data type of the modified column. This could be derived during the undo processing but it is simpler just to store it during the merge.';


--
-- TOC entry 689 (class 1259 OID 146569475)
-- Dependencies: 6579 8
-- Name: msg; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE msg (
    msg_id integer DEFAULT nextval(('"msg_msg_id_seq"'::text)::regclass) NOT NULL,
    msg_posted timestamp with time zone,
    msg_scheduled timestamp with time zone,
    msg_text text,
    msg_expires timestamp with time zone,
    msg_username text
);


ALTER TABLE public.msg OWNER TO admin;

--
-- TOC entry 10005 (class 0 OID 0)
-- Dependencies: 689
-- Name: TABLE msg; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE msg IS 'System Message information';


--
-- TOC entry 690 (class 1259 OID 146569482)
-- Dependencies: 8
-- Name: msg_msg_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE msg_msg_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.msg_msg_id_seq OWNER TO admin;

--
-- TOC entry 691 (class 1259 OID 146569484)
-- Dependencies: 6580 8
-- Name: msguser; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE msguser (
    msguser_id integer DEFAULT nextval(('"msguser_msguser_id_seq"'::text)::regclass) NOT NULL,
    msguser_msg_id integer,
    msguser_viewed timestamp with time zone,
    msguser_username text
);


ALTER TABLE public.msguser OWNER TO admin;

--
-- TOC entry 10008 (class 0 OID 0)
-- Dependencies: 691
-- Name: TABLE msguser; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE msguser IS 'System Message user information';


--
-- TOC entry 692 (class 1259 OID 146569491)
-- Dependencies: 8
-- Name: msguser_msguser_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE msguser_msguser_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.msguser_msguser_id_seq OWNER TO admin;

--
-- TOC entry 693 (class 1259 OID 146569493)
-- Dependencies: 8
-- Name: nvend_nvend_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE nvend_nvend_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.nvend_nvend_id_seq OWNER TO admin;


--
-- TOC entry 695 (class 1259 OID 146569504)
-- Dependencies: 231 8
-- Name: ophead_ophead_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE ophead_ophead_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ophead_ophead_id_seq OWNER TO admin;

--
-- TOC entry 10015 (class 0 OID 0)
-- Dependencies: 695
-- Name: ophead_ophead_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE ophead_ophead_id_seq OWNED BY ophead.ophead_id;


--
-- TOC entry 696 (class 1259 OID 146569506)
-- Dependencies: 6585 8
-- Name: opsource; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE opsource (
    opsource_id integer NOT NULL,
    opsource_name text NOT NULL,
    opsource_descrip text,
    CONSTRAINT opsource_opsource_name_check CHECK ((opsource_name <> ''::text))
);


ALTER TABLE public.opsource OWNER TO admin;

--
-- TOC entry 10017 (class 0 OID 0)
-- Dependencies: 696
-- Name: TABLE opsource; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE opsource IS 'Opportunity Lead Source values.';


--
-- TOC entry 697 (class 1259 OID 146569513)
-- Dependencies: 696 8
-- Name: opsource_opsource_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE opsource_opsource_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.opsource_opsource_id_seq OWNER TO admin;

--
-- TOC entry 10019 (class 0 OID 0)
-- Dependencies: 697
-- Name: opsource_opsource_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE opsource_opsource_id_seq OWNED BY opsource.opsource_id;


--
-- TOC entry 698 (class 1259 OID 146569515)
-- Dependencies: 6587 6588 6589 8
-- Name: opstage; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE opstage (
    opstage_id integer NOT NULL,
    opstage_name text NOT NULL,
    opstage_descrip text,
    opstage_order integer DEFAULT 0 NOT NULL,
    opstage_opinactive boolean DEFAULT false,
    CONSTRAINT opstage_opstage_name_check CHECK ((opstage_name <> ''::text))
);


ALTER TABLE public.opstage OWNER TO admin;

--
-- TOC entry 10021 (class 0 OID 0)
-- Dependencies: 698
-- Name: TABLE opstage; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE opstage IS 'Opportunity stage values.';


--
-- TOC entry 699 (class 1259 OID 146569524)
-- Dependencies: 698 8
-- Name: opstage_opstage_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE opstage_opstage_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.opstage_opstage_id_seq OWNER TO admin;

--
-- TOC entry 10023 (class 0 OID 0)
-- Dependencies: 699
-- Name: opstage_opstage_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE opstage_opstage_id_seq OWNED BY opstage.opstage_id;


--
-- TOC entry 700 (class 1259 OID 146569526)
-- Dependencies: 6591 8
-- Name: optype; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE optype (
    optype_id integer NOT NULL,
    optype_name text NOT NULL,
    optype_descrip text,
    CONSTRAINT optype_optype_name_check CHECK ((optype_name <> ''::text))
);


ALTER TABLE public.optype OWNER TO admin;

--
-- TOC entry 10025 (class 0 OID 0)
-- Dependencies: 700
-- Name: TABLE optype; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE optype IS 'Opportunity Type values.';


--
-- TOC entry 701 (class 1259 OID 146569533)
-- Dependencies: 700 8
-- Name: optype_optype_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE optype_optype_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.optype_optype_id_seq OWNER TO admin;

--
-- TOC entry 10027 (class 0 OID 0)
-- Dependencies: 701
-- Name: optype_optype_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE optype_optype_id_seq OWNED BY optype.optype_id;


--
-- TOC entry 704 (class 1259 OID 146569545)
-- Dependencies: 6592 6593 8 2700
-- Name: orderseq; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE orderseq (
    orderseq_id integer DEFAULT nextval(('orderseq_orderseq_id_seq'::text)::regclass) NOT NULL,
    orderseq_name text NOT NULL,
    orderseq_number integer,
    orderseq_table text,
    orderseq_numcol text,
    orderseq_seqiss seqiss[],
    CONSTRAINT orderseq_orderseq_name_check CHECK ((orderseq_name <> ''::text))
);


ALTER TABLE public.orderseq OWNER TO admin;

--
-- TOC entry 10033 (class 0 OID 0)
-- Dependencies: 704
-- Name: TABLE orderseq; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE orderseq IS 'Configuration information for common numbering sequences';


--
-- TOC entry 705 (class 1259 OID 146569553)
-- Dependencies: 8
-- Name: orderseq_orderseq_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE orderseq_orderseq_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.orderseq_orderseq_id_seq OWNER TO admin;

--
-- TOC entry 706 (class 1259 OID 146569555)
-- Dependencies: 6595 6596 8
-- Name: pack; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE pack (
    pack_id integer NOT NULL,
    pack_head_id integer NOT NULL,
    pack_head_type text NOT NULL,
    pack_shiphead_id integer,
    pack_printed boolean DEFAULT false NOT NULL,
    CONSTRAINT pack_pack_head_type_check CHECK (((pack_head_type = 'SO'::text) OR (pack_head_type = 'TO'::text)))
);


ALTER TABLE public.pack OWNER TO admin;


--
-- TOC entry 707 (class 1259 OID 146569563)
-- Dependencies: 706 8
-- Name: pack_pack_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE pack_pack_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pack_pack_id_seq OWNER TO admin;

--
-- TOC entry 10038 (class 0 OID 0)
-- Dependencies: 707
-- Name: pack_pack_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE pack_pack_id_seq OWNED BY pack.pack_id;


--
-- TOC entry 708 (class 1259 OID 146569565)
-- Dependencies: 6597 6598 8
-- Name: payaropen; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE payaropen (
    payaropen_ccpay_id integer NOT NULL,
    payaropen_aropen_id integer NOT NULL,
    payaropen_amount numeric(20,2) DEFAULT 0.00 NOT NULL,
    payaropen_curr_id integer DEFAULT basecurrid()
);


ALTER TABLE public.payaropen OWNER TO admin;

--
-- TOC entry 10040 (class 0 OID 0)
-- Dependencies: 708
-- Name: TABLE payaropen; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE payaropen IS 'Credit Card payment to credit memo join table';


--
-- TOC entry 709 (class 1259 OID 146569570)
-- Dependencies: 6599 6600 8
-- Name: payco; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE payco (
    payco_ccpay_id integer NOT NULL,
    payco_cohead_id integer NOT NULL,
    payco_amount numeric(20,2) DEFAULT 0.00 NOT NULL,
    payco_curr_id integer DEFAULT basecurrid()
);


ALTER TABLE public.payco OWNER TO admin;


--
-- TOC entry 710 (class 1259 OID 146569575)
-- Dependencies: 264 8
-- Name: period_period_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE period_period_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.period_period_id_seq OWNER TO admin;

--
-- TOC entry 10044 (class 0 OID 0)
-- Dependencies: 710
-- Name: period_period_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE period_period_id_seq OWNED BY period.period_id;


--
-- TOC entry 717 (class 1259 OID 146569601)
-- Dependencies: 8
-- Name: plancode_plancode_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE plancode_plancode_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.plancode_plancode_id_seq OWNER TO admin;

--
-- TOC entry 718 (class 1259 OID 146569603)
-- Dependencies: 8
-- Name: planord_planord_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE planord_planord_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.planord_planord_id_seq OWNER TO admin;

--
-- TOC entry 719 (class 1259 OID 146569605)
-- Dependencies: 8
-- Name: pohead_pohead_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE pohead_pohead_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.pohead_pohead_id_seq OWNER TO admin;

--
-- TOC entry 720 (class 1259 OID 146569607)
-- Dependencies: 8
-- Name: poitem_poitem_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE poitem_poitem_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.poitem_poitem_id_seq OWNER TO admin;

--
-- TOC entry 721 (class 1259 OID 146569609)
-- Dependencies: 6607 6608 6609 6611 8
-- Name: recv; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE recv (
    recv_id integer NOT NULL,
    recv_order_type text NOT NULL,
    recv_order_number text NOT NULL,
    recv_orderitem_id integer NOT NULL,
    recv_agent_username text,
    recv_itemsite_id integer,
    recv_vend_id integer,
    recv_vend_item_number text,
    recv_vend_item_descrip text,
    recv_vend_uom text,
    recv_purchcost numeric(16,6),
    recv_purchcost_curr_id integer,
    recv_duedate date,
    recv_qty numeric(18,6),
    recv_recvcost numeric(16,6),
    recv_recvcost_curr_id integer,
    recv_freight numeric(16,4),
    recv_freight_curr_id integer,
    recv_date timestamp with time zone,
    recv_value numeric(18,6),
    recv_posted boolean DEFAULT false NOT NULL,
    recv_invoiced boolean DEFAULT false NOT NULL,
    recv_vohead_id integer,
    recv_voitem_id integer,
    recv_trans_usr_name text DEFAULT geteffectivextuser() NOT NULL,
    recv_notes text,
    recv_gldistdate date,
    recv_splitfrom_id integer,
    recv_rlsd_duedate date,
    CONSTRAINT recv_recv_order_type_check CHECK ((((recv_order_type = 'PO'::text) OR (recv_order_type = 'RA'::text)) OR (recv_order_type = 'TO'::text)))
);


ALTER TABLE public.recv OWNER TO admin;

--
-- TOC entry 10065 (class 0 OID 0)
-- Dependencies: 721
-- Name: TABLE recv; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE recv IS 'Information about Received Orders.';


--
-- TOC entry 723 (class 1259 OID 146569624)
-- Dependencies: 8
-- Name: porecv_porecv_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE porecv_porecv_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.porecv_porecv_id_seq OWNER TO admin;

--
-- TOC entry 724 (class 1259 OID 146569626)
-- Dependencies: 6612 8
-- Name: poreject; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE poreject (
    poreject_id integer DEFAULT nextval(('"poreject_poreject_id_seq"'::text)::regclass) NOT NULL,
    poreject_date timestamp with time zone,
    poreject_ponumber text,
    poreject_itemsite_id integer,
    poreject_vend_id integer,
    poreject_vend_item_number text,
    poreject_vend_item_descrip text,
    poreject_vend_uom text,
    poreject_qty numeric(18,6),
    poreject_posted boolean,
    poreject_rjctcode_id integer,
    poreject_poitem_id integer,
    poreject_invoiced boolean,
    poreject_vohead_id integer,
    poreject_agent_username text,
    poreject_voitem_id integer,
    poreject_value numeric(18,6),
    poreject_trans_username text,
    poreject_recv_id integer
);


ALTER TABLE public.poreject OWNER TO admin;


--
-- TOC entry 725 (class 1259 OID 146569633)
-- Dependencies: 8
-- Name: poreject_poreject_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE poreject_poreject_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.poreject_poreject_id_seq OWNER TO admin;

CREATE TABLE pr (
    pr_id integer DEFAULT nextval(('"pr_pr_id_seq"'::text)::regclass) NOT NULL,
    pr_number integer,
    pr_subnumber integer,
    pr_status character(1),
    pr_order_type character(1),
    pr_order_id integer,
    pr_poitem_id integer,
    pr_duedate date,
    pr_itemsite_id integer,
    pr_qtyreq numeric(18,6),
    pr_prj_id integer,
    pr_releasenote text,
    pr_createdate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.pr OWNER TO admin;

--
-- TOC entry 10094 (class 0 OID 0)
-- Dependencies: 728
-- Name: TABLE pr; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE pr IS 'Purchase Request information';


--
-- TOC entry 729 (class 1259 OID 146569651)
-- Dependencies: 8
-- Name: pr_pr_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE pr_pr_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pr_pr_id_seq OWNER TO admin;

--
-- TOC entry 730 (class 1259 OID 146569653)
-- Dependencies: 6617 8
-- Name: prftcntr; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE prftcntr (
    prftcntr_id integer NOT NULL,
    prftcntr_number text NOT NULL,
    prftcntr_descrip text,
    CONSTRAINT prftcntr_prftcntr_number_check CHECK ((prftcntr_number <> ''::text))
);


ALTER TABLE public.prftcntr OWNER TO admin;

--
-- TOC entry 10097 (class 0 OID 0)
-- Dependencies: 730
-- Name: TABLE prftcntr; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE prftcntr IS 'Profit Center information';


--
-- TOC entry 731 (class 1259 OID 146569660)
-- Dependencies: 730 8
-- Name: prftcntr_prftcntr_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE prftcntr_prftcntr_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.prftcntr_prftcntr_id_seq OWNER TO admin;

--
-- TOC entry 10099 (class 0 OID 0)
-- Dependencies: 731
-- Name: prftcntr_prftcntr_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE prftcntr_prftcntr_id_seq OWNED BY prftcntr.prftcntr_id;


--
-- TOC entry 732 (class 1259 OID 146569662)
-- Dependencies: 8
-- Name: usrgrp; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE usrgrp (
    usrgrp_id integer NOT NULL,
    usrgrp_grp_id integer NOT NULL,
    usrgrp_username text NOT NULL
);


ALTER TABLE public.usrgrp OWNER TO admin;

--
-- TOC entry 10101 (class 0 OID 0)
-- Dependencies: 732
-- Name: TABLE usrgrp; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE usrgrp IS 'This is which group a user belongs to.';


--
-- TOC entry 733 (class 1259 OID 146569668)
-- Dependencies: 6619 8
-- Name: usrpriv; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE usrpriv (
    usrpriv_id integer DEFAULT nextval(('usrpriv_usrpriv_id_seq'::text)::regclass) NOT NULL,
    usrpriv_priv_id integer,
    usrpriv_username text
);


ALTER TABLE public.usrpriv OWNER TO admin;

--
-- TOC entry 10103 (class 0 OID 0)
-- Dependencies: 733
-- Name: TABLE usrpriv; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE usrpriv IS 'User Privileges information';


--
-- TOC entry 735 (class 1259 OID 146569680)
-- Dependencies: 225 8
-- Name: prj_prj_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE prj_prj_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.prj_prj_id_seq OWNER TO admin;

--
-- TOC entry 10106 (class 0 OID 0)
-- Dependencies: 735
-- Name: prj_prj_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE prj_prj_id_seq OWNED BY prj.prj_id;


--
-- TOC entry 736 (class 1259 OID 146569682)
-- Dependencies: 232 8
-- Name: prjtask_prjtask_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE prjtask_prjtask_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.prjtask_prjtask_id_seq OWNER TO admin;

--
-- TOC entry 10108 (class 0 OID 0)
-- Dependencies: 736
-- Name: prjtask_prjtask_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE prjtask_prjtask_id_seq OWNED BY prjtask.prjtask_id;


--
-- TOC entry 737 (class 1259 OID 146569684)
-- Dependencies: 8
-- Name: prjtaskuser; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE prjtaskuser (
    prjtaskuser_id integer NOT NULL,
    prjtaskuser_prjtask_id integer,
    prjtaskuser_username text
);


ALTER TABLE public.prjtaskuser OWNER TO admin;

--
-- TOC entry 10110 (class 0 OID 0)
-- Dependencies: 737
-- Name: TABLE prjtaskuser; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE prjtaskuser IS 'Project Task user information';


--
-- TOC entry 738 (class 1259 OID 146569690)
-- Dependencies: 737 8
-- Name: prjtaskuser_prjtaskuser_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE prjtaskuser_prjtaskuser_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.prjtaskuser_prjtaskuser_id_seq OWNER TO admin;

--
-- TOC entry 10112 (class 0 OID 0)
-- Dependencies: 738
-- Name: prjtaskuser_prjtaskuser_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE prjtaskuser_prjtaskuser_id_seq OWNED BY prjtaskuser.prjtaskuser_id;


--
-- TOC entry 739 (class 1259 OID 146569692)
-- Dependencies: 6622 8
-- Name: prjtype; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE prjtype (
    prjtype_id integer NOT NULL,
    prjtype_code text,
    prjtype_descr text,
    prjtype_active boolean DEFAULT true
);


ALTER TABLE public.prjtype OWNER TO admin;

--
-- TOC entry 740 (class 1259 OID 146569699)
-- Dependencies: 739 8
-- Name: prjtype_prjtype_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE prjtype_prjtype_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.prjtype_prjtype_id_seq OWNER TO admin;

--
-- TOC entry 10115 (class 0 OID 0)
-- Dependencies: 740
-- Name: prjtype_prjtype_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE prjtype_prjtype_id_seq OWNED BY prjtype.prjtype_id;


--
-- TOC entry 741 (class 1259 OID 146569701)
-- Dependencies: 8
-- Name: prodcat_prodcat_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE prodcat_prodcat_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.prodcat_prodcat_id_seq OWNER TO admin;

--
-- TOC entry 742 (class 1259 OID 146569703)
-- Dependencies: 6624 6625 6626 8
-- Name: qryhead; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE qryhead (
    qryhead_id integer NOT NULL,
    qryhead_name text NOT NULL,
    qryhead_descrip text,
    qryhead_notes text,
    qryhead_username text DEFAULT geteffectivextuser() NOT NULL,
    qryhead_updated date DEFAULT ('now'::text)::date NOT NULL,
    CONSTRAINT qryhead_qryhead_name_check CHECK ((qryhead_name <> ''::text))
);


ALTER TABLE public.qryhead OWNER TO admin;

--
-- TOC entry 10117 (class 0 OID 0)
-- Dependencies: 742
-- Name: TABLE qryhead; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE qryhead IS 'A header record for a set of queries to be run sequentially. One use is for data export.';


--
-- TOC entry 10118 (class 0 OID 0)
-- Dependencies: 742
-- Name: COLUMN qryhead.qryhead_id; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN qryhead.qryhead_id IS 'The primary key, holding an internal value used to cross-reference this table.';


--
-- TOC entry 10119 (class 0 OID 0)
-- Dependencies: 742
-- Name: COLUMN qryhead.qryhead_name; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN qryhead.qryhead_name IS 'The user-assigned short name for this set of queries.';


--
-- TOC entry 10120 (class 0 OID 0)
-- Dependencies: 742
-- Name: COLUMN qryhead.qryhead_descrip; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN qryhead.qryhead_descrip IS 'A long description of the purpose of this set of queries.';


--
-- TOC entry 10121 (class 0 OID 0)
-- Dependencies: 742
-- Name: COLUMN qryhead.qryhead_notes; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN qryhead.qryhead_notes IS 'General information about this queryset.';


--
-- TOC entry 10122 (class 0 OID 0)
-- Dependencies: 742
-- Name: COLUMN qryhead.qryhead_username; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN qryhead.qryhead_username IS 'The name of the user who last modified this qryhead record.';


--
-- TOC entry 10123 (class 0 OID 0)
-- Dependencies: 742
-- Name: COLUMN qryhead.qryhead_updated; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN qryhead.qryhead_updated IS 'The date this qryhead was last modified.';


--
-- TOC entry 743 (class 1259 OID 146569712)
-- Dependencies: 742 8
-- Name: qryhead_qryhead_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE qryhead_qryhead_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.qryhead_qryhead_id_seq OWNER TO admin;

--
-- TOC entry 10125 (class 0 OID 0)
-- Dependencies: 743
-- Name: qryhead_qryhead_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE qryhead_qryhead_id_seq OWNED BY qryhead.qryhead_id;


--
-- TOC entry 744 (class 1259 OID 146569714)
-- Dependencies: 6627 6628 6629 6631 6632 8
-- Name: qryitem; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE qryitem (
    qryitem_id integer NOT NULL,
    qryitem_qryhead_id integer NOT NULL,
    qryitem_name text NOT NULL,
    qryitem_order integer NOT NULL,
    qryitem_src text NOT NULL,
    qryitem_group text,
    qryitem_detail text NOT NULL,
    qryitem_notes text DEFAULT ''::text NOT NULL,
    qryitem_username text DEFAULT geteffectivextuser() NOT NULL,
    qryitem_updated date DEFAULT ('now'::text)::date NOT NULL,
    CONSTRAINT qryitem_qryitem_detail_check CHECK ((btrim(qryitem_detail) <> ''::text)),
    CONSTRAINT qryitem_qryitem_src_check CHECK ((qryitem_src = ANY (ARRAY['REL'::text, 'MQL'::text, 'CUSTOM'::text])))
);


ALTER TABLE public.qryitem OWNER TO admin;

--
-- TOC entry 10127 (class 0 OID 0)
-- Dependencies: 744
-- Name: TABLE qryitem; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE qryitem IS 'The description of a query to be run as part of a set (see qryhead).';


--
-- TOC entry 10128 (class 0 OID 0)
-- Dependencies: 744
-- Name: COLUMN qryitem.qryitem_id; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN qryitem.qryitem_id IS 'The primary key, holding an internal value used to cross-reference this table.';


--
-- TOC entry 10129 (class 0 OID 0)
-- Dependencies: 744
-- Name: COLUMN qryitem.qryitem_qryhead_id; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN qryitem.qryitem_qryhead_id IS 'The primary key of the query set to which this individual query belongs.';


--
-- TOC entry 10130 (class 0 OID 0)
-- Dependencies: 744
-- Name: COLUMN qryitem.qryitem_order; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN qryitem.qryitem_order IS 'The order in which query items within a query set should be run.';


--
-- TOC entry 10131 (class 0 OID 0)
-- Dependencies: 744
-- Name: COLUMN qryitem.qryitem_src; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN qryitem.qryitem_src IS 'The source of the query. If the qryitem_src is "REL" then the qryitem_group and _detail name a particular table or view and all rows will be returned. If the source is "MQL" then the qryitem_group and _detail name a pre-defined MetaSQL query in the metasql table. If the source is "CUSTOM" then the qryitem_detail contains the full MetaSQL text of the query to run.';


--
-- TOC entry 10132 (class 0 OID 0)
-- Dependencies: 744
-- Name: COLUMN qryitem.qryitem_group; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN qryitem.qryitem_group IS 'Information to help find the query to run. If the qryitem_src is "REL" then this is the schema in which to find the table or view to query and all rows will be returned (the qryitem_detail names the table or view). If the qryitem_src is "MQL" then this is the group of the query in the metasql table to run (the name is in qryitem_detail). If the qryitem_src IS "CUSTOM" then this ignored.';


--
-- TOC entry 10133 (class 0 OID 0)
-- Dependencies: 744
-- Name: COLUMN qryitem.qryitem_detail; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN qryitem.qryitem_detail IS 'The particular query to run. If the qryitem_src is "REL" then this is the name of the table or view to query and all rows will be returned. If the qryitem_src is "MQL" then this is the name of the query in the metasql table to run. If the qryitem_src IS "CUSTOM" then this is the actual MetaSQL query text to be parsed and run.';


--
-- TOC entry 10134 (class 0 OID 0)
-- Dependencies: 744
-- Name: COLUMN qryitem.qryitem_notes; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN qryitem.qryitem_notes IS 'General information about this query.';


--
-- TOC entry 10135 (class 0 OID 0)
-- Dependencies: 744
-- Name: COLUMN qryitem.qryitem_username; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN qryitem.qryitem_username IS 'The name of the user who last modified this qryitem record.';


--
-- TOC entry 10136 (class 0 OID 0)
-- Dependencies: 744
-- Name: COLUMN qryitem.qryitem_updated; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN qryitem.qryitem_updated IS 'The date this qryitem was last modified.';


--
-- TOC entry 745 (class 1259 OID 146569725)
-- Dependencies: 744 8
-- Name: qryitem_qryitem_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE qryitem_qryitem_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.qryitem_qryitem_id_seq OWNER TO admin;

--
-- TOC entry 10138 (class 0 OID 0)
-- Dependencies: 745
-- Name: qryitem_qryitem_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE qryitem_qryitem_id_seq OWNED BY qryitem.qryitem_id;


--
-- TOC entry 746 (class 1259 OID 146569727)
-- Dependencies: 8
-- Name: quhead_quhead_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE quhead_quhead_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.quhead_quhead_id_seq OWNER TO admin;

--
-- TOC entry 747 (class 1259 OID 146569729)
-- Dependencies: 8
-- Name: quitem_quitem_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE quitem_quitem_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.quitem_quitem_id_seq OWNER TO admin;

--
-- TOC entry 748 (class 1259 OID 146569731)
-- Dependencies: 6633 8
-- Name: rcalitem; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE rcalitem (
    rcalitem_id integer DEFAULT nextval(('"xcalitem_xcalitem_id_seq"'::text)::regclass) NOT NULL,
    rcalitem_calhead_id integer,
    rcalitem_offsettype character(1),
    rcalitem_offsetcount integer,
    rcalitem_periodtype character(1),
    rcalitem_periodcount integer,
    rcalitem_name text
);


ALTER TABLE public.rcalitem OWNER TO admin;

--
-- TOC entry 10142 (class 0 OID 0)
-- Dependencies: 748
-- Name: TABLE rcalitem; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE rcalitem IS 'Relative Calendar Item information';

--
-- TOC entry 751 (class 1259 OID 146569749)
-- Dependencies: 8
-- Name: recurtype; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE recurtype (
    recurtype_id integer NOT NULL,
    recurtype_type text NOT NULL,
    recurtype_table text NOT NULL,
    recurtype_donecheck text NOT NULL,
    recurtype_schedcol text NOT NULL,
    recurtype_limit text,
    recurtype_copyfunc text NOT NULL,
    recurtype_copyargs text[] NOT NULL,
    recurtype_delfunc text
);


ALTER TABLE public.recurtype OWNER TO admin;

--
-- TOC entry 10157 (class 0 OID 0)
-- Dependencies: 751
-- Name: TABLE recurtype; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE recurtype IS 'Describes the properties of recurring items/events in way that can be used by stored procedures to maintain the recurrence.';


--
-- TOC entry 10158 (class 0 OID 0)
-- Dependencies: 751
-- Name: COLUMN recurtype.recurtype_id; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN recurtype.recurtype_id IS 'The internal id of this recurrence description.';


--
-- TOC entry 10159 (class 0 OID 0)
-- Dependencies: 751
-- Name: COLUMN recurtype.recurtype_type; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN recurtype.recurtype_type IS 'A code value used by the RecurrenceWidget and the code that uses it to describe the item/event that will recur. Examples include "INCDT" for CRM Incidents and "J" for Projects.';


--
-- TOC entry 10160 (class 0 OID 0)
-- Dependencies: 751
-- Name: COLUMN recurtype.recurtype_table; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN recurtype.recurtype_table IS 'The table that holds the item/event that will recur.';


--
-- TOC entry 10161 (class 0 OID 0)
-- Dependencies: 751
-- Name: COLUMN recurtype.recurtype_donecheck; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN recurtype.recurtype_donecheck IS 'A boolean expression that returns TRUE if an individual item/event record in the recurtype_table has already been completed.';


--
-- TOC entry 10162 (class 0 OID 0)
-- Dependencies: 751
-- Name: COLUMN recurtype.recurtype_schedcol; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN recurtype.recurtype_schedcol IS 'The name of the column in the recurtype_table holding the date or timestamp by which the item is scheduled to be completed or at which the event is supposed to occur.';


--
-- TOC entry 10163 (class 0 OID 0)
-- Dependencies: 751
-- Name: COLUMN recurtype.recurtype_limit; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN recurtype.recurtype_limit IS 'A boolean expression that returns TRUE if the current user should see the row in the recurtype_table. NULL indicates there is no specific limitation. For example, the maintainance of recurring TODO items should restricted to those items belonging to the user unless s/he has been granted the privilege to modify other people''s todo lists.';


--
-- TOC entry 10164 (class 0 OID 0)
-- Dependencies: 751
-- Name: COLUMN recurtype.recurtype_copyfunc; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN recurtype.recurtype_copyfunc IS 'The name of the function to copy an existing item/event record. The copy function is expected to take at least 2 arguments: the id of the item to copy and the new date/timestamp. If the function accepts more than 2, it must be able to accept NULL values for the 3rd and following arguments.';


--
-- TOC entry 10165 (class 0 OID 0)
-- Dependencies: 751
-- Name: COLUMN recurtype.recurtype_copyargs; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN recurtype.recurtype_copyargs IS 'An abbreviated argument list for the copy function. This is used to determine whether the second argument must be cast to a date or a timestamp, and to figure out how many additional arguments to pass.';


--
-- TOC entry 10166 (class 0 OID 0)
-- Dependencies: 751
-- Name: COLUMN recurtype.recurtype_delfunc; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN recurtype.recurtype_delfunc IS 'The name of the function to delete an existing item/event record. The function is expected to take exactly one argument: the id of the item to delete. NULL indicates there is no delete function and that an SQL DELETE statement can be used. In this case, the id column name will be built as the recurtype_table concatenated with the "_id" suffix.';


--
-- TOC entry 752 (class 1259 OID 146569755)
-- Dependencies: 751 8
-- Name: recurtype_recurtype_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE recurtype_recurtype_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.recurtype_recurtype_id_seq OWNER TO admin;

--
-- TOC entry 10168 (class 0 OID 0)
-- Dependencies: 752
-- Name: recurtype_recurtype_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE recurtype_recurtype_id_seq OWNED BY recurtype.recurtype_id;


--
-- TOC entry 753 (class 1259 OID 146569757)
-- Dependencies: 721 8
-- Name: recv_recv_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE recv_recv_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.recv_recv_id_seq OWNER TO admin;

--
-- TOC entry 10170 (class 0 OID 0)
-- Dependencies: 753
-- Name: recv_recv_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE recv_recv_id_seq OWNED BY recv.recv_id;


--
-- TOC entry 755 (class 1259 OID 146569763)
-- Dependencies: 6639 6640 8
-- Name: rjctcode; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE rjctcode (
    rjctcode_id integer DEFAULT nextval(('"rjctcode_rjctcode_id_seq"'::text)::regclass) NOT NULL,
    rjctcode_code text NOT NULL,
    rjctcode_descrip text,
    CONSTRAINT rjctcode_rjctcode_code_check CHECK ((rjctcode_code <> ''::text))
);


ALTER TABLE public.rjctcode OWNER TO admin;

--
-- TOC entry 10173 (class 0 OID 0)
-- Dependencies: 755
-- Name: TABLE rjctcode; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE rjctcode IS 'Reject Code information';


--
-- TOC entry 756 (class 1259 OID 146569771)
-- Dependencies: 8
-- Name: rjctcode_rjctcode_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE rjctcode_rjctcode_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.rjctcode_rjctcode_id_seq OWNER TO admin;

--
-- TOC entry 757 (class 1259 OID 146569773)
-- Dependencies: 214 8
-- Name: rsncode_rsncode_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE rsncode_rsncode_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.rsncode_rsncode_id_seq OWNER TO admin;

--
-- TOC entry 10176 (class 0 OID 0)
-- Dependencies: 757
-- Name: rsncode_rsncode_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE rsncode_rsncode_id_seq OWNED BY rsncode.rsncode_id;


--
-- TOC entry 758 (class 1259 OID 146569775)
-- Dependencies: 6641 6642 8
-- Name: sale; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE sale (
    sale_id integer DEFAULT nextval(('"sale_sale_id_seq"'::text)::regclass) NOT NULL,
    sale_name text NOT NULL,
    sale_descrip text,
    sale_ipshead_id integer,
    sale_startdate date,
    sale_enddate date,
    CONSTRAINT sale_sale_name_check CHECK ((sale_name <> ''::text))
);


ALTER TABLE public.sale OWNER TO admin;

--
-- TOC entry 10178 (class 0 OID 0)
-- Dependencies: 758
-- Name: TABLE sale; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE sale IS 'Sale information';


--
-- TOC entry 759 (class 1259 OID 146569783)
-- Dependencies: 8
-- Name: sale_sale_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE sale_sale_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sale_sale_id_seq OWNER TO admin;

--
-- TOC entry 760 (class 1259 OID 146569785)
-- Dependencies: 8
-- Name: salesaccnt_salesaccnt_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE salesaccnt_salesaccnt_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.salesaccnt_salesaccnt_id_seq OWNER TO admin;

--
-- TOC entry 761 (class 1259 OID 146569787)
-- Dependencies: 215 8
-- Name: salescat_salescat_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE salescat_salescat_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.salescat_salescat_id_seq OWNER TO admin;

--
-- TOC entry 10182 (class 0 OID 0)
-- Dependencies: 761
-- Name: salescat_salescat_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE salescat_salescat_id_seq OWNED BY salescat.salescat_id;


--
-- TOC entry 764 (class 1259 OID 146569799)
-- Dependencies: 8
-- Name: salesrep_salesrep_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE salesrep_salesrep_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.salesrep_salesrep_id_seq OWNER TO admin;

--
-- TOC entry 765 (class 1259 OID 146569801)
-- Dependencies: 226 8
-- Name: saletype_saletype_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE saletype_saletype_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.saletype_saletype_id_seq OWNER TO admin;

--
-- TOC entry 10189 (class 0 OID 0)
-- Dependencies: 765
-- Name: saletype_saletype_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE saletype_saletype_id_seq OWNED BY saletype.saletype_id;


--
-- TOC entry 766 (class 1259 OID 146569803)
-- Dependencies: 6644 6645 8
-- Name: schemaord; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE schemaord (
    schemaord_id integer NOT NULL,
    schemaord_name text NOT NULL,
    schemaord_order integer NOT NULL,
    CONSTRAINT schemaord_schemaord_name_check CHECK ((length(schemaord_name) > 0)),
    CONSTRAINT schemaord_schemaord_name_check1 CHECK ((schemaord_name <> ''::text))
);


ALTER TABLE public.schemaord OWNER TO admin;

--
-- TOC entry 10191 (class 0 OID 0)
-- Dependencies: 766
-- Name: TABLE schemaord; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE schemaord IS 'Set the order in which db schemas will appear in the search path after login';


--
-- TOC entry 767 (class 1259 OID 146569811)
-- Dependencies: 766 8
-- Name: schemaord_schemaord_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE schemaord_schemaord_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.schemaord_schemaord_id_seq OWNER TO admin;

--
-- TOC entry 10193 (class 0 OID 0)
-- Dependencies: 767
-- Name: schemaord_schemaord_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE schemaord_schemaord_id_seq OWNED BY schemaord.schemaord_id;


--
-- TOC entry 768 (class 1259 OID 146569813)
-- Dependencies: 8
-- Name: sequence; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE sequence (
    sequence_value integer
);


ALTER TABLE public.sequence OWNER TO admin;

--
-- TOC entry 10195 (class 0 OID 0)
-- Dependencies: 768
-- Name: TABLE sequence; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE sequence IS 'Pre-populated list of sequence numbers (1-1000) used for printing Labels and other uses';


--
-- TOC entry 769 (class 1259 OID 146569816)
-- Dependencies: 293 8
-- Name: shift_shift_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE shift_shift_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.shift_shift_id_seq OWNER TO admin;

--
-- TOC entry 10197 (class 0 OID 0)
-- Dependencies: 769
-- Name: shift_shift_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE shift_shift_id_seq OWNED BY shift.shift_id;


--
-- TOC entry 770 (class 1259 OID 146569818)
-- Dependencies: 281 8
-- Name: shipchrg_shipchrg_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE shipchrg_shipchrg_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.shipchrg_shipchrg_id_seq OWNER TO admin;

--
-- TOC entry 10199 (class 0 OID 0)
-- Dependencies: 770
-- Name: shipchrg_shipchrg_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE shipchrg_shipchrg_id_seq OWNED BY shipchrg.shipchrg_id;


--
-- TOC entry 771 (class 1259 OID 146569820)
-- Dependencies: 6646 6647 6648 6649 6650 8
-- Name: shipdatasum; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE shipdatasum (
    shipdatasum_cohead_number text NOT NULL,
    shipdatasum_cosmisc_tracknum text NOT NULL,
    shipdatasum_cosmisc_packnum_tracknum text NOT NULL,
    shipdatasum_weight numeric(16,4),
    shipdatasum_base_freight numeric(16,4),
    shipdatasum_total_freight numeric(16,4),
    shipdatasum_shipper text DEFAULT 'UPS'::text,
    shipdatasum_billing_option text,
    shipdatasum_package_type text,
    shipdatasum_lastupdated timestamp without time zone DEFAULT ('now'::text)::timestamp(6) with time zone NOT NULL,
    shipdatasum_shipped boolean DEFAULT false,
    shipdatasum_shiphead_number text,
    shipdatasum_base_freight_curr_id integer DEFAULT basecurrid(),
    shipdatasum_total_freight_curr_id integer DEFAULT basecurrid()
);


ALTER TABLE public.shipdatasum OWNER TO admin;

--
-- TOC entry 10201 (class 0 OID 0)
-- Dependencies: 771
-- Name: TABLE shipdatasum; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE shipdatasum IS 'Shipping Interface information.';


--
-- TOC entry 772 (class 1259 OID 146569831)
-- Dependencies: 8
-- Name: shipform_shipform_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE shipform_shipform_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.shipform_shipform_id_seq OWNER TO admin;

--
-- TOC entry 773 (class 1259 OID 146569833)
-- Dependencies: 526 8
-- Name: shiphead_shiphead_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE shiphead_shiphead_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.shiphead_shiphead_id_seq OWNER TO admin;

--
-- TOC entry 10204 (class 0 OID 0)
-- Dependencies: 773
-- Name: shiphead_shiphead_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE shiphead_shiphead_id_seq OWNED BY shiphead.shiphead_id;


--
-- TOC entry 774 (class 1259 OID 146569835)
-- Dependencies: 527 8
-- Name: shipitem_shipitem_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE shipitem_shipitem_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.shipitem_shipitem_id_seq OWNER TO admin;

--
-- TOC entry 10206 (class 0 OID 0)
-- Dependencies: 774
-- Name: shipitem_shipitem_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE shipitem_shipitem_id_seq OWNED BY shipitem.shipitem_id;


--
-- TOC entry 775 (class 1259 OID 146569837)
-- Dependencies: 8
-- Name: shipment_number_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE shipment_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.shipment_number_seq OWNER TO admin;


--
-- TOC entry 777 (class 1259 OID 146569844)
-- Dependencies: 8
-- Name: shipto_shipto_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE shipto_shipto_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.shipto_shipto_id_seq OWNER TO admin;

--
-- TOC entry 778 (class 1259 OID 146569846)
-- Dependencies: 8
-- Name: shipvia_shipvia_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE shipvia_shipvia_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.shipvia_shipvia_id_seq OWNER TO admin;

--
-- TOC entry 779 (class 1259 OID 146569848)
-- Dependencies: 8
-- Name: shipzone_shipzone_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE shipzone_shipzone_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.shipzone_shipzone_id_seq OWNER TO admin;

--
-- TOC entry 780 (class 1259 OID 146569850)
-- Dependencies: 387 8
-- Name: sitetype_sitetype_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE sitetype_sitetype_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sitetype_sitetype_id_seq OWNER TO admin;

--
-- TOC entry 10213 (class 0 OID 0)
-- Dependencies: 780
-- Name: sitetype_sitetype_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE sitetype_sitetype_id_seq OWNED BY sitetype.sitetype_id;


--
-- TOC entry 781 (class 1259 OID 146569852)
-- Dependencies: 6651 6652 6653 8
-- Name: sltrans; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE sltrans (
    sltrans_id integer DEFAULT nextval('gltrans_gltrans_id_seq'::regclass) NOT NULL,
    sltrans_created timestamp with time zone,
    sltrans_date date NOT NULL,
    sltrans_sequence integer,
    sltrans_accnt_id integer NOT NULL,
    sltrans_source text,
    sltrans_docnumber text,
    sltrans_misc_id integer,
    sltrans_amount numeric(20,2) NOT NULL,
    sltrans_notes text,
    sltrans_journalnumber integer,
    sltrans_posted boolean NOT NULL,
    sltrans_doctype text,
    sltrans_username text DEFAULT geteffectivextuser() NOT NULL,
    sltrans_gltrans_journalnumber integer,
    sltrans_rec boolean DEFAULT false NOT NULL
);


ALTER TABLE public.sltrans OWNER TO admin;

--
-- TOC entry 10215 (class 0 OID 0)
-- Dependencies: 781
-- Name: TABLE sltrans; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE sltrans IS 'Journal transaction information';


--
-- TOC entry 782 (class 1259 OID 146569861)
-- Dependencies: 8
-- Name: sltrans_backup; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE sltrans_backup (
    sltrans_old_id integer,
    sltrans_new_id integer
);


ALTER TABLE public.sltrans_backup OWNER TO admin;

--
-- TOC entry 10217 (class 0 OID 0)
-- Dependencies: 782
-- Name: TABLE sltrans_backup; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE sltrans_backup IS 'backup cross references of old and new ids for sltrans 4.0 upgrade.';


--
-- TOC entry 784 (class 1259 OID 146569868)
-- Dependencies: 8
-- Name: sopack_sopack_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE sopack_sopack_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sopack_sopack_id_seq OWNER TO admin;

--
-- TOC entry 785 (class 1259 OID 146569870)
-- Dependencies: 6655 8
-- Name: source; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE source (
    source_id integer NOT NULL,
    source_module text,
    source_name text NOT NULL,
    source_descrip text,
    CONSTRAINT source_source_name_check CHECK ((source_name <> ''::text))
);


ALTER TABLE public.source OWNER TO admin;

--
-- TOC entry 786 (class 1259 OID 146569877)
-- Dependencies: 785 8
-- Name: source_source_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE source_source_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.source_source_id_seq OWNER TO admin;

--
-- TOC entry 10226 (class 0 OID 0)
-- Dependencies: 786
-- Name: source_source_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE source_source_id_seq OWNED BY source.source_id;


--
-- TOC entry 787 (class 1259 OID 146569879)
-- Dependencies: 6657 8
-- Name: state; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE state (
    state_id integer NOT NULL,
    state_name text NOT NULL,
    state_abbr text,
    state_country_id integer,
    CONSTRAINT state_state_name_check CHECK ((state_name <> ''::text))
);


ALTER TABLE public.state OWNER TO admin;

--
-- TOC entry 10228 (class 0 OID 0)
-- Dependencies: 787
-- Name: TABLE state; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE state IS 'List of states, provinces, and territories associated with various countries.';


--
-- TOC entry 788 (class 1259 OID 146569886)
-- Dependencies: 787 8
-- Name: state_state_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE state_state_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.state_state_id_seq OWNER TO admin;

--
-- TOC entry 10230 (class 0 OID 0)
-- Dependencies: 788
-- Name: state_state_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE state_state_id_seq OWNED BY state.state_id;


--
-- TOC entry 789 (class 1259 OID 146569888)
-- Dependencies: 6659 8
-- Name: status; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE status (
    status_id integer NOT NULL,
    status_type text NOT NULL,
    status_code character(1) NOT NULL,
    status_name text,
    status_seq integer,
    status_color text DEFAULT 'white'::text
);


ALTER TABLE public.status OWNER TO admin;

--
-- TOC entry 790 (class 1259 OID 146569895)
-- Dependencies: 789 8
-- Name: status_status_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE status_status_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.status_status_id_seq OWNER TO admin;

--
-- TOC entry 10233 (class 0 OID 0)
-- Dependencies: 790
-- Name: status_status_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE status_status_id_seq OWNED BY status.status_id;


--
-- TOC entry 791 (class 1259 OID 146569897)
-- Dependencies: 6661 8
-- Name: stdjrnl; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE stdjrnl (
    stdjrnl_id integer NOT NULL,
    stdjrnl_name text NOT NULL,
    stdjrnl_descrip text,
    stdjrnl_notes text,
    CONSTRAINT stdjrnl_stdjrnl_name_check CHECK ((stdjrnl_name <> ''::text))
);


ALTER TABLE public.stdjrnl OWNER TO admin;

--
-- TOC entry 10235 (class 0 OID 0)
-- Dependencies: 791
-- Name: TABLE stdjrnl; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE stdjrnl IS 'Standard Journal information';


--
-- TOC entry 792 (class 1259 OID 146569904)
-- Dependencies: 791 8
-- Name: stdjrnl_stdjrnl_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE stdjrnl_stdjrnl_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.stdjrnl_stdjrnl_id_seq OWNER TO admin;

--
-- TOC entry 10237 (class 0 OID 0)
-- Dependencies: 792
-- Name: stdjrnl_stdjrnl_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE stdjrnl_stdjrnl_id_seq OWNED BY stdjrnl.stdjrnl_id;


--
-- TOC entry 793 (class 1259 OID 146569906)
-- Dependencies: 6663 8
-- Name: stdjrnlgrp; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE stdjrnlgrp (
    stdjrnlgrp_id integer NOT NULL,
    stdjrnlgrp_name text NOT NULL,
    stdjrnlgrp_descrip text,
    CONSTRAINT stdjrnlgrp_stdjrnlgrp_name_check CHECK ((stdjrnlgrp_name <> ''::text))
);


ALTER TABLE public.stdjrnlgrp OWNER TO admin;

--
-- TOC entry 10239 (class 0 OID 0)
-- Dependencies: 793
-- Name: TABLE stdjrnlgrp; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE stdjrnlgrp IS 'Standard Journal Group information';


--
-- TOC entry 794 (class 1259 OID 146569913)
-- Dependencies: 793 8
-- Name: stdjrnlgrp_stdjrnlgrp_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE stdjrnlgrp_stdjrnlgrp_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.stdjrnlgrp_stdjrnlgrp_id_seq OWNER TO admin;

--
-- TOC entry 10241 (class 0 OID 0)
-- Dependencies: 794
-- Name: stdjrnlgrp_stdjrnlgrp_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE stdjrnlgrp_stdjrnlgrp_id_seq OWNED BY stdjrnlgrp.stdjrnlgrp_id;


--
-- TOC entry 795 (class 1259 OID 146569915)
-- Dependencies: 8
-- Name: stdjrnlgrpitem; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE stdjrnlgrpitem (
    stdjrnlgrpitem_id integer NOT NULL,
    stdjrnlgrpitem_stdjrnl_id integer,
    stdjrnlgrpitem_toapply integer,
    stdjrnlgrpitem_applied integer,
    stdjrnlgrpitem_effective date,
    stdjrnlgrpitem_expires date,
    stdjrnlgrpitem_stdjrnlgrp_id integer
);


ALTER TABLE public.stdjrnlgrpitem OWNER TO admin;

--
-- TOC entry 10243 (class 0 OID 0)
-- Dependencies: 795
-- Name: TABLE stdjrnlgrpitem; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE stdjrnlgrpitem IS 'Standard Journal Group Item information';


--
-- TOC entry 796 (class 1259 OID 146569918)
-- Dependencies: 795 8
-- Name: stdjrnlgrpitem_stdjrnlgrpitem_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE stdjrnlgrpitem_stdjrnlgrpitem_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.stdjrnlgrpitem_stdjrnlgrpitem_id_seq OWNER TO admin;

--
-- TOC entry 10245 (class 0 OID 0)
-- Dependencies: 796
-- Name: stdjrnlgrpitem_stdjrnlgrpitem_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE stdjrnlgrpitem_stdjrnlgrpitem_id_seq OWNED BY stdjrnlgrpitem.stdjrnlgrpitem_id;


--
-- TOC entry 797 (class 1259 OID 146569920)
-- Dependencies: 8
-- Name: stdjrnlitem; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE stdjrnlitem (
    stdjrnlitem_id integer NOT NULL,
    stdjrnlitem_stdjrnl_id integer NOT NULL,
    stdjrnlitem_accnt_id integer NOT NULL,
    stdjrnlitem_amount numeric(20,2) NOT NULL,
    stdjrnlitem_notes text
);


ALTER TABLE public.stdjrnlitem OWNER TO admin;

--
-- TOC entry 10247 (class 0 OID 0)
-- Dependencies: 797
-- Name: TABLE stdjrnlitem; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE stdjrnlitem IS 'Standard Journal Item information';


--
-- TOC entry 798 (class 1259 OID 146569926)
-- Dependencies: 797 8
-- Name: stdjrnlitem_stdjrnlitem_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE stdjrnlitem_stdjrnlitem_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.stdjrnlitem_stdjrnlitem_id_seq OWNER TO admin;

--
-- TOC entry 10249 (class 0 OID 0)
-- Dependencies: 798
-- Name: stdjrnlitem_stdjrnlitem_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE stdjrnlitem_stdjrnlitem_id_seq OWNED BY stdjrnlitem.stdjrnlitem_id;


--
-- TOC entry 799 (class 1259 OID 146569928)
-- Dependencies: 6667 8
-- Name: subaccnt; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE subaccnt (
    subaccnt_id integer NOT NULL,
    subaccnt_number text NOT NULL,
    subaccnt_descrip text,
    CONSTRAINT subaccnt_subaccnt_number_check CHECK ((subaccnt_number <> ''::text))
);


ALTER TABLE public.subaccnt OWNER TO admin;

--
-- TOC entry 10251 (class 0 OID 0)
-- Dependencies: 799
-- Name: TABLE subaccnt; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE subaccnt IS 'Subaccount information';


--
-- TOC entry 800 (class 1259 OID 146569935)
-- Dependencies: 799 8
-- Name: subaccnt_subaccnt_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE subaccnt_subaccnt_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.subaccnt_subaccnt_id_seq OWNER TO admin;

--
-- TOC entry 10253 (class 0 OID 0)
-- Dependencies: 800
-- Name: subaccnt_subaccnt_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE subaccnt_subaccnt_id_seq OWNED BY subaccnt.subaccnt_id;


--
-- TOC entry 801 (class 1259 OID 146569937)
-- Dependencies: 8
-- Name: subaccnttype; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE subaccnttype (
    subaccnttype_id integer NOT NULL,
    subaccnttype_accnt_type character(1) NOT NULL,
    subaccnttype_code text NOT NULL,
    subaccnttype_descrip text
);


ALTER TABLE public.subaccnttype OWNER TO admin;

--
-- TOC entry 10255 (class 0 OID 0)
-- Dependencies: 801
-- Name: TABLE subaccnttype; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE subaccnttype IS 'User defined Sub Account Types.';


--
-- TOC entry 802 (class 1259 OID 146569943)
-- Dependencies: 801 8
-- Name: subaccnttype_subaccnttype_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE subaccnttype_subaccnttype_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.subaccnttype_subaccnttype_id_seq OWNER TO admin;

--
-- TOC entry 10257 (class 0 OID 0)
-- Dependencies: 802
-- Name: subaccnttype_subaccnttype_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE subaccnttype_subaccnttype_id_seq OWNED BY subaccnttype.subaccnttype_id;


--
-- TOC entry 803 (class 1259 OID 146569945)
-- Dependencies: 8
-- Name: tax_tax_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE tax_tax_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tax_tax_id_seq OWNER TO admin;

--
-- TOC entry 804 (class 1259 OID 146569947)
-- Dependencies: 8
-- Name: taxass; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE taxass (
    taxass_id integer NOT NULL,
    taxass_taxzone_id integer,
    taxass_taxtype_id integer,
    taxass_tax_id integer NOT NULL
);


ALTER TABLE public.taxass OWNER TO admin;


--
-- TOC entry 805 (class 1259 OID 146569950)
-- Dependencies: 804 8
-- Name: taxass_taxass_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE taxass_taxass_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.taxass_taxass_id_seq OWNER TO admin;

--
-- TOC entry 10265 (class 0 OID 0)
-- Dependencies: 805
-- Name: taxass_taxass_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE taxass_taxass_id_seq OWNED BY taxass.taxass_id;


--
-- TOC entry 806 (class 1259 OID 146569952)
-- Dependencies: 284 8
-- Name: taxauth_taxauth_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE taxauth_taxauth_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.taxauth_taxauth_id_seq OWNER TO admin;

--
-- TOC entry 10267 (class 0 OID 0)
-- Dependencies: 806
-- Name: taxauth_taxauth_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE taxauth_taxauth_id_seq OWNED BY taxauth.taxauth_id;


--
-- TOC entry 807 (class 1259 OID 146569954)
-- Dependencies: 6671 8
-- Name: taxclass; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE taxclass (
    taxclass_id integer NOT NULL,
    taxclass_code text NOT NULL,
    taxclass_descrip text,
    taxclass_sequence integer,
    CONSTRAINT taxclass_taxclass_code_check CHECK ((taxclass_code <> ''::text))
);


ALTER TABLE public.taxclass OWNER TO admin;

--
-- TOC entry 10269 (class 0 OID 0)
-- Dependencies: 807
-- Name: TABLE taxclass; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE taxclass IS 'Tax class information';


--
-- TOC entry 10270 (class 0 OID 0)
-- Dependencies: 807
-- Name: COLUMN taxclass.taxclass_id; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN taxclass.taxclass_id IS 'Primary key';


--
-- TOC entry 10271 (class 0 OID 0)
-- Dependencies: 807
-- Name: COLUMN taxclass.taxclass_code; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN taxclass.taxclass_code IS 'Code';


--
-- TOC entry 10272 (class 0 OID 0)
-- Dependencies: 807
-- Name: COLUMN taxclass.taxclass_descrip; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN taxclass.taxclass_descrip IS 'Description';


--
-- TOC entry 10273 (class 0 OID 0)
-- Dependencies: 807
-- Name: COLUMN taxclass.taxclass_sequence; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN taxclass.taxclass_sequence IS 'Group sequence';


--
-- TOC entry 808 (class 1259 OID 146569961)
-- Dependencies: 807 8
-- Name: taxclass_taxclass_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE taxclass_taxclass_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.taxclass_taxclass_id_seq OWNER TO admin;

--
-- TOC entry 10275 (class 0 OID 0)
-- Dependencies: 808
-- Name: taxclass_taxclass_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE taxclass_taxclass_id_seq OWNED BY taxclass.taxclass_id;


--
-- TOC entry 378 (class 1259 OID 146568112)
-- Dependencies: 377 8
-- Name: taxhist_taxhist_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE taxhist_taxhist_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.taxhist_taxhist_id_seq OWNER TO admin;

--
-- TOC entry 10277 (class 0 OID 0)
-- Dependencies: 378
-- Name: taxhist_taxhist_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE taxhist_taxhist_id_seq OWNED BY taxhist.taxhist_id;


--
-- TOC entry 809 (class 1259 OID 146569963)
-- Dependencies: 8
-- Name: taxrate; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE taxrate (
    taxrate_id integer NOT NULL,
    taxrate_tax_id integer NOT NULL,
    taxrate_percent numeric(10,6) NOT NULL,
    taxrate_curr_id integer,
    taxrate_amount numeric(16,2) NOT NULL,
    taxrate_effective date,
    taxrate_expires date
);


ALTER TABLE public.taxrate OWNER TO admin;

--
-- TOC entry 10279 (class 0 OID 0)
-- Dependencies: 809
-- Name: TABLE taxrate; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE taxrate IS 'Tax rates.';


--
-- TOC entry 10280 (class 0 OID 0)
-- Dependencies: 809
-- Name: COLUMN taxrate.taxrate_id; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN taxrate.taxrate_id IS 'Primary key.';


--
-- TOC entry 10281 (class 0 OID 0)
-- Dependencies: 809
-- Name: COLUMN taxrate.taxrate_tax_id; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN taxrate.taxrate_tax_id IS 'The id of the parent tax code.';


--
-- TOC entry 10282 (class 0 OID 0)
-- Dependencies: 809
-- Name: COLUMN taxrate.taxrate_percent; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN taxrate.taxrate_percent IS 'Tax rate percentage.';


--
-- TOC entry 10283 (class 0 OID 0)
-- Dependencies: 809
-- Name: COLUMN taxrate.taxrate_curr_id; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN taxrate.taxrate_curr_id IS 'The currency id of the flat rate amount.';


--
-- TOC entry 10284 (class 0 OID 0)
-- Dependencies: 809
-- Name: COLUMN taxrate.taxrate_amount; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN taxrate.taxrate_amount IS 'Flat tax rate amount.';


--
-- TOC entry 10285 (class 0 OID 0)
-- Dependencies: 809
-- Name: COLUMN taxrate.taxrate_effective; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN taxrate.taxrate_effective IS 'The effective date of the tax rate.  NULL value means always.';


--
-- TOC entry 10286 (class 0 OID 0)
-- Dependencies: 809
-- Name: COLUMN taxrate.taxrate_expires; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN taxrate.taxrate_expires IS 'The expire date of the tax rate.  NULL value means never.';


--
-- TOC entry 810 (class 1259 OID 146569966)
-- Dependencies: 809 8
-- Name: taxrate_taxrate_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE taxrate_taxrate_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.taxrate_taxrate_id_seq OWNER TO admin;

--
-- TOC entry 10288 (class 0 OID 0)
-- Dependencies: 810
-- Name: taxrate_taxrate_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE taxrate_taxrate_id_seq OWNED BY taxrate.taxrate_id;


--
-- TOC entry 811 (class 1259 OID 146569968)
-- Dependencies: 285 8
-- Name: taxreg_taxreg_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE taxreg_taxreg_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.taxreg_taxreg_id_seq OWNER TO admin;

--
-- TOC entry 10290 (class 0 OID 0)
-- Dependencies: 811
-- Name: taxreg_taxreg_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE taxreg_taxreg_id_seq OWNED BY taxreg.taxreg_id;


--
-- TOC entry 812 (class 1259 OID 146569970)
-- Dependencies: 199 8
-- Name: taxtype_taxtype_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE taxtype_taxtype_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.taxtype_taxtype_id_seq OWNER TO admin;

--
-- TOC entry 10292 (class 0 OID 0)
-- Dependencies: 812
-- Name: taxtype_taxtype_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE taxtype_taxtype_id_seq OWNED BY taxtype.taxtype_id;


--
-- TOC entry 813 (class 1259 OID 146569972)
-- Dependencies: 220 8
-- Name: taxzone_taxzone_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE taxzone_taxzone_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.taxzone_taxzone_id_seq OWNER TO admin;

--
-- TOC entry 10294 (class 0 OID 0)
-- Dependencies: 813
-- Name: taxzone_taxzone_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE taxzone_taxzone_id_seq OWNED BY taxzone.taxzone_id;


--
-- TOC entry 814 (class 1259 OID 146569974)
-- Dependencies: 8
-- Name: terms_terms_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE terms_terms_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.terms_terms_id_seq OWNER TO admin;

--
-- TOC entry 815 (class 1259 OID 146569976)
-- Dependencies: 233 8
-- Name: todoitem_todoitem_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE todoitem_todoitem_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.todoitem_todoitem_id_seq OWNER TO admin;

--
-- TOC entry 10297 (class 0 OID 0)
-- Dependencies: 815
-- Name: todoitem_todoitem_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE todoitem_todoitem_id_seq OWNED BY todoitem.todoitem_id;


--
-- TOC entry 816 (class 1259 OID 146569978)
-- Dependencies: 8
-- Name: trgthist; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE trgthist (
    trgthist_src_cntct_id integer NOT NULL,
    trgthist_trgt_cntct_id integer NOT NULL,
    trgthist_col text NOT NULL,
    trgthist_value text NOT NULL
);


ALTER TABLE public.trgthist OWNER TO admin;

--
-- TOC entry 817 (class 1259 OID 146569984)
-- Dependencies: 6674 8
-- Name: trialbal; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE trialbal (
    trialbal_id integer NOT NULL,
    trialbal_period_id integer,
    trialbal_accnt_id integer,
    trialbal_beginning numeric(20,2),
    trialbal_ending numeric(20,2),
    trialbal_credits numeric(20,2),
    trialbal_debits numeric(20,2),
    trialbal_dirty boolean,
    trialbal_yearend numeric(20,2) DEFAULT 0.00 NOT NULL
);


ALTER TABLE public.trialbal OWNER TO admin;

--
-- TOC entry 10300 (class 0 OID 0)
-- Dependencies: 817
-- Name: TABLE trialbal; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE trialbal IS 'Trial Balance information';


--
-- TOC entry 818 (class 1259 OID 146569988)
-- Dependencies: 817 8
-- Name: trialbal_trialbal_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE trialbal_trialbal_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.trialbal_trialbal_id_seq OWNER TO admin;

--
-- TOC entry 10302 (class 0 OID 0)
-- Dependencies: 818
-- Name: trialbal_trialbal_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE trialbal_trialbal_id_seq OWNED BY trialbal.trialbal_id;


--
-- TOC entry 819 (class 1259 OID 146569990)
-- Dependencies: 200 8
-- Name: uom_uom_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE uom_uom_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.uom_uom_id_seq OWNER TO admin;

--
-- TOC entry 10304 (class 0 OID 0)
-- Dependencies: 819
-- Name: uom_uom_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE uom_uom_id_seq OWNED BY uom.uom_id;


--
-- TOC entry 820 (class 1259 OID 146569992)
-- Dependencies: 6676 8
-- Name: uomconv; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE uomconv (
    uomconv_id integer NOT NULL,
    uomconv_from_uom_id integer NOT NULL,
    uomconv_from_value numeric(20,10) NOT NULL,
    uomconv_to_uom_id integer NOT NULL,
    uomconv_to_value numeric(20,10) NOT NULL,
    uomconv_fractional boolean DEFAULT false NOT NULL
);


ALTER TABLE public.uomconv OWNER TO admin;

--
-- TOC entry 10306 (class 0 OID 0)
-- Dependencies: 820
-- Name: TABLE uomconv; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE uomconv IS 'UOM conversion information. From Unit to To Unit with a value per ratio.';


--
-- TOC entry 821 (class 1259 OID 146569996)
-- Dependencies: 820 8
-- Name: uomconv_uomconv_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE uomconv_uomconv_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.uomconv_uomconv_id_seq OWNER TO admin;

--
-- TOC entry 10308 (class 0 OID 0)
-- Dependencies: 821
-- Name: uomconv_uomconv_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE uomconv_uomconv_id_seq OWNED BY uomconv.uomconv_id;


--
-- TOC entry 822 (class 1259 OID 146569998)
-- Dependencies: 6678 6679 8
-- Name: uomtype; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE uomtype (
    uomtype_id integer NOT NULL,
    uomtype_name text NOT NULL,
    uomtype_descrip text,
    uomtype_multiple boolean DEFAULT false NOT NULL,
    CONSTRAINT uomtype_uomtype_name_check CHECK ((uomtype_name <> ''::text))
);


ALTER TABLE public.uomtype OWNER TO admin;

--
-- TOC entry 10310 (class 0 OID 0)
-- Dependencies: 822
-- Name: TABLE uomtype; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE uomtype IS 'UOM Type values.';


--
-- TOC entry 823 (class 1259 OID 146570006)
-- Dependencies: 822 8
-- Name: uomtype_uomtype_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE uomtype_uomtype_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.uomtype_uomtype_id_seq OWNER TO admin;

--
-- TOC entry 10312 (class 0 OID 0)
-- Dependencies: 823
-- Name: uomtype_uomtype_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE uomtype_uomtype_id_seq OWNED BY uomtype.uomtype_id;


--
-- TOC entry 824 (class 1259 OID 146570008)
-- Dependencies: 244 8
-- Name: urlinfo_url_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE urlinfo_url_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.urlinfo_url_id_seq OWNER TO admin;

--
-- TOC entry 10314 (class 0 OID 0)
-- Dependencies: 824
-- Name: urlinfo_url_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE urlinfo_url_id_seq OWNED BY urlinfo.url_id;


--
-- TOC entry 825 (class 1259 OID 146570010)
-- Dependencies: 6680 8
-- Name: usrpref; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE usrpref (
    usrpref_id integer DEFAULT nextval(('usrpref_usrpref_id_seq'::text)::regclass) NOT NULL,
    usrpref_name text,
    usrpref_value text,
    usrpref_username text
);


ALTER TABLE public.usrpref OWNER TO admin;

--
-- TOC entry 10316 (class 0 OID 0)
-- Dependencies: 825
-- Name: TABLE usrpref; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE usrpref IS 'User Preferences information';


--
-- TOC entry 827 (class 1259 OID 146570022)
-- Dependencies: 6681 8
-- Name: usr_bak; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE usr_bak (
    usr_id integer DEFAULT nextval(('usr_usr_id_seq'::text)::regclass) NOT NULL,
    usr_username text NOT NULL,
    usr_propername text,
    usr_passwd text,
    usr_locale_id integer NOT NULL,
    usr_initials text,
    usr_agent boolean NOT NULL,
    usr_active boolean NOT NULL,
    usr_email text,
    usr_window text
);


ALTER TABLE public.usr_bak OWNER TO admin;

--
-- TOC entry 10319 (class 0 OID 0)
-- Dependencies: 827
-- Name: TABLE usr_bak; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE usr_bak IS 'User information';


--
-- TOC entry 828 (class 1259 OID 146570029)
-- Dependencies: 8
-- Name: usr_usr_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE usr_usr_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.usr_usr_id_seq OWNER TO admin;

--
-- TOC entry 829 (class 1259 OID 146570031)
-- Dependencies: 732 8
-- Name: usrgrp_usrgrp_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE usrgrp_usrgrp_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.usrgrp_usrgrp_id_seq OWNER TO admin;

--
-- TOC entry 10322 (class 0 OID 0)
-- Dependencies: 829
-- Name: usrgrp_usrgrp_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE usrgrp_usrgrp_id_seq OWNED BY usrgrp.usrgrp_id;


--
-- TOC entry 830 (class 1259 OID 146570033)
-- Dependencies: 8
-- Name: usrpref_usrpref_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE usrpref_usrpref_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.usrpref_usrpref_id_seq OWNER TO admin;

--
-- TOC entry 831 (class 1259 OID 146570035)
-- Dependencies: 8
-- Name: usrpriv_usrpriv_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE usrpriv_usrpriv_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.usrpriv_usrpriv_id_seq OWNER TO admin;


--
-- TOC entry 833 (class 1259 OID 146570042)
-- Dependencies: 8
-- Name: vend_vend_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE vend_vend_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.vend_vend_id_seq OWNER TO admin;


--
-- TOC entry 835 (class 1259 OID 146570049)
-- Dependencies: 8
-- Name: vendaddr_vendaddr_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE vendaddr_vendaddr_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.vendaddr_vendaddr_id_seq OWNER TO admin;

--
-- TOC entry 836 (class 1259 OID 146570051)
-- Dependencies: 393 8
-- Name: vendtype_vendtype_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE vendtype_vendtype_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.vendtype_vendtype_id_seq OWNER TO admin;

--
-- TOC entry 10330 (class 0 OID 0)
-- Dependencies: 836
-- Name: vendtype_vendtype_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE vendtype_vendtype_id_seq OWNED BY vendtype.vendtype_id;


--
-- TOC entry 837 (class 1259 OID 146570053)
-- Dependencies: 6682 6683 6684 6685 8
-- Name: vodist; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE vodist (
    vodist_id integer DEFAULT nextval(('"vodist_vodist_id_seq"'::text)::regclass) NOT NULL,
    vodist_poitem_id integer,
    vodist_vohead_id integer,
    vodist_costelem_id integer,
    vodist_accnt_id integer,
    vodist_amount numeric(18,6),
    vodist_qty numeric(18,6),
    vodist_expcat_id integer DEFAULT (-1),
    vodist_tax_id integer DEFAULT (-1),
    vodist_discountable boolean DEFAULT true NOT NULL,
    vodist_notes text
);


ALTER TABLE public.vodist OWNER TO admin;


--
-- TOC entry 838 (class 1259 OID 146570063)
-- Dependencies: 8
-- Name: vodist_vodist_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE vodist_vodist_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.vodist_vodist_id_seq OWNER TO admin;

--
-- TOC entry 839 (class 1259 OID 146570065)
-- Dependencies: 6686 6687 6688 8
-- Name: vohead; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE vohead (
    vohead_id integer DEFAULT nextval(('vohead_vohead_id_seq'::text)::regclass) NOT NULL,
    vohead_number text NOT NULL,
    vohead_pohead_id integer,
    vohead_posted boolean,
    vohead_duedate date,
    vohead_invcnumber text,
    vohead_amount numeric(16,4),
    vohead_docdate date,
    vohead_1099 boolean,
    vohead_distdate date,
    vohead_reference text,
    vohead_terms_id integer,
    vohead_vend_id integer,
    vohead_curr_id integer DEFAULT basecurrid(),
    vohead_adjtaxtype_id integer,
    vohead_freighttaxtype_id integer,
    vohead_gldistdate date,
    vohead_misc boolean,
    vohead_taxzone_id integer,
    vohead_taxtype_id integer,
    vohead_notes text,
    vohead_recurring_vohead_id integer,
    CONSTRAINT vohead_vohead_number_check CHECK ((vohead_number <> ''::text))
);


ALTER TABLE public.vohead OWNER TO admin;


--
-- TOC entry 840 (class 1259 OID 146570074)
-- Dependencies: 8
-- Name: vohead_vohead_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE vohead_vohead_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.vohead_vohead_id_seq OWNER TO admin;

--
-- TOC entry 841 (class 1259 OID 146570076)
-- Dependencies: 377 8
-- Name: voheadtax; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE voheadtax (
)
INHERITS (taxhist);


ALTER TABLE public.voheadtax OWNER TO admin;

--
-- TOC entry 842 (class 1259 OID 146570082)
-- Dependencies: 6690 6691 8
-- Name: voitem; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE voitem (
    voitem_id integer DEFAULT nextval(('"voitem_voitem_id_seq"'::text)::regclass) NOT NULL,
    voitem_vohead_id integer,
    voitem_poitem_id integer,
    voitem_close boolean,
    voitem_qty numeric(18,6),
    voitem_freight numeric(16,4) DEFAULT 0.0 NOT NULL,
    voitem_taxtype_id integer
);


ALTER TABLE public.voitem OWNER TO admin;

--
-- TOC entry 10339 (class 0 OID 0)
-- Dependencies: 842
-- Name: TABLE voitem; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE voitem IS 'Voucher Line Item information';


--
-- TOC entry 843 (class 1259 OID 146570087)
-- Dependencies: 8
-- Name: voitem_voitem_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE voitem_voitem_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.voitem_voitem_id_seq OWNER TO admin;

--
-- TOC entry 844 (class 1259 OID 146570089)
-- Dependencies: 377 8
-- Name: voitemtax; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE voitemtax (
)
INHERITS (taxhist);


ALTER TABLE public.voitemtax OWNER TO admin;


--
-- TOC entry 846 (class 1259 OID 146570100)
-- Dependencies: 8
-- Name: warehous_warehous_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE warehous_warehous_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.warehous_warehous_id_seq OWNER TO admin;

--
-- TOC entry 847 (class 1259 OID 146570102)
-- Dependencies: 343 8
-- Name: whsezone_whsezone_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE whsezone_whsezone_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.whsezone_whsezone_id_seq OWNER TO admin;

--
-- TOC entry 10345 (class 0 OID 0)
-- Dependencies: 847
-- Name: whsezone_whsezone_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE whsezone_whsezone_id_seq OWNED BY whsezone.whsezone_id;


--
-- TOC entry 848 (class 1259 OID 146570104)
-- Dependencies: 8
-- Name: wo_wo_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE wo_wo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.wo_wo_id_seq OWNER TO admin;

--
-- TOC entry 849 (class 1259 OID 146570106)
-- Dependencies: 8
-- Name: womatl_womatl_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE womatl_womatl_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.womatl_womatl_id_seq OWNER TO admin;

--
-- TOC entry 850 (class 1259 OID 146570108)
-- Dependencies: 8
-- Name: womatlpost; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE womatlpost (
    womatlpost_id integer NOT NULL,
    womatlpost_womatl_id integer,
    womatlpost_invhist_id integer
);


ALTER TABLE public.womatlpost OWNER TO admin;

--
-- TOC entry 10349 (class 0 OID 0)
-- Dependencies: 850
-- Name: TABLE womatlpost; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE womatlpost IS 'Table to tie work order to work order material transactions for efficient queries';


--
-- TOC entry 851 (class 1259 OID 146570111)
-- Dependencies: 850 8
-- Name: womatlpost_womatlpost_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE womatlpost_womatlpost_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.womatlpost_womatlpost_id_seq OWNER TO admin;

--
-- TOC entry 10351 (class 0 OID 0)
-- Dependencies: 851
-- Name: womatlpost_womatlpost_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE womatlpost_womatlpost_id_seq OWNED BY womatlpost.womatlpost_id;


--
-- TOC entry 852 (class 1259 OID 146570113)
-- Dependencies: 6694 6695 8
-- Name: womatlvar; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE womatlvar (
    womatlvar_id integer DEFAULT nextval(('"womatlvar_womatlvar_id_seq"'::text)::regclass) NOT NULL,
    womatlvar_number integer,
    womatlvar_subnumber integer,
    womatlvar_posted date,
    womatlvar_parent_itemsite_id integer,
    womatlvar_component_itemsite_id integer,
    womatlvar_qtyord numeric(18,6),
    womatlvar_qtyrcv numeric(18,6),
    womatlvar_qtyiss numeric(18,6),
    womatlvar_qtyper numeric(18,6),
    womatlvar_scrap numeric(18,6),
    womatlvar_wipscrap numeric(18,6),
    womatlvar_bomitem_id integer,
    womatlvar_ref text,
    womatlvar_notes text,
    womatlvar_qtyfxd numeric(20,8) DEFAULT 0 NOT NULL
);


ALTER TABLE public.womatlvar OWNER TO admin;

--
-- TOC entry 10353 (class 0 OID 0)
-- Dependencies: 852
-- Name: TABLE womatlvar; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE womatlvar IS 'Work Order Material Requirements Variance information';


--
-- TOC entry 10354 (class 0 OID 0)
-- Dependencies: 852
-- Name: COLUMN womatlvar.womatlvar_qtyfxd; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN womatlvar.womatlvar_qtyfxd IS 'The fixed quantity required';


--
-- TOC entry 853 (class 1259 OID 146570121)
-- Dependencies: 8
-- Name: womatlvar_womatlvar_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE womatlvar_womatlvar_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.womatlvar_womatlvar_id_seq OWNER TO admin;

--
-- TOC entry 854 (class 1259 OID 146570123)
-- Dependencies: 8
-- Name: xcalitem_xcalitem_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE xcalitem_xcalitem_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.xcalitem_xcalitem_id_seq OWNER TO admin;

--
-- TOC entry 855 (class 1259 OID 146570125)
-- Dependencies: 6697 6698 6699 6700 8
-- Name: xsltmap; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE xsltmap (
    xsltmap_id integer NOT NULL,
    xsltmap_name text NOT NULL,
    xsltmap_doctype text NOT NULL,
    xsltmap_system text NOT NULL,
    xsltmap_import text NOT NULL,
    xsltmap_export text DEFAULT ''::text NOT NULL,
    CONSTRAINT xsltmap_check CHECK (((xsltmap_doctype <> ''::text) OR (xsltmap_system <> ''::text))),
    CONSTRAINT xsltmap_xsltmap_importexport_check CHECK (((xsltmap_import <> ''::text) OR (xsltmap_export <> ''::text))),
    CONSTRAINT xsltmap_xsltmap_name_check CHECK ((xsltmap_name <> ''::text))
);


ALTER TABLE public.xsltmap OWNER TO admin;

--
-- TOC entry 10358 (class 0 OID 0)
-- Dependencies: 855
-- Name: TABLE xsltmap; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE xsltmap IS 'Mapping of XML System identifiers to XSLT transformation files';


--
-- TOC entry 856 (class 1259 OID 146570135)
-- Dependencies: 855 8
-- Name: xsltmap_xsltmap_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE xsltmap_xsltmap_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.xsltmap_xsltmap_id_seq OWNER TO admin;

--
-- TOC entry 10360 (class 0 OID 0)
-- Dependencies: 856
-- Name: xsltmap_xsltmap_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE xsltmap_xsltmap_id_seq OWNED BY xsltmap.xsltmap_id;


--
-- TOC entry 857 (class 1259 OID 146570137)
-- Dependencies: 6702 8
-- Name: yearperiod; Type: TABLE; Schema: public; Owner: admin; Tablespace:
--

CREATE TABLE yearperiod (
    yearperiod_id integer NOT NULL,
    yearperiod_start date NOT NULL,
    yearperiod_end date NOT NULL,
    yearperiod_closed boolean DEFAULT false NOT NULL
);


ALTER TABLE public.yearperiod OWNER TO admin;

--
-- TOC entry 10362 (class 0 OID 0)
-- Dependencies: 857
-- Name: TABLE yearperiod; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE yearperiod IS 'Accounting Year Periods information';


--
-- TOC entry 858 (class 1259 OID 146570141)
-- Dependencies: 857 8
-- Name: yearperiod_yearperiod_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE yearperiod_yearperiod_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.yearperiod_yearperiod_id_seq OWNER TO admin;

--
-- TOC entry 10364 (class 0 OID 0)
-- Dependencies: 858
-- Name: yearperiod_yearperiod_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE yearperiod_yearperiod_id_seq OWNED BY yearperiod.yearperiod_id;


--
-- TOC entry 6055 (class 2604 OID 146570320)
-- Dependencies: 422 234
-- Name: addr_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY addr ALTER COLUMN addr_id SET DEFAULT nextval('addr_addr_id_seq'::regclass);


--
-- TOC entry 6290 (class 2604 OID 146570321)
-- Dependencies: 425 424
-- Name: alarm_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY alarm ALTER COLUMN alarm_id SET DEFAULT nextval('alarm_alarm_id_seq'::regclass);


--
-- TOC entry 6291 (class 2604 OID 146570322)
-- Dependencies: 427 426
-- Name: apaccnt_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY apaccnt ALTER COLUMN apaccnt_id SET DEFAULT nextval('apaccnt_apaccnt_id_seq'::regclass);


--
-- TOC entry 6292 (class 2604 OID 146570323)
-- Dependencies: 429 428
-- Name: apapply_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY apapply ALTER COLUMN apapply_id SET DEFAULT nextval('apapply_apapply_id_seq'::regclass);


--
-- TOC entry 6310 (class 2604 OID 146570324)
-- Dependencies: 435 434
-- Name: apcreditapply_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY apcreditapply ALTER COLUMN apcreditapply_id SET DEFAULT nextval('apcreditapply_apcreditapply_id_seq'::regclass);


--
-- TOC entry 6312 (class 2604 OID 146570448)
-- Dependencies: 438 378 438
-- Name: taxhist_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY apopentax ALTER COLUMN taxhist_id SET DEFAULT nextval('taxhist_taxhist_id_seq'::regclass);


--
-- TOC entry 6313 (class 2604 OID 146570325)
-- Dependencies: 440 439
-- Name: apselect_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY apselect ALTER COLUMN apselect_id SET DEFAULT nextval('apselect_apselect_id_seq'::regclass);


--
-- TOC entry 6317 (class 2604 OID 146570326)
-- Dependencies: 444 443
-- Name: arapply_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY arapply ALTER COLUMN arapply_id SET DEFAULT nextval('arapply_arapply_id_seq'::regclass);


--
-- TOC entry 6321 (class 2604 OID 146570449)
-- Dependencies: 450 378 450
-- Name: taxhist_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY aropentax ALTER COLUMN taxhist_id SET DEFAULT nextval('taxhist_taxhist_id_seq'::regclass);


--
-- TOC entry 6322 (class 2604 OID 146570327)
-- Dependencies: 452 451
-- Name: asohist_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY asohist ALTER COLUMN asohist_id SET DEFAULT nextval('asohist_asohist_id_seq'::regclass);


--
-- TOC entry 6324 (class 2604 OID 146570450)
-- Dependencies: 453 378 453
-- Name: taxhist_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY asohisttax ALTER COLUMN taxhist_id SET DEFAULT nextval('taxhist_taxhist_id_seq'::regclass);


--
-- TOC entry 6325 (class 2604 OID 146570328)
-- Dependencies: 455 454
-- Name: atlasmap_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY atlasmap ALTER COLUMN atlasmap_id SET DEFAULT nextval('atlasmap_atlasmap_id_seq'::regclass);


--
-- TOC entry 6107 (class 2604 OID 146570329)
-- Dependencies: 457 266
-- Name: bankaccnt_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY bankaccnt ALTER COLUMN bankaccnt_id SET DEFAULT nextval('bankaccnt_bankaccnt_id_seq'::regclass);


--
-- TOC entry 6332 (class 2604 OID 146570330)
-- Dependencies: 459 458
-- Name: bankadj_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY bankadj ALTER COLUMN bankadj_id SET DEFAULT nextval('bankadj_bankadj_id_seq'::regclass);


--
-- TOC entry 6333 (class 2604 OID 146570331)
-- Dependencies: 461 460
-- Name: bankadjtype_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY bankadjtype ALTER COLUMN bankadjtype_id SET DEFAULT nextval('bankadjtype_bankadjtype_id_seq'::regclass);


--
-- TOC entry 6339 (class 2604 OID 146570332)
-- Dependencies: 463 462
-- Name: bankrec_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY bankrec ALTER COLUMN bankrec_id SET DEFAULT nextval('bankrec_bankrec_id_seq'::regclass);


--
-- TOC entry 6340 (class 2604 OID 146570333)
-- Dependencies: 465 464
-- Name: bankrecitem_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY bankrecitem ALTER COLUMN bankrecitem_id SET DEFAULT nextval('bankrecitem_bankrecitem_id_seq'::regclass);


--
-- TOC entry 6346 (class 2604 OID 146570334)
-- Dependencies: 469 468
-- Name: bomitemcost_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY bomitemcost ALTER COLUMN bomitemcost_id SET DEFAULT nextval('bomitemcost_bomitemcost_id_seq'::regclass);


--
-- TOC entry 6092 (class 2604 OID 146570335)
-- Dependencies: 470 258
-- Name: bomitemsub_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY bomitemsub ALTER COLUMN bomitemsub_id SET DEFAULT nextval('bomitemsub_bomitemsub_id_seq'::regclass);


--
-- TOC entry 6347 (class 2604 OID 146570336)
-- Dependencies: 472 471
-- Name: bomwork_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY bomwork ALTER COLUMN bomwork_id SET DEFAULT nextval('bomwork_bomwork_id_seq'::regclass);


--
-- TOC entry 6093 (class 2604 OID 146570337)
-- Dependencies: 474 260
-- Name: budghead_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY budghead ALTER COLUMN budghead_id SET DEFAULT nextval('budghead_budghead_id_seq'::regclass);


--
-- TOC entry 6099 (class 2604 OID 146570338)
-- Dependencies: 475 263
-- Name: budgitem_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY budgitem ALTER COLUMN budgitem_id SET DEFAULT nextval('budgitem_budgitem_id_seq'::regclass);


--
-- TOC entry 6116 (class 2604 OID 146570339)
-- Dependencies: 479 267
-- Name: cashrcpt_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY cashrcpt ALTER COLUMN cashrcpt_id SET DEFAULT nextval('cashrcpt_cashrcpt_id_seq'::regclass);


--
-- TOC entry 6118 (class 2604 OID 146570340)
-- Dependencies: 445 269
-- Name: cashrcptitem_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY cashrcptitem ALTER COLUMN cashrcptitem_id SET DEFAULT nextval('cashrcptitem_cashrcptitem_id_seq'::regclass);


--
-- TOC entry 6121 (class 2604 OID 146570341)
-- Dependencies: 480 271
-- Name: cashrcptmisc_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY cashrcptmisc ALTER COLUMN cashrcptmisc_id SET DEFAULT nextval('cashrcptmisc_cashrcptmisc_id_seq'::regclass);


--
-- TOC entry 6129 (class 2604 OID 146570342)
-- Dependencies: 481 278
-- Name: ccard_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY ccard ALTER COLUMN ccard_id SET DEFAULT nextval('ccard_ccard_id_seq'::regclass);


--
-- TOC entry 6352 (class 2604 OID 146570343)
-- Dependencies: 483 482
-- Name: ccardaud_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY ccardaud ALTER COLUMN ccardaud_id SET DEFAULT nextval('ccardaud_ccardaud_id_seq'::regclass);


--
-- TOC entry 6355 (class 2604 OID 146570344)
-- Dependencies: 485 484
-- Name: ccbank_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY ccbank ALTER COLUMN ccbank_id SET DEFAULT nextval('ccbank_ccbank_id_seq'::regclass);


--
-- TOC entry 6362 (class 2604 OID 146570345)
-- Dependencies: 487 486
-- Name: ccpay_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY ccpay ALTER COLUMN ccpay_id SET DEFAULT nextval('ccpay_ccpay_id_seq'::regclass);


--
-- TOC entry 6070 (class 2604 OID 146570346)
-- Dependencies: 488 236
-- Name: char_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY "char" ALTER COLUMN char_id SET DEFAULT nextval('char_char_id_seq'::regclass);


--
-- TOC entry 6072 (class 2604 OID 146570347)
-- Dependencies: 489 237
-- Name: charass_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY charass ALTER COLUMN charass_id SET DEFAULT nextval('charass_charass_id_seq'::regclass);


--
-- TOC entry 6363 (class 2604 OID 146570348)
-- Dependencies: 491 490
-- Name: charopt_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY charopt ALTER COLUMN charopt_id SET DEFAULT nextval('charopt_charopt_id_seq'::regclass);


--
-- TOC entry 6302 (class 2604 OID 146570349)
-- Dependencies: 492 430
-- Name: checkhead_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY checkhead ALTER COLUMN checkhead_id SET DEFAULT nextval('checkhead_checkhead_id_seq'::regclass);


--
-- TOC entry 6308 (class 2604 OID 146570350)
-- Dependencies: 493 432
-- Name: checkitem_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY checkitem ALTER COLUMN checkitem_id SET DEFAULT nextval('checkitem_checkitem_id_seq'::regclass);


--
-- TOC entry 6265 (class 2604 OID 146568218)
-- Dependencies: 398 397
-- Name: cmd_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY cmd ALTER COLUMN cmd_id SET DEFAULT nextval('cmd_cmd_id_seq'::regclass);


--
-- TOC entry 6267 (class 2604 OID 146568234)
-- Dependencies: 401 400
-- Name: cmdarg_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY cmdarg ALTER COLUMN cmdarg_id SET DEFAULT nextval('cmdarg_cmdarg_id_seq'::regclass);


--
-- TOC entry 6365 (class 2604 OID 146570451)
-- Dependencies: 497 378 497
-- Name: taxhist_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY cmheadtax ALTER COLUMN taxhist_id SET DEFAULT nextval('taxhist_taxhist_id_seq'::regclass);


--
-- TOC entry 6366 (class 2604 OID 146570452)
-- Dependencies: 499 378 499
-- Name: taxhist_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY cmitemtax ALTER COLUMN taxhist_id SET DEFAULT nextval('taxhist_taxhist_id_seq'::regclass);


--
-- TOC entry 6075 (class 2604 OID 146570351)
-- Dependencies: 500 239
-- Name: cmnttype_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY cmnttype ALTER COLUMN cmnttype_id SET DEFAULT nextval('cmnttype_cmnttype_id_seq'::regclass);


--
-- TOC entry 6367 (class 2604 OID 146570352)
-- Dependencies: 502 501
-- Name: cmnttypesource_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY cmnttypesource ALTER COLUMN cmnttypesource_id SET DEFAULT nextval('cmnttypesource_cmnttypesource_id_seq'::regclass);


--
-- TOC entry 5944 (class 2604 OID 146570353)
-- Dependencies: 503 204
-- Name: cntct_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY cntct ALTER COLUMN cntct_id SET DEFAULT nextval('cntct_cntct_id_seq'::regclass);


--
-- TOC entry 6368 (class 2604 OID 146570354)
-- Dependencies: 505 504
-- Name: cntctaddr_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY cntctaddr ALTER COLUMN cntctaddr_id SET DEFAULT nextval('cntctaddr_cntctaddr_id_seq'::regclass);


--
-- TOC entry 6369 (class 2604 OID 146570355)
-- Dependencies: 507 506
-- Name: cntctdata_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY cntctdata ALTER COLUMN cntctdata_id SET DEFAULT nextval('cntctdata_cntctdata_id_seq'::regclass);


--
-- TOC entry 6370 (class 2604 OID 146570356)
-- Dependencies: 509 508
-- Name: cntcteml_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY cntcteml ALTER COLUMN cntcteml_id SET DEFAULT nextval('cntcteml_cntcteml_id_seq'::regclass);


--
-- TOC entry 6390 (class 2604 OID 146570453)
-- Dependencies: 515 378 515
-- Name: taxhist_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY cobilltax ALTER COLUMN taxhist_id SET DEFAULT nextval('taxhist_taxhist_id_seq'::regclass);


--
-- TOC entry 6393 (class 2604 OID 146570454)
-- Dependencies: 518 378 518
-- Name: taxhist_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY cobmisctax ALTER COLUMN taxhist_id SET DEFAULT nextval('taxhist_taxhist_id_seq'::regclass);


--
-- TOC entry 6258 (class 2604 OID 146570447)
-- Dependencies: 379 378 379
-- Name: taxhist_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY cohisttax ALTER COLUMN taxhist_id SET DEFAULT nextval('taxhist_taxhist_id_seq'::regclass);


--
-- TOC entry 6394 (class 2604 OID 146570357)
-- Dependencies: 524 523
-- Name: company_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY company ALTER COLUMN company_id SET DEFAULT nextval('company_company_id_seq'::regclass);


--
-- TOC entry 6193 (class 2604 OID 146570358)
-- Dependencies: 525 329
-- Name: contrct_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY contrct ALTER COLUMN contrct_id SET DEFAULT nextval('contrct_contrct_id_seq'::regclass);


--
-- TOC entry 6411 (class 2604 OID 146570359)
-- Dependencies: 539 538
-- Name: country_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY country ALTER COLUMN country_id SET DEFAULT nextval('country_country_id_seq'::regclass);


--
-- TOC entry 5946 (class 2604 OID 146570360)
-- Dependencies: 543 205
-- Name: crmacct_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY crmacct ALTER COLUMN crmacct_id SET DEFAULT nextval('crmacct_crmacct_id_seq'::regclass);


--
-- TOC entry 6433 (class 2604 OID 146570361)
-- Dependencies: 546 545
-- Name: curr_rate_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY curr_rate ALTER COLUMN curr_rate_id SET DEFAULT nextval('curr_rate_curr_rate_id_seq'::regclass);


--
-- TOC entry 5965 (class 2604 OID 146570362)
-- Dependencies: 547 208
-- Name: curr_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY curr_symbol ALTER COLUMN curr_id SET DEFAULT nextval('curr_symbol_curr_id_seq'::regclass);


--
-- TOC entry 6144 (class 2604 OID 146570363)
-- Dependencies: 557 291
-- Name: dept_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY dept ALTER COLUMN dept_id SET DEFAULT nextval('dept_dept_id_seq'::regclass);


--
-- TOC entry 6080 (class 2604 OID 146570364)
-- Dependencies: 247 242
-- Name: docass_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY docass ALTER COLUMN docass_id SET DEFAULT nextval('docass_docass_id_seq'::regclass);


--
-- TOC entry 6149 (class 2604 OID 146570365)
-- Dependencies: 562 292
-- Name: emp_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY emp ALTER COLUMN emp_id SET DEFAULT nextval('emp_emp_id_seq'::regclass);


--
-- TOC entry 6449 (class 2604 OID 146570366)
-- Dependencies: 564 563
-- Name: empgrp_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY empgrp ALTER COLUMN empgrp_id SET DEFAULT nextval('empgrp_empgrp_id_seq'::regclass);


--
-- TOC entry 6451 (class 2604 OID 146570367)
-- Dependencies: 566 565
-- Name: empgrpitem_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY empgrpitem ALTER COLUMN empgrpitem_id SET DEFAULT nextval('empgrpitem_empgrpitem_id_seq'::regclass);


--
-- TOC entry 6228 (class 2604 OID 146570368)
-- Dependencies: 573 358
-- Name: expcat_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY expcat ALTER COLUMN expcat_id SET DEFAULT nextval('expcat_expcat_id_seq'::regclass);


--
-- TOC entry 6084 (class 2604 OID 146570369)
-- Dependencies: 574 243
-- Name: file_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY file ALTER COLUMN file_id SET DEFAULT nextval('file_file_id_seq'::regclass);


--
-- TOC entry 6456 (class 2604 OID 146570370)
-- Dependencies: 576 575
-- Name: filter_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY filter ALTER COLUMN filter_id SET DEFAULT nextval('filter_filter_id_seq'::regclass);


--
-- TOC entry 6458 (class 2604 OID 146570371)
-- Dependencies: 578 577
-- Name: fincharg_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY fincharg ALTER COLUMN fincharg_id SET DEFAULT nextval('fincharg_fincharg_id_seq'::regclass);


--
-- TOC entry 6491 (class 2604 OID 146570372)
-- Dependencies: 583 582
-- Name: flcol_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY flcol ALTER COLUMN flcol_id SET DEFAULT nextval('flcol_flcol_id_seq'::regclass);


--
-- TOC entry 6509 (class 2604 OID 146570373)
-- Dependencies: 585 584
-- Name: flgrp_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY flgrp ALTER COLUMN flgrp_id SET DEFAULT nextval('flgrp_flgrp_id_seq'::regclass);


--
-- TOC entry 6477 (class 2604 OID 146570374)
-- Dependencies: 586 579
-- Name: flhead_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY flhead ALTER COLUMN flhead_id SET DEFAULT nextval('flhead_flhead_id_seq'::regclass);


--
-- TOC entry 6490 (class 2604 OID 146570375)
-- Dependencies: 587 580
-- Name: flitem_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY flitem ALTER COLUMN flitem_id SET DEFAULT nextval('flitem_flitem_id_seq'::regclass);


--
-- TOC entry 6510 (class 2604 OID 146570376)
-- Dependencies: 589 588
-- Name: flnotes_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY flnotes ALTER COLUMN flnotes_id SET DEFAULT nextval('flnotes_flnotes_id_seq'::regclass);


--
-- TOC entry 6512 (class 2604 OID 146570377)
-- Dependencies: 591 590
-- Name: flrpt_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY flrpt ALTER COLUMN flrpt_id SET DEFAULT nextval('flrpt_flrpt_id_seq'::regclass);


--
-- TOC entry 6527 (class 2604 OID 146570378)
-- Dependencies: 593 592
-- Name: flspec_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY flspec ALTER COLUMN flspec_id SET DEFAULT nextval('flspec_flspec_id_seq'::regclass);


--
-- TOC entry 6160 (class 2604 OID 146570379)
-- Dependencies: 596 299
-- Name: freightclass_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY freightclass ALTER COLUMN freightclass_id SET DEFAULT nextval('freightclass_freightclass_id_seq'::regclass);


--
-- TOC entry 6531 (class 2604 OID 146570380)
-- Dependencies: 602 601
-- Name: grp_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY grp ALTER COLUMN grp_id SET DEFAULT nextval('grp_grp_id_seq'::regclass);


--
-- TOC entry 6533 (class 2604 OID 146570381)
-- Dependencies: 604 603
-- Name: grppriv_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY grppriv ALTER COLUMN grppriv_id SET DEFAULT nextval('grppriv_grppriv_id_seq'::regclass);


--
-- TOC entry 6534 (class 2604 OID 146570382)
-- Dependencies: 606 605
-- Name: hnfc_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY hnfc ALTER COLUMN hnfc_id SET DEFAULT nextval('hnfc_hnfc_id_seq'::regclass);


--
-- TOC entry 5955 (class 2604 OID 146570383)
-- Dependencies: 607 206
-- Name: incdt_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY incdt ALTER COLUMN incdt_id SET DEFAULT nextval('incdt_incdt_id_seq'::regclass);


--
-- TOC entry 6168 (class 2604 OID 146570384)
-- Dependencies: 608 304
-- Name: incdtcat_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY incdtcat ALTER COLUMN incdtcat_id SET DEFAULT nextval('incdtcat_incdtcat_id_seq'::regclass);


--
-- TOC entry 6536 (class 2604 OID 146570385)
-- Dependencies: 610 609
-- Name: incdthist_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY incdthist ALTER COLUMN incdthist_id SET DEFAULT nextval('incdthist_incdthist_id_seq'::regclass);


--
-- TOC entry 6170 (class 2604 OID 146570386)
-- Dependencies: 611 305
-- Name: incdtpriority_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY incdtpriority ALTER COLUMN incdtpriority_id SET DEFAULT nextval('incdtpriority_incdtpriority_id_seq'::regclass);


--
-- TOC entry 6172 (class 2604 OID 146570387)
-- Dependencies: 612 306
-- Name: incdtresolution_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY incdtresolution ALTER COLUMN incdtresolution_id SET DEFAULT nextval('incdtresolution_incdtresolution_id_seq'::regclass);


--
-- TOC entry 6174 (class 2604 OID 146570388)
-- Dependencies: 613 307
-- Name: incdtseverity_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY incdtseverity ALTER COLUMN incdtseverity_id SET DEFAULT nextval('incdtseverity_incdtseverity_id_seq'::regclass);


--
-- TOC entry 5935 (class 2604 OID 146570389)
-- Dependencies: 614 202
-- Name: invbal_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY invbal ALTER COLUMN invbal_id SET DEFAULT nextval('invbal_invbal_id_seq'::regclass);


--
-- TOC entry 6025 (class 2604 OID 146570390)
-- Dependencies: 616 224
-- Name: invchead_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY invchead ALTER COLUMN invchead_id SET DEFAULT nextval('invchead_invchead_id_seq'::regclass);


--
-- TOC entry 6539 (class 2604 OID 146570455)
-- Dependencies: 617 378 617
-- Name: taxhist_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY invcheadtax ALTER COLUMN taxhist_id SET DEFAULT nextval('taxhist_taxhist_id_seq'::regclass);


--
-- TOC entry 6034 (class 2604 OID 146570391)
-- Dependencies: 618 229
-- Name: invcitem_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY invcitem ALTER COLUMN invcitem_id SET DEFAULT nextval('invcitem_invcitem_id_seq'::regclass);


--
-- TOC entry 6540 (class 2604 OID 146570456)
-- Dependencies: 619 378 619
-- Name: taxhist_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY invcitemtax ALTER COLUMN taxhist_id SET DEFAULT nextval('taxhist_taxhist_id_seq'::regclass);


--
-- TOC entry 6549 (class 2604 OID 146570392)
-- Dependencies: 626 625
-- Name: invhistexpcat_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY invhistexpcat ALTER COLUMN invhistexpcat_id SET DEFAULT nextval('invhistexpcat_invhistexpcat_id_seq'::regclass);


--
-- TOC entry 6217 (class 2604 OID 146570393)
-- Dependencies: 628 347
-- Name: ipsass_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY ipsass ALTER COLUMN ipsass_id SET DEFAULT nextval('ipsass_ipsass_id_seq'::regclass);


--
-- TOC entry 6162 (class 2604 OID 146570394)
-- Dependencies: 631 300
-- Name: ipsfreight_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY ipsfreight ALTER COLUMN ipsfreight_id SET DEFAULT nextval('ipsfreight_ipsfreight_id_seq'::regclass);


--
-- TOC entry 6223 (class 2604 OID 146570395)
-- Dependencies: 634 351
-- Name: ipsitemchar_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY ipsitemchar ALTER COLUMN ipsitemchar_id SET DEFAULT nextval('ipsitemchar_ipsitemchar_id_seq'::regclass);


--
-- TOC entry 6550 (class 2604 OID 146570396)
-- Dependencies: 637 636
-- Name: ipsprodcat_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY ipsprodcat_bak ALTER COLUMN ipsprodcat_id SET DEFAULT nextval('ipsprodcat_ipsprodcat_id_seq'::regclass);


--
-- TOC entry 6562 (class 2604 OID 146570397)
-- Dependencies: 655 654
-- Name: itemlocpost_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY itemlocpost ALTER COLUMN itemlocpost_id SET DEFAULT nextval('itemlocpost_itemlocpost_id_seq'::regclass);


--
-- TOC entry 6207 (class 2604 OID 146570398)
-- Dependencies: 661 336
-- Name: itemtax_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY itemtax ALTER COLUMN itemtax_id SET DEFAULT nextval('itemtax_itemtax_id_seq'::regclass);


--
-- TOC entry 6563 (class 2604 OID 146570399)
-- Dependencies: 663 662
-- Name: itemtrans_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY itemtrans ALTER COLUMN itemtrans_id SET DEFAULT nextval('itemtrans_itemtrans_id_seq'::regclass);


--
-- TOC entry 6564 (class 2604 OID 146570400)
-- Dependencies: 665 664
-- Name: itemuom_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY itemuom ALTER COLUMN itemuom_id SET DEFAULT nextval('itemuom_itemuom_id_seq'::regclass);


--
-- TOC entry 6208 (class 2604 OID 146570401)
-- Dependencies: 666 338
-- Name: itemuomconv_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY itemuomconv ALTER COLUMN itemuomconv_id SET DEFAULT nextval('itemuomconv_itemuomconv_id_seq'::regclass);


--
-- TOC entry 6566 (class 2604 OID 146570402)
-- Dependencies: 671 670
-- Name: labeldef_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY labeldef ALTER COLUMN labeldef_id SET DEFAULT nextval('labeldef_labeldef_id_seq'::regclass);


--
-- TOC entry 6569 (class 2604 OID 146570403)
-- Dependencies: 675 674
-- Name: lang_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY lang ALTER COLUMN lang_id SET DEFAULT nextval('lang_lang_id_seq'::regclass);


--
-- TOC entry 6270 (class 2604 OID 146568260)
-- Dependencies: 406 405
-- Name: metasql_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY metasql ALTER COLUMN metasql_id SET DEFAULT nextval('metasql_metasql_id_seq'::regclass);


--
-- TOC entry 6577 (class 2604 OID 146570404)
-- Dependencies: 685 684
-- Name: metricenc_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY metricenc ALTER COLUMN metricenc_id SET DEFAULT nextval('metricenc_metricenc_id_seq'::regclass);


--
-- TOC entry 6037 (class 2604 OID 146570405)
-- Dependencies: 695 231
-- Name: ophead_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY ophead ALTER COLUMN ophead_id SET DEFAULT nextval('ophead_ophead_id_seq'::regclass);


--
-- TOC entry 6584 (class 2604 OID 146570406)
-- Dependencies: 697 696
-- Name: opsource_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY opsource ALTER COLUMN opsource_id SET DEFAULT nextval('opsource_opsource_id_seq'::regclass);


--
-- TOC entry 6586 (class 2604 OID 146570407)
-- Dependencies: 699 698
-- Name: opstage_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY opstage ALTER COLUMN opstage_id SET DEFAULT nextval('opstage_opstage_id_seq'::regclass);


--
-- TOC entry 6590 (class 2604 OID 146570408)
-- Dependencies: 701 700
-- Name: optype_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY optype ALTER COLUMN optype_id SET DEFAULT nextval('optype_optype_id_seq'::regclass);


--
-- TOC entry 6594 (class 2604 OID 146570409)
-- Dependencies: 707 706
-- Name: pack_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY pack ALTER COLUMN pack_id SET DEFAULT nextval('pack_pack_id_seq'::regclass);


--
-- TOC entry 6100 (class 2604 OID 146570410)
-- Dependencies: 710 264
-- Name: period_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY period ALTER COLUMN period_id SET DEFAULT nextval('period_period_id_seq'::regclass);




--
-- TOC entry 6616 (class 2604 OID 146570415)
-- Dependencies: 731 730
-- Name: prftcntr_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY prftcntr ALTER COLUMN prftcntr_id SET DEFAULT nextval('prftcntr_prftcntr_id_seq'::regclass);


--
-- TOC entry 6027 (class 2604 OID 146570416)
-- Dependencies: 735 225
-- Name: prj_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY prj ALTER COLUMN prj_id SET DEFAULT nextval('prj_prj_id_seq'::regclass);


--
-- TOC entry 6040 (class 2604 OID 146570417)
-- Dependencies: 736 232
-- Name: prjtask_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY prjtask ALTER COLUMN prjtask_id SET DEFAULT nextval('prjtask_prjtask_id_seq'::regclass);


--
-- TOC entry 6620 (class 2604 OID 146570418)
-- Dependencies: 738 737
-- Name: prjtaskuser_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY prjtaskuser ALTER COLUMN prjtaskuser_id SET DEFAULT nextval('prjtaskuser_prjtaskuser_id_seq'::regclass);


--
-- TOC entry 6621 (class 2604 OID 146570419)
-- Dependencies: 740 739
-- Name: prjtype_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY prjtype ALTER COLUMN prjtype_id SET DEFAULT nextval('prjtype_prjtype_id_seq'::regclass);


--
-- TOC entry 6623 (class 2604 OID 146570420)
-- Dependencies: 743 742
-- Name: qryhead_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY qryhead ALTER COLUMN qryhead_id SET DEFAULT nextval('qryhead_qryhead_id_seq'::regclass);


--
-- TOC entry 6630 (class 2604 OID 146570421)
-- Dependencies: 745 744
-- Name: qryitem_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY qryitem ALTER COLUMN qryitem_id SET DEFAULT nextval('qryitem_qryitem_id_seq'::regclass);


--
-- TOC entry 6638 (class 2604 OID 146570423)
-- Dependencies: 752 751
-- Name: recurtype_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY recurtype ALTER COLUMN recurtype_id SET DEFAULT nextval('recurtype_recurtype_id_seq'::regclass);


--
-- TOC entry 6610 (class 2604 OID 146570424)
-- Dependencies: 753 721
-- Name: recv_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY recv ALTER COLUMN recv_id SET DEFAULT nextval('recv_recv_id_seq'::regclass);


--
-- TOC entry 6006 (class 2604 OID 146570425)
-- Dependencies: 757 214
-- Name: rsncode_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY rsncode ALTER COLUMN rsncode_id SET DEFAULT nextval('rsncode_rsncode_id_seq'::regclass);


--
-- TOC entry 6008 (class 2604 OID 146570426)
-- Dependencies: 761 215
-- Name: salescat_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY salescat ALTER COLUMN salescat_id SET DEFAULT nextval('salescat_salescat_id_seq'::regclass);


--
-- TOC entry 6030 (class 2604 OID 146570427)
-- Dependencies: 765 226
-- Name: saletype_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY saletype ALTER COLUMN saletype_id SET DEFAULT nextval('saletype_saletype_id_seq'::regclass);


--
-- TOC entry 6643 (class 2604 OID 146570428)
-- Dependencies: 767 766
-- Name: schemaord_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY schemaord ALTER COLUMN schemaord_id SET DEFAULT nextval('schemaord_schemaord_id_seq'::regclass);


--
-- TOC entry 6278 (class 2604 OID 146568310)
-- Dependencies: 415 414
-- Name: script_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY script ALTER COLUMN script_id SET DEFAULT nextval('script_script_id_seq'::regclass);


--
-- TOC entry 6154 (class 2604 OID 146570429)
-- Dependencies: 769 293
-- Name: shift_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY shift ALTER COLUMN shift_id SET DEFAULT nextval('shift_shift_id_seq'::regclass);


--
-- TOC entry 6133 (class 2604 OID 146570430)
-- Dependencies: 770 281
-- Name: shipchrg_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY shipchrg ALTER COLUMN shipchrg_id SET DEFAULT nextval('shipchrg_shipchrg_id_seq'::regclass);


--
-- TOC entry 6400 (class 2604 OID 146570431)
-- Dependencies: 773 526
-- Name: shiphead_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY shiphead ALTER COLUMN shiphead_id SET DEFAULT nextval('shiphead_shiphead_id_seq'::regclass);


--
-- TOC entry 6404 (class 2604 OID 146570432)
-- Dependencies: 774 527
-- Name: shipitem_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY shipitem ALTER COLUMN shipitem_id SET DEFAULT nextval('shipitem_shipitem_id_seq'::regclass);


--
-- TOC entry 6261 (class 2604 OID 146570433)
-- Dependencies: 780 387
-- Name: sitetype_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY sitetype ALTER COLUMN sitetype_id SET DEFAULT nextval('sitetype_sitetype_id_seq'::regclass);


--
-- TOC entry 6654 (class 2604 OID 146570434)
-- Dependencies: 786 785
-- Name: source_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY source ALTER COLUMN source_id SET DEFAULT nextval('source_source_id_seq'::regclass);


--
-- TOC entry 6656 (class 2604 OID 146570435)
-- Dependencies: 788 787
-- Name: state_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY state ALTER COLUMN state_id SET DEFAULT nextval('state_state_id_seq'::regclass);


--
-- TOC entry 6658 (class 2604 OID 146570436)
-- Dependencies: 790 789
-- Name: status_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY status ALTER COLUMN status_id SET DEFAULT nextval('status_status_id_seq'::regclass);


--
-- TOC entry 6660 (class 2604 OID 146570437)
-- Dependencies: 792 791
-- Name: stdjrnl_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY stdjrnl ALTER COLUMN stdjrnl_id SET DEFAULT nextval('stdjrnl_stdjrnl_id_seq'::regclass);


--
-- TOC entry 6662 (class 2604 OID 146570438)
-- Dependencies: 794 793
-- Name: stdjrnlgrp_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY stdjrnlgrp ALTER COLUMN stdjrnlgrp_id SET DEFAULT nextval('stdjrnlgrp_stdjrnlgrp_id_seq'::regclass);


--
-- TOC entry 6664 (class 2604 OID 146570439)
-- Dependencies: 796 795
-- Name: stdjrnlgrpitem_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY stdjrnlgrpitem ALTER COLUMN stdjrnlgrpitem_id SET DEFAULT nextval('stdjrnlgrpitem_stdjrnlgrpitem_id_seq'::regclass);


--
-- TOC entry 6665 (class 2604 OID 146570440)
-- Dependencies: 798 797
-- Name: stdjrnlitem_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY stdjrnlitem ALTER COLUMN stdjrnlitem_id SET DEFAULT nextval('stdjrnlitem_stdjrnlitem_id_seq'::regclass);


--
-- TOC entry 6666 (class 2604 OID 146570441)
-- Dependencies: 800 799
-- Name: subaccnt_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY subaccnt ALTER COLUMN subaccnt_id SET DEFAULT nextval('subaccnt_subaccnt_id_seq'::regclass);


--
-- TOC entry 6668 (class 2604 OID 146570442)
-- Dependencies: 802 801
-- Name: subaccnttype_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY subaccnttype ALTER COLUMN subaccnttype_id SET DEFAULT nextval('subaccnttype_subaccnttype_id_seq'::regclass);


--
-- TOC entry 6669 (class 2604 OID 146570443)
-- Dependencies: 805 804
-- Name: taxass_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY taxass ALTER COLUMN taxass_id SET DEFAULT nextval('taxass_taxass_id_seq'::regclass);


--
-- TOC entry 6137 (class 2604 OID 146570444)
-- Dependencies: 806 284
-- Name: taxauth_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY taxauth ALTER COLUMN taxauth_id SET DEFAULT nextval('taxauth_taxauth_id_seq'::regclass);


--
-- TOC entry 6670 (class 2604 OID 146570445)
-- Dependencies: 808 807
-- Name: taxclass_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY taxclass ALTER COLUMN taxclass_id SET DEFAULT nextval('taxclass_taxclass_id_seq'::regclass);


--
-- TOC entry 6257 (class 2604 OID 146570446)
-- Dependencies: 378 377
-- Name: taxhist_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY taxhist ALTER COLUMN taxhist_id SET DEFAULT nextval('taxhist_taxhist_id_seq'::regclass);


--
-- TOC entry 6672 (class 2604 OID 146570459)
-- Dependencies: 810 809
-- Name: taxrate_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY taxrate ALTER COLUMN taxrate_id SET DEFAULT nextval('taxrate_taxrate_id_seq'::regclass);


--
-- TOC entry 6142 (class 2604 OID 146570460)
-- Dependencies: 811 285
-- Name: taxreg_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY taxreg ALTER COLUMN taxreg_id SET DEFAULT nextval('taxreg_taxreg_id_seq'::regclass);


--
-- TOC entry 5929 (class 2604 OID 146570461)
-- Dependencies: 812 199
-- Name: taxtype_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY taxtype ALTER COLUMN taxtype_id SET DEFAULT nextval('taxtype_taxtype_id_seq'::regclass);


--
-- TOC entry 6018 (class 2604 OID 146570462)
-- Dependencies: 813 220
-- Name: taxzone_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY taxzone ALTER COLUMN taxzone_id SET DEFAULT nextval('taxzone_taxzone_id_seq'::regclass);


--
-- TOC entry 6045 (class 2604 OID 146570463)
-- Dependencies: 815 233
-- Name: todoitem_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY todoitem ALTER COLUMN todoitem_id SET DEFAULT nextval('todoitem_todoitem_id_seq'::regclass);


--
-- TOC entry 6673 (class 2604 OID 146570464)
-- Dependencies: 818 817
-- Name: trialbal_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY trialbal ALTER COLUMN trialbal_id SET DEFAULT nextval('trialbal_trialbal_id_seq'::regclass);


--
-- TOC entry 6282 (class 2604 OID 146568328)
-- Dependencies: 418 417
-- Name: uiform_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY uiform ALTER COLUMN uiform_id SET DEFAULT nextval('uiform_uiform_id_seq'::regclass);


--
-- TOC entry 5932 (class 2604 OID 146570465)
-- Dependencies: 819 200
-- Name: uom_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY uom ALTER COLUMN uom_id SET DEFAULT nextval('uom_uom_id_seq'::regclass);


--
-- TOC entry 6675 (class 2604 OID 146570466)
-- Dependencies: 821 820
-- Name: uomconv_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY uomconv ALTER COLUMN uomconv_id SET DEFAULT nextval('uomconv_uomconv_id_seq'::regclass);


--
-- TOC entry 6677 (class 2604 OID 146570467)
-- Dependencies: 823 822
-- Name: uomtype_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY uomtype ALTER COLUMN uomtype_id SET DEFAULT nextval('uomtype_uomtype_id_seq'::regclass);


--
-- TOC entry 6085 (class 2604 OID 146570468)
-- Dependencies: 824 244
-- Name: url_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY urlinfo ALTER COLUMN url_id SET DEFAULT nextval('urlinfo_url_id_seq'::regclass);


--
-- TOC entry 6618 (class 2604 OID 146570469)
-- Dependencies: 829 732
-- Name: usrgrp_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY usrgrp ALTER COLUMN usrgrp_id SET DEFAULT nextval('usrgrp_usrgrp_id_seq'::regclass);


--
-- TOC entry 6263 (class 2604 OID 146570470)
-- Dependencies: 836 393
-- Name: vendtype_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY vendtype ALTER COLUMN vendtype_id SET DEFAULT nextval('vendtype_vendtype_id_seq'::regclass);


--
-- TOC entry 6689 (class 2604 OID 146570457)
-- Dependencies: 841 378 841
-- Name: taxhist_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY voheadtax ALTER COLUMN taxhist_id SET DEFAULT nextval('taxhist_taxhist_id_seq'::regclass);


--
-- TOC entry 6692 (class 2604 OID 146570458)
-- Dependencies: 844 378 844
-- Name: taxhist_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY voitemtax ALTER COLUMN taxhist_id SET DEFAULT nextval('taxhist_taxhist_id_seq'::regclass);


--
-- TOC entry 6216 (class 2604 OID 146570471)
-- Dependencies: 847 343
-- Name: whsezone_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY whsezone ALTER COLUMN whsezone_id SET DEFAULT nextval('whsezone_whsezone_id_seq'::regclass);


--
-- TOC entry 6693 (class 2604 OID 146570472)
-- Dependencies: 851 850
-- Name: womatlpost_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY womatlpost ALTER COLUMN womatlpost_id SET DEFAULT nextval('womatlpost_womatlpost_id_seq'::regclass);


--
-- TOC entry 6696 (class 2604 OID 146570473)
-- Dependencies: 856 855
-- Name: xsltmap_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY xsltmap ALTER COLUMN xsltmap_id SET DEFAULT nextval('xsltmap_xsltmap_id_seq'::regclass);


--
-- TOC entry 6701 (class 2604 OID 146570474)
-- Dependencies: 858 857
-- Name: yearperiod_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY yearperiod ALTER COLUMN yearperiod_id SET DEFAULT nextval('yearperiod_yearperiod_id_seq'::regclass);


--
-- TOC entry 7197 (class 2606 OID 146570818)
-- Dependencies: 420 420 8894
-- Name: acalitem_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY acalitem
    ADD CONSTRAINT acalitem_pkey PRIMARY KEY (acalitem_id);

ALTER TABLE ONLY accnt
    ADD CONSTRAINT accnt_pkey PRIMARY KEY (accnt_id);

--
-- TOC entry 6919 (class 2606 OID 146570822)
-- Dependencies: 234 234 8894
-- Name: addr_addr_number_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY addr
    ADD CONSTRAINT addr_addr_number_key UNIQUE (addr_number);


--
-- TOC entry 6921 (class 2606 OID 146570824)
-- Dependencies: 234 234 8894
-- Name: addr_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY addr
    ADD CONSTRAINT addr_pkey PRIMARY KEY (addr_id);


--
-- TOC entry 7199 (class 2606 OID 146570826)
-- Dependencies: 424 424 8894
-- Name: alarm_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY alarm
    ADD CONSTRAINT alarm_pkey PRIMARY KEY (alarm_id);


--
-- TOC entry 7201 (class 2606 OID 146570828)
-- Dependencies: 426 426 8894
-- Name: apaccnt_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY apaccnt
    ADD CONSTRAINT apaccnt_pkey PRIMARY KEY (apaccnt_id);



--
-- TOC entry 7212 (class 2606 OID 146570832)
-- Dependencies: 434 434 8894
-- Name: apcreditapply_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY apcreditapply
    ADD CONSTRAINT apcreditapply_pkey PRIMARY KEY (apcreditapply_id);

ALTER TABLE ONLY apopen
    ADD CONSTRAINT apopen_pkey PRIMARY KEY (apopen_id);

--
-- TOC entry 7214 (class 2606 OID 146570836)
-- Dependencies: 438 438 8894
-- Name: apopentax_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY apopentax
    ADD CONSTRAINT apopentax_pkey PRIMARY KEY (taxhist_id);


--
-- TOC entry 7217 (class 2606 OID 146570838)
-- Dependencies: 439 439 8894
-- Name: apselect_apselect_apopen_id_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY apselect
    ADD CONSTRAINT apselect_apselect_apopen_id_key UNIQUE (apselect_apopen_id);


--
-- TOC entry 7219 (class 2606 OID 146570840)
-- Dependencies: 439 439 8894
-- Name: apselect_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY apselect
    ADD CONSTRAINT apselect_pkey PRIMARY KEY (apselect_id);


--
-- TOC entry 7221 (class 2606 OID 146570842)
-- Dependencies: 441 441 8894
-- Name: araccnt_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY araccnt
    ADD CONSTRAINT araccnt_pkey PRIMARY KEY (araccnt_id);



--
-- TOC entry 7226 (class 2606 OID 146570846)
-- Dependencies: 446 446 8894
-- Name: arcreditapply_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY arcreditapply
    ADD CONSTRAINT arcreditapply_pkey PRIMARY KEY (arcreditapply_id);

ALTER TABLE ONLY aropen
    ADD CONSTRAINT aropen_pkey PRIMARY KEY (aropen_id);

ALTER TABLE ONLY aropenalloc
    ADD CONSTRAINT aropenalloc_pkey PRIMARY KEY (aropenalloc_aropen_id, aropenalloc_doctype, aropenalloc_doc_id);


ALTER TABLE ONLY aropentax
    ADD CONSTRAINT aropentax_pkey PRIMARY KEY (taxhist_id);

ALTER TABLE ONLY asohist
    ADD CONSTRAINT asohist_pkey PRIMARY KEY (asohist_id);



--
-- TOC entry 7232 (class 2606 OID 146570856)
-- Dependencies: 453 453 8894
-- Name: asohisttax_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY asohisttax
    ADD CONSTRAINT asohisttax_pkey PRIMARY KEY (taxhist_id);


--
-- TOC entry 7234 (class 2606 OID 146570858)
-- Dependencies: 454 454 8894
-- Name: atlasmap_atlasmap_name_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY atlasmap
    ADD CONSTRAINT atlasmap_atlasmap_name_key UNIQUE (atlasmap_name);


--
-- TOC entry 7236 (class 2606 OID 146570860)
-- Dependencies: 454 454 8894
-- Name: atlasmap_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY atlasmap
    ADD CONSTRAINT atlasmap_pkey PRIMARY KEY (atlasmap_id);

ALTER TABLE ONLY bankaccnt
    ADD CONSTRAINT bankaccnt_pkey PRIMARY KEY (bankaccnt_id);

--
-- TOC entry 7238 (class 2606 OID 146570866)
-- Dependencies: 458 458 8894
-- Name: bankadj_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY bankadj
    ADD CONSTRAINT bankadj_pkey PRIMARY KEY (bankadj_id);


--
-- TOC entry 7240 (class 2606 OID 146570868)
-- Dependencies: 460 460 8894
-- Name: bankadjtype_bankadjtype_name_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY bankadjtype
    ADD CONSTRAINT bankadjtype_bankadjtype_name_key UNIQUE (bankadjtype_name);


--
-- TOC entry 7242 (class 2606 OID 146570870)
-- Dependencies: 460 460 8894
-- Name: bankadjtype_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY bankadjtype
    ADD CONSTRAINT bankadjtype_pkey PRIMARY KEY (bankadjtype_id);


--
-- TOC entry 7244 (class 2606 OID 146570872)
-- Dependencies: 462 462 8894
-- Name: bankrec_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY bankrec
    ADD CONSTRAINT bankrec_pkey PRIMARY KEY (bankrec_id);

ALTER TABLE ONLY bomitem
    ADD CONSTRAINT bomitem_pkey PRIMARY KEY (bomitem_id);

--
-- TOC entry 7250 (class 2606 OID 146570880)
-- Dependencies: 468 468 8894
-- Name: bomitemcost_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY bomitemcost
    ADD CONSTRAINT bomitemcost_pkey PRIMARY KEY (bomitemcost_id);


--
-- TOC entry 6949 (class 2606 OID 146570882)
-- Dependencies: 258 258 8894
-- Name: bomitemsub_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY bomitemsub
    ADD CONSTRAINT bomitemsub_pkey PRIMARY KEY (bomitemsub_id);


--
-- TOC entry 7252 (class 2606 OID 146570884)
-- Dependencies: 471 471 8894
-- Name: bomwork_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY bomwork
    ADD CONSTRAINT bomwork_pkey PRIMARY KEY (bomwork_id);


--
-- TOC entry 6951 (class 2606 OID 146570886)
-- Dependencies: 260 260 8894
-- Name: budghead_budghead_name_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY budghead
    ADD CONSTRAINT budghead_budghead_name_key UNIQUE (budghead_name);


--
-- TOC entry 6953 (class 2606 OID 146570888)
-- Dependencies: 260 260 8894
-- Name: budghead_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY budghead
    ADD CONSTRAINT budghead_pkey PRIMARY KEY (budghead_id);


--
-- TOC entry 6958 (class 2606 OID 146570890)
-- Dependencies: 263 263 8894
-- Name: budgitem_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY budgitem
    ADD CONSTRAINT budgitem_pkey PRIMARY KEY (budgitem_id);


--
-- TOC entry 7254 (class 2606 OID 146570892)
-- Dependencies: 476 476 8894
-- Name: calhead_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY calhead
    ADD CONSTRAINT calhead_pkey PRIMARY KEY (calhead_id);



--
-- TOC entry 6977 (class 2606 OID 146570902)
-- Dependencies: 278 278 8894
-- Name: ccard_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY ccard
    ADD CONSTRAINT ccard_pkey PRIMARY KEY (ccard_id);


--
-- TOC entry 7258 (class 2606 OID 146570904)
-- Dependencies: 482 482 8894
-- Name: ccardaud_ccard_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY ccardaud
    ADD CONSTRAINT ccardaud_ccard_pkey PRIMARY KEY (ccardaud_id);

ALTER TABLE ONLY ccpay
    ADD CONSTRAINT ccpay_pkey PRIMARY KEY (ccpay_id);

ALTER TABLE ONLY "char"
    ADD CONSTRAINT char_pkey PRIMARY KEY (char_id);

--
-- TOC entry 6927 (class 2606 OID 146570916)
-- Dependencies: 237 237 8894
-- Name: charass_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY charass
    ADD CONSTRAINT charass_pkey PRIMARY KEY (charass_id);


--
-- TOC entry 7269 (class 2606 OID 146570918)
-- Dependencies: 490 490 8894
-- Name: charopt_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY charopt
    ADD CONSTRAINT charopt_pkey PRIMARY KEY (charopt_id);

ALTER TABLE ONLY checkhead
    ADD CONSTRAINT checkhead_pkey PRIMARY KEY (checkhead_id);

--
-- TOC entry 7210 (class 2606 OID 146570922)
-- Dependencies: 432 432 8894
-- Name: checkitem_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY checkitem
    ADD CONSTRAINT checkitem_pkey PRIMARY KEY (checkitem_id);


--
-- TOC entry 7036 (class 2606 OID 146570924)
-- Dependencies: 313 313 8894
-- Name: classcode_classcode_code_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY classcode
    ADD CONSTRAINT classcode_classcode_code_key UNIQUE (classcode_code);


--
-- TOC entry 7038 (class 2606 OID 146570926)
-- Dependencies: 313 313 8894
-- Name: classcode_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY classcode
    ADD CONSTRAINT classcode_pkey PRIMARY KEY (classcode_id);


--
-- TOC entry 7163 (class 2606 OID 146570928)
-- Dependencies: 397 397 8894
-- Name: cmd_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY cmd
    ADD CONSTRAINT cmd_pkey PRIMARY KEY (cmd_id);


--
-- TOC entry 7167 (class 2606 OID 146570930)
-- Dependencies: 400 400 8894
-- Name: cmdarg_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY cmdarg
    ADD CONSTRAINT cmdarg_pkey PRIMARY KEY (cmdarg_id);


--
-- TOC entry 6870 (class 2606 OID 146570932)
-- Dependencies: 218 218 8894
-- Name: cmhead_cmhead_number_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY cmhead
    ADD CONSTRAINT cmhead_cmhead_number_key UNIQUE (cmhead_number);


--
-- TOC entry 6873 (class 2606 OID 146570934)
-- Dependencies: 218 218 8894
-- Name: cmhead_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY cmhead
    ADD CONSTRAINT cmhead_pkey PRIMARY KEY (cmhead_id);


--
-- TOC entry 7271 (class 2606 OID 146570936)
-- Dependencies: 497 497 8894
-- Name: cmheadtax_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY cmheadtax
    ADD CONSTRAINT cmheadtax_pkey PRIMARY KEY (taxhist_id);

ALTER TABLE ONLY cmitem
    ADD CONSTRAINT cmitem_pkey PRIMARY KEY (cmitem_id);

--
-- TOC entry 7273 (class 2606 OID 146570942)
-- Dependencies: 499 499 8894
-- Name: cmitemtax_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY cmitemtax
    ADD CONSTRAINT cmitemtax_pkey PRIMARY KEY (taxhist_id);


--
-- TOC entry 6930 (class 2606 OID 146570944)
-- Dependencies: 239 239 8894
-- Name: cmnttype_cmnttype_name_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY cmnttype
    ADD CONSTRAINT cmnttype_cmnttype_name_key UNIQUE (cmnttype_name);


--
-- TOC entry 6932 (class 2606 OID 146570946)
-- Dependencies: 239 239 8894
-- Name: cmnttype_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY cmnttype
    ADD CONSTRAINT cmnttype_pkey PRIMARY KEY (cmnttype_id);

ALTER TABLE ONLY cntct
    ADD CONSTRAINT cntct_pkey PRIMARY KEY (cntct_id);

--
-- TOC entry 7277 (class 2606 OID 146570955)
-- Dependencies: 504 504 8894
-- Name: cntctaddr_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY cntctaddr
    ADD CONSTRAINT cntctaddr_pkey PRIMARY KEY (cntctaddr_id);


--
-- TOC entry 7279 (class 2606 OID 146570958)
-- Dependencies: 506 506 8894
-- Name: cntctdata_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY cntctdata
    ADD CONSTRAINT cntctdata_pkey PRIMARY KEY (cntctdata_id);


--
-- TOC entry 7281 (class 2606 OID 146570960)
-- Dependencies: 508 508 8894
-- Name: cntcteml_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY cntcteml
    ADD CONSTRAINT cntcteml_pkey PRIMARY KEY (cntcteml_id);


--
-- TOC entry 7283 (class 2606 OID 146570962)
-- Dependencies: 510 510 8894
-- Name: cntctmrgd_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY cntctmrgd
    ADD CONSTRAINT cntctmrgd_pkey PRIMARY KEY (cntctmrgd_cntct_id);


--
-- TOC entry 7285 (class 2606 OID 146570964)
-- Dependencies: 511 511 8894
-- Name: cntctsel_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY cntctsel
    ADD CONSTRAINT cntctsel_pkey PRIMARY KEY (cntctsel_cntct_id);


--
-- TOC entry 6744 (class 2606 OID 146570967)
-- Dependencies: 189 189 8894
-- Name: cntslip_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY cntslip
    ADD CONSTRAINT cntslip_pkey PRIMARY KEY (cntslip_id);


--
-- TOC entry 7289 (class 2606 OID 146570969)
-- Dependencies: 513 513 8894
-- Name: cobill_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY cobill
    ADD CONSTRAINT cobill_pkey PRIMARY KEY (cobill_id);


--
-- TOC entry 7291 (class 2606 OID 146570972)
-- Dependencies: 515 515 8894
-- Name: cobilltax_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY cobilltax
    ADD CONSTRAINT cobilltax_pkey PRIMARY KEY (taxhist_id);


--
-- TOC entry 7294 (class 2606 OID 146570974)
-- Dependencies: 516 516 8894
-- Name: cobmisc_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY cobmisc
    ADD CONSTRAINT cobmisc_pkey PRIMARY KEY (cobmisc_id);


--
-- TOC entry 7297 (class 2606 OID 146570976)
-- Dependencies: 518 518 8894
-- Name: cobmisctax_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY cobmisctax
    ADD CONSTRAINT cobmisctax_pkey PRIMARY KEY (taxhist_id);

ALTER TABLE ONLY cohead
    ADD CONSTRAINT cohead_pkey PRIMARY KEY (cohead_id);


--
-- TOC entry 7149 (class 2606 OID 146570984)
-- Dependencies: 379 379 8894
-- Name: cohisttax_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY cohisttax
    ADD CONSTRAINT cohisttax_pkey PRIMARY KEY (taxhist_id);


--
-- TOC entry 6781 (class 2606 OID 146570986)
-- Dependencies: 196 196 8894
-- Name: coitem_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY coitem
    ADD CONSTRAINT coitem_pkey PRIMARY KEY (coitem_id);


--
-- TOC entry 6935 (class 2606 OID 146570989)
-- Dependencies: 240 240 8894
-- Name: comment_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY comment
    ADD CONSTRAINT comment_pkey PRIMARY KEY (comment_id);


ALTER TABLE ONLY company
    ADD CONSTRAINT company_pkey PRIMARY KEY (company_id);
ALTER TABLE ONLY company
    ADD CONSTRAINT company_company_number_key UNIQUE (company_number);


--
-- TOC entry 7065 (class 2606 OID 146570995)
-- Dependencies: 329 329 8894
-- Name: contrct_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY contrct
    ADD CONSTRAINT contrct_pkey PRIMARY KEY (contrct_id);


--
-- TOC entry 7056 (class 2606 OID 146570997)
-- Dependencies: 325 325 8894
-- Name: costcat_costcat_code_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY costcat
    ADD CONSTRAINT costcat_costcat_code_key UNIQUE (costcat_code);


--
-- TOC entry 7058 (class 2606 OID 146570999)
-- Dependencies: 325 325 8894
-- Name: costcat_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY costcat
    ADD CONSTRAINT costcat_pkey PRIMARY KEY (costcat_id);


--
-- TOC entry 7048 (class 2606 OID 146571001)
-- Dependencies: 320 320 8894
-- Name: costelem_costelem_type_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY costelem
    ADD CONSTRAINT costelem_costelem_type_key UNIQUE (costelem_type);


--
-- TOC entry 7050 (class 2606 OID 146571004)
-- Dependencies: 320 320 8894
-- Name: costelem_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY costelem
    ADD CONSTRAINT costelem_pkey PRIMARY KEY (costelem_id);


--
-- TOC entry 7314 (class 2606 OID 146571006)
-- Dependencies: 535 535 8894
-- Name: costhist_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY costhist
    ADD CONSTRAINT costhist_pkey PRIMARY KEY (costhist_id);


--
-- TOC entry 7316 (class 2606 OID 146571013)
-- Dependencies: 537 537 8894
-- Name: costupdate_costupdate_item_id_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY costupdate
    ADD CONSTRAINT costupdate_costupdate_item_id_key UNIQUE (costupdate_item_id);


--
-- TOC entry 7318 (class 2606 OID 146571017)
-- Dependencies: 538 538 8894
-- Name: country_country_abbr_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY country
    ADD CONSTRAINT country_country_abbr_key UNIQUE (country_abbr);


--
-- TOC entry 7320 (class 2606 OID 146571019)
-- Dependencies: 538 538 8894
-- Name: country_country_name_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY country
    ADD CONSTRAINT country_country_name_key UNIQUE (country_name);


--
-- TOC entry 7322 (class 2606 OID 146571021)
-- Dependencies: 538 538 8894
-- Name: country_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY country
    ADD CONSTRAINT country_pkey PRIMARY KEY (country_id);


ALTER TABLE ONLY crmacct
    ADD CONSTRAINT crmacct_pkey PRIMARY KEY (crmacct_id);


--
-- TOC entry 7328 (class 2606 OID 146571027)
-- Dependencies: 544 544 8894
-- Name: crmacctsel_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY crmacctsel
    ADD CONSTRAINT crmacctsel_pkey PRIMARY KEY (crmacctsel_src_crmacct_id);

ALTER TABLE ONLY curr_rate
    ADD CONSTRAINT curr_rate_pkey PRIMARY KEY (curr_rate_id);


--
-- TOC entry 6831 (class 2606 OID 146571033)
-- Dependencies: 208 208 8894
-- Name: curr_symbol_curr_abbr_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY curr_symbol
    ADD CONSTRAINT curr_symbol_curr_abbr_key UNIQUE (curr_abbr);


--
-- TOC entry 6833 (class 2606 OID 146571035)
-- Dependencies: 208 208 8894
-- Name: curr_symbol_curr_name_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY curr_symbol
    ADD CONSTRAINT curr_symbol_curr_name_key UNIQUE (curr_name);


--
-- TOC entry 6835 (class 2606 OID 146571037)
-- Dependencies: 208 208 8894
-- Name: curr_symbol_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY curr_symbol
    ADD CONSTRAINT curr_symbol_pkey PRIMARY KEY (curr_id);


ALTER TABLE ONLY custinfo
    ADD CONSTRAINT cust_pkey PRIMARY KEY (cust_id);


--
-- TOC entry 7334 (class 2606 OID 146571041)
-- Dependencies: 550 550 8894
-- Name: custform_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY custform
    ADD CONSTRAINT custform_pkey PRIMARY KEY (custform_id);


--
-- TOC entry 7336 (class 2606 OID 146571043)
-- Dependencies: 552 552 8894
-- Name: custgrp_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY custgrp
    ADD CONSTRAINT custgrp_pkey PRIMARY KEY (custgrp_id);


--
-- TOC entry 7338 (class 2606 OID 146571045)
-- Dependencies: 554 554 8894
-- Name: custgrpitem_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY custgrpitem
    ADD CONSTRAINT custgrpitem_pkey PRIMARY KEY (custgrpitem_id);


ALTER TABLE ONLY custtype
    ADD CONSTRAINT custtype_custtype_code_key UNIQUE (custtype_code);


--
-- TOC entry 6981 (class 2606 OID 146571051)
-- Dependencies: 280 280 8894
-- Name: custtype_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY custtype
    ADD CONSTRAINT custtype_pkey PRIMARY KEY (custtype_id);


--
-- TOC entry 6995 (class 2606 OID 146571053)
-- Dependencies: 291 291 8894
-- Name: dept_dept_number_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY dept
    ADD CONSTRAINT dept_dept_number_key UNIQUE (dept_number);


--
-- TOC entry 6997 (class 2606 OID 146571055)
-- Dependencies: 291 291 8894
-- Name: dept_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY dept
    ADD CONSTRAINT dept_pkey PRIMARY KEY (dept_id);


--
-- TOC entry 7340 (class 2606 OID 146571057)
-- Dependencies: 558 558 8894
-- Name: destination_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY destination
    ADD CONSTRAINT destination_pkey PRIMARY KEY (destination_id);


ALTER TABLE ONLY docass
    ADD CONSTRAINT docass_pkey PRIMARY KEY (docass_id);


ALTER TABLE ONLY emp
    ADD CONSTRAINT emp_pkey PRIMARY KEY (emp_id);


--
-- TOC entry 7349 (class 2606 OID 146571068)
-- Dependencies: 563 563 8894
-- Name: empgrp_empgrp_name_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY empgrp
    ADD CONSTRAINT empgrp_empgrp_name_key UNIQUE (empgrp_name);


--
-- TOC entry 7351 (class 2606 OID 146571070)
-- Dependencies: 563 563 8894
-- Name: empgrp_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY empgrp
    ADD CONSTRAINT empgrp_pkey PRIMARY KEY (empgrp_id);


--
-- TOC entry 7353 (class 2606 OID 146571072)
-- Dependencies: 565 565 8894
-- Name: empgrpitem_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY empgrpitem
    ADD CONSTRAINT empgrpitem_pkey PRIMARY KEY (empgrpitem_id);


--
-- TOC entry 7357 (class 2606 OID 146571075)
-- Dependencies: 567 567 8894
-- Name: evntlog_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY evntlog
    ADD CONSTRAINT evntlog_pkey PRIMARY KEY (evntlog_id);


--
-- TOC entry 7360 (class 2606 OID 146571077)
-- Dependencies: 569 569 8894
-- Name: evntnot_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY evntnot
    ADD CONSTRAINT evntnot_pkey PRIMARY KEY (evntnot_id);


--
-- TOC entry 7363 (class 2606 OID 146571079)
-- Dependencies: 571 571 8894
-- Name: evnttype_evnttype_name_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY evnttype
    ADD CONSTRAINT evnttype_evnttype_name_key UNIQUE (evnttype_name);


--
-- TOC entry 7365 (class 2606 OID 146571081)
-- Dependencies: 571 571 8894
-- Name: evnttype_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY evnttype
    ADD CONSTRAINT evnttype_pkey PRIMARY KEY (evnttype_id);


--
-- TOC entry 7117 (class 2606 OID 146571083)
-- Dependencies: 358 358 8894
-- Name: expcat_expcat_code_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY expcat
    ADD CONSTRAINT expcat_expcat_code_key UNIQUE (expcat_code);


--
-- TOC entry 7119 (class 2606 OID 146571085)
-- Dependencies: 358 358 8894
-- Name: expcat_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY expcat
    ADD CONSTRAINT expcat_pkey PRIMARY KEY (expcat_id);


--
-- TOC entry 6939 (class 2606 OID 146571087)
-- Dependencies: 243 243 8894
-- Name: file_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY file
    ADD CONSTRAINT file_pkey PRIMARY KEY (file_id);


--
-- TOC entry 7368 (class 2606 OID 146571089)
-- Dependencies: 575 575 8894
-- Name: filter_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY filter
    ADD CONSTRAINT filter_pkey PRIMARY KEY (filter_id);


--
-- TOC entry 7370 (class 2606 OID 146571091)
-- Dependencies: 577 577 8894
-- Name: fincharg_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY fincharg
    ADD CONSTRAINT fincharg_pkey PRIMARY KEY (fincharg_id);


--
-- TOC entry 7378 (class 2606 OID 146571093)
-- Dependencies: 582 582 8894
-- Name: fkey_flcol_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY flcol
    ADD CONSTRAINT fkey_flcol_key PRIMARY KEY (flcol_id);


--
-- TOC entry 7380 (class 2606 OID 146571095)
-- Dependencies: 584 584 8894
-- Name: flgrp_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY flgrp
    ADD CONSTRAINT flgrp_pkey PRIMARY KEY (flgrp_id);


--
-- TOC entry 7372 (class 2606 OID 146571097)
-- Dependencies: 579 579 8894
-- Name: flhead_flhead_name_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY flhead
    ADD CONSTRAINT flhead_flhead_name_key UNIQUE (flhead_name);


--
-- TOC entry 7374 (class 2606 OID 146571099)
-- Dependencies: 579 579 8894
-- Name: flhead_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY flhead
    ADD CONSTRAINT flhead_pkey PRIMARY KEY (flhead_id);


--
-- TOC entry 7376 (class 2606 OID 146571101)
-- Dependencies: 580 580 8894
-- Name: flitem_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY flitem
    ADD CONSTRAINT flitem_pkey PRIMARY KEY (flitem_id);


--
-- TOC entry 7382 (class 2606 OID 146571103)
-- Dependencies: 588 588 588 8894
-- Name: flnotes_flnotes_flhead_id_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY flnotes
    ADD CONSTRAINT flnotes_flnotes_flhead_id_key UNIQUE (flnotes_flhead_id, flnotes_period_id);


--
-- TOC entry 7384 (class 2606 OID 146571105)
-- Dependencies: 590 590 8894
-- Name: flrpt_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY flrpt
    ADD CONSTRAINT flrpt_pkey PRIMARY KEY (flrpt_id);


--
-- TOC entry 7386 (class 2606 OID 146571107)
-- Dependencies: 592 592 8894
-- Name: flspec_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY flspec
    ADD CONSTRAINT flspec_pkey PRIMARY KEY (flspec_id);


--
-- TOC entry 7388 (class 2606 OID 146571109)
-- Dependencies: 594 594 8894
-- Name: form_form_name_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY form
    ADD CONSTRAINT form_form_name_key UNIQUE (form_name);


--
-- TOC entry 7390 (class 2606 OID 146571111)
-- Dependencies: 594 594 8894
-- Name: form_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY form
    ADD CONSTRAINT form_pkey PRIMARY KEY (form_id);


--
-- TOC entry 7010 (class 2606 OID 146571113)
-- Dependencies: 299 299 8894
-- Name: freightclass_freightclass_code_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY freightclass
    ADD CONSTRAINT freightclass_freightclass_code_key UNIQUE (freightclass_code);


--
-- TOC entry 7012 (class 2606 OID 146571115)
-- Dependencies: 299 299 8894
-- Name: freightclass_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY freightclass
    ADD CONSTRAINT freightclass_pkey PRIMARY KEY (freightclass_id);


--
-- TOC entry 7392 (class 2606 OID 146571117)
-- Dependencies: 597 597 8894
-- Name: glseries_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY glseries
    ADD CONSTRAINT glseries_pkey PRIMARY KEY (glseries_id);


--
-- TOC entry 7090 (class 2606 OID 146571119)
-- Dependencies: 340 340 8894
-- Name: gltrans_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY gltrans
    ADD CONSTRAINT gltrans_pkey PRIMARY KEY (gltrans_id);

ALTER TABLE ONLY grp
    ADD CONSTRAINT grp_pkey PRIMARY KEY (grp_id);


--
-- TOC entry 7398 (class 2606 OID 146571125)
-- Dependencies: 603 603 8894
-- Name: grppriv_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY grppriv
    ADD CONSTRAINT grppriv_pkey PRIMARY KEY (grppriv_id);


--
-- TOC entry 7400 (class 2606 OID 146571127)
-- Dependencies: 605 605 8894
-- Name: hnfc_hnfc_code_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY hnfc
    ADD CONSTRAINT hnfc_hnfc_code_key UNIQUE (hnfc_code);


--
-- TOC entry 7402 (class 2606 OID 146571129)
-- Dependencies: 605 605 8894
-- Name: hnfc_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY hnfc
    ADD CONSTRAINT hnfc_pkey PRIMARY KEY (hnfc_id);


--
-- TOC entry 6943 (class 2606 OID 146571131)
-- Dependencies: 248 248 8894
-- Name: image_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY image
    ADD CONSTRAINT image_pkey PRIMARY KEY (image_id);


--
-- TOC entry 6945 (class 2606 OID 146571133)
-- Dependencies: 249 249 8894
-- Name: imageass_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY imageass
    ADD CONSTRAINT imageass_pkey PRIMARY KEY (imageass_id);


ALTER TABLE ONLY incdt
    ADD CONSTRAINT incdt_pkey PRIMARY KEY (incdt_id);


--
-- TOC entry 7020 (class 2606 OID 146571139)
-- Dependencies: 304 304 8894
-- Name: incdtcat_incdtcat_name_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY incdtcat
    ADD CONSTRAINT incdtcat_incdtcat_name_key UNIQUE (incdtcat_name);


--
-- TOC entry 7022 (class 2606 OID 146571141)
-- Dependencies: 304 304 8894
-- Name: incdtcat_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY incdtcat
    ADD CONSTRAINT incdtcat_pkey PRIMARY KEY (incdtcat_id);


--
-- TOC entry 7404 (class 2606 OID 146571143)
-- Dependencies: 609 609 8894
-- Name: incdthist_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY incdthist
    ADD CONSTRAINT incdthist_pkey PRIMARY KEY (incdthist_id);


--
-- TOC entry 7024 (class 2606 OID 146571145)
-- Dependencies: 305 305 8894
-- Name: incdtpriority_incdtpriority_name_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY incdtpriority
    ADD CONSTRAINT incdtpriority_incdtpriority_name_key UNIQUE (incdtpriority_name);


--
-- TOC entry 7026 (class 2606 OID 146571147)
-- Dependencies: 305 305 8894
-- Name: incdtpriority_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY incdtpriority
    ADD CONSTRAINT incdtpriority_pkey PRIMARY KEY (incdtpriority_id);


--
-- TOC entry 7028 (class 2606 OID 146571149)
-- Dependencies: 306 306 8894
-- Name: incdtresolution_incdtresolution_name_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY incdtresolution
    ADD CONSTRAINT incdtresolution_incdtresolution_name_key UNIQUE (incdtresolution_name);


--
-- TOC entry 7030 (class 2606 OID 146571151)
-- Dependencies: 306 306 8894
-- Name: incdtresolution_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY incdtresolution
    ADD CONSTRAINT incdtresolution_pkey PRIMARY KEY (incdtresolution_id);


--
-- TOC entry 7032 (class 2606 OID 146571153)
-- Dependencies: 307 307 8894
-- Name: incdtseverity_incdtseverity_name_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY incdtseverity
    ADD CONSTRAINT incdtseverity_incdtseverity_name_key UNIQUE (incdtseverity_name);


--
-- TOC entry 7034 (class 2606 OID 146571155)
-- Dependencies: 307 307 8894
-- Name: incdtseverity_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY incdtseverity
    ADD CONSTRAINT incdtseverity_pkey PRIMARY KEY (incdtseverity_id);


--
-- TOC entry 6805 (class 2606 OID 146571157)
-- Dependencies: 202 202 8894
-- Name: invbal_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY invbal
    ADD CONSTRAINT invbal_pkey PRIMARY KEY (invbal_id);


ALTER TABLE ONLY invchead
    ADD CONSTRAINT invchead_pkey PRIMARY KEY (invchead_id);


--
-- TOC entry 7406 (class 2606 OID 146571163)
-- Dependencies: 617 617 8894
-- Name: invcheadtax_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY invcheadtax
    ADD CONSTRAINT invcheadtax_pkey PRIMARY KEY (taxhist_id);


ALTER TABLE ONLY invcitem
    ADD CONSTRAINT invcitem_pkey PRIMARY KEY (invcitem_id);


--
-- TOC entry 7408 (class 2606 OID 146571169)
-- Dependencies: 619 619 8894
-- Name: invcitemtax_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY invcitemtax
    ADD CONSTRAINT invcitemtax_pkey PRIMARY KEY (taxhist_id);


--
-- TOC entry 6746 (class 2606 OID 146571171)
-- Dependencies: 190 190 8894
-- Name: invcnt_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY invcnt
    ADD CONSTRAINT invcnt_pkey PRIMARY KEY (invcnt_id);


--
-- TOC entry 7413 (class 2606 OID 146571173)
-- Dependencies: 621 621 8894
-- Name: invdetail_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY invdetail
    ADD CONSTRAINT invdetail_pkey PRIMARY KEY (invdetail_id);


--
-- TOC entry 7418 (class 2606 OID 146571175)
-- Dependencies: 623 623 8894
-- Name: invhist_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY invhist
    ADD CONSTRAINT invhist_pkey PRIMARY KEY (invhist_id);


--
-- TOC entry 7423 (class 2606 OID 146571177)
-- Dependencies: 625 625 625 8894
-- Name: invhistexpcat_invhist_id_expcat_id; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY invhistexpcat
    ADD CONSTRAINT invhistexpcat_invhist_id_expcat_id UNIQUE (invhistexpcat_invhist_id, invhistexpcat_expcat_id);


--
-- TOC entry 7425 (class 2606 OID 146571179)
-- Dependencies: 625 625 8894
-- Name: invhistexpcat_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY invhistexpcat
    ADD CONSTRAINT invhistexpcat_pkey PRIMARY KEY (invhistexpcat_id);


ALTER TABLE ONLY ipsass
    ADD CONSTRAINT ipsass_pkey PRIMARY KEY (ipsass_id);


--
-- TOC entry 7014 (class 2606 OID 146571185)
-- Dependencies: 300 300 8894
-- Name: ipsfreight_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY ipsfreight
    ADD CONSTRAINT ipsfreight_pkey PRIMARY KEY (ipsfreight_id);


ALTER TABLE ONLY ipshead
    ADD CONSTRAINT ipshead_pkey PRIMARY KEY (ipshead_id);


--
-- TOC entry 7103 (class 2606 OID 146571191)
-- Dependencies: 349 349 349 349 349 349 349 8894
-- Name: ipsitem_ipsitem_ipshead_id_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY ipsiteminfo
    ADD CONSTRAINT ipsitem_ipsitem_ipshead_id_key UNIQUE (ipsitem_ipshead_id, ipsitem_item_id, ipsitem_prodcat_id, ipsitem_qtybreak, ipsitem_qty_uom_id, ipsitem_price_uom_id);


--
-- TOC entry 7105 (class 2606 OID 146571193)
-- Dependencies: 349 349 8894
-- Name: ipsitem_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY ipsiteminfo
    ADD CONSTRAINT ipsitem_pkey PRIMARY KEY (ipsitem_id);


--
-- TOC entry 7107 (class 2606 OID 146571195)
-- Dependencies: 351 351 351 351 8894
-- Name: ipsitemchar_ipsitemchar_ipsitem_id_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY ipsitemchar
    ADD CONSTRAINT ipsitemchar_ipsitemchar_ipsitem_id_key UNIQUE (ipsitemchar_ipsitem_id, ipsitemchar_char_id, ipsitemchar_value);


--
-- TOC entry 7109 (class 2606 OID 146571197)
-- Dependencies: 351 351 351 351 8894
-- Name: ipsitemchar_ipsitemchar_ipsitem_id_key1; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY ipsitemchar
    ADD CONSTRAINT ipsitemchar_ipsitemchar_ipsitem_id_key1 UNIQUE (ipsitemchar_ipsitem_id, ipsitemchar_char_id, ipsitemchar_value);


--
-- TOC entry 7111 (class 2606 OID 146571199)
-- Dependencies: 351 351 8894
-- Name: ipsitemchar_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY ipsitemchar
    ADD CONSTRAINT ipsitemchar_pkey PRIMARY KEY (ipsitemchar_id);


--
-- TOC entry 7427 (class 2606 OID 146571201)
-- Dependencies: 636 636 8894
-- Name: ipsprodcat_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY ipsprodcat_bak
    ADD CONSTRAINT ipsprodcat_pkey PRIMARY KEY (ipsprodcat_id);


ALTER TABLE ONLY item
    ADD CONSTRAINT item_pkey PRIMARY KEY (item_id);


ALTER TABLE ONLY itemalias
    ADD CONSTRAINT itemalias_pkey PRIMARY KEY (itemalias_id);


--
-- TOC entry 7054 (class 2606 OID 146571211)
-- Dependencies: 321 321 8894
-- Name: itemcost_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY itemcost
    ADD CONSTRAINT itemcost_pkey PRIMARY KEY (itemcost_id);


--
-- TOC entry 7429 (class 2606 OID 146571213)
-- Dependencies: 643 643 8894
-- Name: itemgrp_itemgrp_name_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY itemgrp
    ADD CONSTRAINT itemgrp_itemgrp_name_key UNIQUE (itemgrp_name);


--
-- TOC entry 7431 (class 2606 OID 146571215)
-- Dependencies: 643 643 8894
-- Name: itemgrp_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY itemgrp
    ADD CONSTRAINT itemgrp_pkey PRIMARY KEY (itemgrp_id);


--
-- TOC entry 7433 (class 2606 OID 146571217)
-- Dependencies: 645 645 8894
-- Name: itemgrpitem_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY itemgrpitem
    ADD CONSTRAINT itemgrpitem_pkey PRIMARY KEY (itemgrpitem_id);


--
-- TOC entry 7435 (class 2606 OID 146571219)
-- Dependencies: 645 645 645 645 8894
-- Name: itemgrpitem_unique_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY itemgrpitem
    ADD CONSTRAINT itemgrpitem_unique_key UNIQUE (itemgrpitem_itemgrp_id, itemgrpitem_item_id, itemgrpitem_item_type);


--
-- TOC entry 7439 (class 2606 OID 146571221)
-- Dependencies: 649 649 8894
-- Name: itemloc_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY itemloc
    ADD CONSTRAINT itemloc_pkey PRIMARY KEY (itemloc_id);


ALTER TABLE ONLY itemlocdist
    ADD CONSTRAINT itemlocdist_pkey PRIMARY KEY (itemlocdist_id);


--
-- TOC entry 7443 (class 2606 OID 146571225)
-- Dependencies: 654 654 8894
-- Name: itemlocpost_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY itemlocpost
    ADD CONSTRAINT itemlocpost_pkey PRIMARY KEY (itemlocpost_id);


ALTER TABLE ONLY itemsite
    ADD CONSTRAINT itemsite_pkey PRIMARY KEY (itemsite_id);


--
-- TOC entry 7067 (class 2606 OID 146571229)
-- Dependencies: 330 330 330 330 330 330 330 330 330 8894
-- Name: itemsrc_itemsrc_vend_id_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY itemsrc
    ADD CONSTRAINT itemsrc_itemsrc_vend_id_key UNIQUE (itemsrc_vend_id, itemsrc_item_id, itemsrc_effective, itemsrc_expires, itemsrc_vend_item_number, itemsrc_manuf_name, itemsrc_manuf_item_number, itemsrc_contrct_id);


--
-- TOC entry 7069 (class 2606 OID 146571231)
-- Dependencies: 330 330 8894
-- Name: itemsrc_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY itemsrc
    ADD CONSTRAINT itemsrc_pkey PRIMARY KEY (itemsrc_id);


--
-- TOC entry 7073 (class 2606 OID 146571233)
-- Dependencies: 332 332 332 332 332 8894
-- Name: itemsrcp_itemsrcp_itemsrc_id_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY itemsrcp
    ADD CONSTRAINT itemsrcp_itemsrcp_itemsrc_id_key UNIQUE (itemsrcp_itemsrc_id, itemsrcp_warehous_id, itemsrcp_dropship, itemsrcp_qtybreak);


--
-- TOC entry 7075 (class 2606 OID 146571235)
-- Dependencies: 332 332 8894
-- Name: itemsrcp_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY itemsrcp
    ADD CONSTRAINT itemsrcp_pkey PRIMARY KEY (itemsrcp_id);


--
-- TOC entry 7077 (class 2606 OID 146571237)
-- Dependencies: 334 334 334 8894
-- Name: itemsub_itemsub_parent_item_id_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY itemsub
    ADD CONSTRAINT itemsub_itemsub_parent_item_id_key UNIQUE (itemsub_parent_item_id, itemsub_sub_item_id);


--
-- TOC entry 7080 (class 2606 OID 146571239)
-- Dependencies: 334 334 8894
-- Name: itemsub_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY itemsub
    ADD CONSTRAINT itemsub_pkey PRIMARY KEY (itemsub_id);


--
-- TOC entry 7083 (class 2606 OID 146571241)
-- Dependencies: 336 336 8894
-- Name: itemtax_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY itemtax
    ADD CONSTRAINT itemtax_pkey PRIMARY KEY (itemtax_id);


--
-- TOC entry 7445 (class 2606 OID 146571243)
-- Dependencies: 662 662 662 8894
-- Name: itemtrans_itemtrans_source_item_id_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY itemtrans
    ADD CONSTRAINT itemtrans_itemtrans_source_item_id_key UNIQUE (itemtrans_source_item_id, itemtrans_target_item_id);


--
-- TOC entry 7447 (class 2606 OID 146571245)
-- Dependencies: 662 662 8894
-- Name: itemtrans_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY itemtrans
    ADD CONSTRAINT itemtrans_pkey PRIMARY KEY (itemtrans_id);


--
-- TOC entry 7449 (class 2606 OID 146571247)
-- Dependencies: 664 664 8894
-- Name: itemuom_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY itemuom
    ADD CONSTRAINT itemuom_pkey PRIMARY KEY (itemuom_id);


ALTER TABLE ONLY itemuomconv
    ADD CONSTRAINT itemuomconv_pkey PRIMARY KEY (itemuomconv_id);


--
-- TOC entry 7451 (class 2606 OID 146571251)
-- Dependencies: 668 668 8894
-- Name: jrnluse_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY jrnluse
    ADD CONSTRAINT jrnluse_pkey PRIMARY KEY (jrnluse_id);


--
-- TOC entry 7453 (class 2606 OID 146571253)
-- Dependencies: 670 670 8894
-- Name: labeldef_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY labeldef
    ADD CONSTRAINT labeldef_pkey PRIMARY KEY (labeldef_id);


--
-- TOC entry 7455 (class 2606 OID 146571255)
-- Dependencies: 672 672 8894
-- Name: labelform_labelform_name_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY labelform
    ADD CONSTRAINT labelform_labelform_name_key UNIQUE (labelform_name);


--
-- TOC entry 7457 (class 2606 OID 146571257)
-- Dependencies: 672 672 8894
-- Name: labelform_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY labelform
    ADD CONSTRAINT labelform_pkey PRIMARY KEY (labelform_id);


--
-- TOC entry 7459 (class 2606 OID 146571259)
-- Dependencies: 674 674 8894
-- Name: lang_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY lang
    ADD CONSTRAINT lang_pkey PRIMARY KEY (lang_id);


--
-- TOC entry 7461 (class 2606 OID 146571261)
-- Dependencies: 676 676 8894
-- Name: locale_locale_code_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY locale
    ADD CONSTRAINT locale_locale_code_key UNIQUE (locale_code);


--
-- TOC entry 7463 (class 2606 OID 146571263)
-- Dependencies: 676 676 8894
-- Name: locale_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY locale
    ADD CONSTRAINT locale_pkey PRIMARY KEY (locale_id);


--
-- TOC entry 7093 (class 2606 OID 146571265)
-- Dependencies: 342 342 8894
-- Name: location_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY location
    ADD CONSTRAINT location_pkey PRIMARY KEY (location_id);


--
-- TOC entry 7465 (class 2606 OID 146571267)
-- Dependencies: 679 679 8894
-- Name: locitem_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY locitem
    ADD CONSTRAINT locitem_pkey PRIMARY KEY (locitem_id);


--
-- TOC entry 7173 (class 2606 OID 146571269)
-- Dependencies: 405 405 405 405 8894
-- Name: metasql_metasql_group_name_grade_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY metasql
    ADD CONSTRAINT metasql_metasql_group_name_grade_key UNIQUE (metasql_group, metasql_name, metasql_grade);


--
-- TOC entry 7175 (class 2606 OID 146571271)
-- Dependencies: 405 405 8894
-- Name: metasql_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY metasql
    ADD CONSTRAINT metasql_pkey PRIMARY KEY (metasql_id);


--
-- TOC entry 7467 (class 2606 OID 146571273)
-- Dependencies: 682 682 8894
-- Name: metric_metric_name_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY metric
    ADD CONSTRAINT metric_metric_name_key UNIQUE (metric_name);


--
-- TOC entry 7469 (class 2606 OID 146571275)
-- Dependencies: 682 682 8894
-- Name: metric_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY metric
    ADD CONSTRAINT metric_pkey PRIMARY KEY (metric_id);


--
-- TOC entry 7471 (class 2606 OID 146571277)
-- Dependencies: 684 684 8894
-- Name: metricenc_metricenc_name_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY metricenc
    ADD CONSTRAINT metricenc_metricenc_name_key UNIQUE (metricenc_name);


--
-- TOC entry 7473 (class 2606 OID 146571279)
-- Dependencies: 684 684 8894
-- Name: metricenc_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY metricenc
    ADD CONSTRAINT metricenc_pkey PRIMARY KEY (metricenc_id);


--
-- TOC entry 7475 (class 2606 OID 146571281)
-- Dependencies: 687 687 687 687 687 687 8894
-- Name: mrghist_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY mrghist
    ADD CONSTRAINT mrghist_pkey PRIMARY KEY (mrghist_cntct_id, mrghist_table, mrghist_pkey_col, mrghist_pkey_id, mrghist_cntct_col);


--
-- TOC entry 7477 (class 2606 OID 146571283)
-- Dependencies: 688 688 688 688 688 688 8894
-- Name: mrgundo_mrgundo_schema_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY mrgundo
    ADD CONSTRAINT mrgundo_mrgundo_schema_key UNIQUE (mrgundo_schema, mrgundo_table, mrgundo_pkey_col, mrgundo_pkey_id, mrgundo_col);


--
-- TOC entry 7479 (class 2606 OID 146571285)
-- Dependencies: 689 689 8894
-- Name: msg_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY msg
    ADD CONSTRAINT msg_pkey PRIMARY KEY (msg_id);


--
-- TOC entry 7481 (class 2606 OID 146571287)
-- Dependencies: 691 691 8894
-- Name: msguser_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY msguser
    ADD CONSTRAINT msguser_pkey PRIMARY KEY (msguser_id);

ALTER TABLE ONLY ophead
    ADD CONSTRAINT ophead_pkey PRIMARY KEY (ophead_id);


--
-- TOC entry 7485 (class 2606 OID 146571295)
-- Dependencies: 696 696 8894
-- Name: opsource_opsource_name_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY opsource
    ADD CONSTRAINT opsource_opsource_name_key UNIQUE (opsource_name);


--
-- TOC entry 7487 (class 2606 OID 146571297)
-- Dependencies: 696 696 8894
-- Name: opsource_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY opsource
    ADD CONSTRAINT opsource_pkey PRIMARY KEY (opsource_id);


--
-- TOC entry 7489 (class 2606 OID 146571299)
-- Dependencies: 698 698 8894
-- Name: opstage_opstage_name_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY opstage
    ADD CONSTRAINT opstage_opstage_name_key UNIQUE (opstage_name);


--
-- TOC entry 7491 (class 2606 OID 146571301)
-- Dependencies: 698 698 8894
-- Name: opstage_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY opstage
    ADD CONSTRAINT opstage_pkey PRIMARY KEY (opstage_id);


--
-- TOC entry 7493 (class 2606 OID 146571303)
-- Dependencies: 700 700 8894
-- Name: optype_optype_name_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY optype
    ADD CONSTRAINT optype_optype_name_key UNIQUE (optype_name);


--
-- TOC entry 7495 (class 2606 OID 146571305)
-- Dependencies: 700 700 8894
-- Name: optype_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY optype
    ADD CONSTRAINT optype_pkey PRIMARY KEY (optype_id);


--
-- TOC entry 7497 (class 2606 OID 146571307)
-- Dependencies: 704 704 8894
-- Name: orderseq_orderseq_name_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY orderseq
    ADD CONSTRAINT orderseq_orderseq_name_key UNIQUE (orderseq_name);


--
-- TOC entry 7499 (class 2606 OID 146571309)
-- Dependencies: 704 704 8894
-- Name: orderseq_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY orderseq
    ADD CONSTRAINT orderseq_pkey PRIMARY KEY (orderseq_id);


ALTER TABLE ONLY pack
    ADD CONSTRAINT pack_pkey PRIMARY KEY (pack_id);


--
-- TOC entry 7505 (class 2606 OID 146571313)
-- Dependencies: 708 708 708 8894
-- Name: payaropen_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY payaropen
    ADD CONSTRAINT payaropen_pkey PRIMARY KEY (payaropen_ccpay_id, payaropen_aropen_id);


--
-- TOC entry 6960 (class 2606 OID 146571315)
-- Dependencies: 264 264 8894
-- Name: period_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY period
    ADD CONSTRAINT period_pkey PRIMARY KEY (period_id);


--
-- TOC entry 7538 (class 2606 OID 146571317)
-- Dependencies: 739 739 8894
-- Name: pk_prjtype; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY prjtype
    ADD CONSTRAINT pk_prjtype PRIMARY KEY (prjtype_id);






--
-- TOC entry 7060 (class 2606 OID 146571329)
-- Dependencies: 326 326 8894
-- Name: plancode_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY plancode
    ADD CONSTRAINT plancode_pkey PRIMARY KEY (plancode_id);


--
-- TOC entry 7062 (class 2606 OID 146571331)
-- Dependencies: 326 326 8894
-- Name: plancode_plancode_code_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY plancode
    ADD CONSTRAINT plancode_plancode_code_key UNIQUE (plancode_code);


ALTER TABLE ONLY pohead
    ADD CONSTRAINT pohead_pkey PRIMARY KEY (pohead_id);

ALTER TABLE ONLY poitem
    ADD CONSTRAINT poitem_pkey PRIMARY KEY (poitem_id);

ALTER TABLE ONLY poreject
    ADD CONSTRAINT poreject_pkey PRIMARY KEY (poreject_id);

--
-- TOC entry 7526 (class 2606 OID 146571345)
-- Dependencies: 728 728 8894
-- Name: pr_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY pr
    ADD CONSTRAINT pr_pkey PRIMARY KEY (pr_id);


--
-- TOC entry 7528 (class 2606 OID 146571347)
-- Dependencies: 730 730 8894
-- Name: prftcntr_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY prftcntr
    ADD CONSTRAINT prftcntr_pkey PRIMARY KEY (prftcntr_id);


--
-- TOC entry 7530 (class 2606 OID 146571349)
-- Dependencies: 730 730 8894
-- Name: prftcntr_prftcntr_number_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY prftcntr
    ADD CONSTRAINT prftcntr_prftcntr_number_key UNIQUE (prftcntr_number);

ALTER TABLE ONLY priv
    ADD CONSTRAINT priv_pkey PRIMARY KEY (priv_id);


ALTER TABLE ONLY prj
    ADD CONSTRAINT prj_pkey PRIMARY KEY (prj_id);

ALTER TABLE ONLY prjtask
    ADD CONSTRAINT prjtask_pkey PRIMARY KEY (prjtask_id);


--
-- TOC entry 7536 (class 2606 OID 146571361)
-- Dependencies: 737 737 8894
-- Name: prjtaskuser_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY prjtaskuser
    ADD CONSTRAINT prjtaskuser_pkey PRIMARY KEY (prjtaskuser_id);


--
-- TOC entry 7040 (class 2606 OID 146571363)
-- Dependencies: 314 314 8894
-- Name: prodcat_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY prodcat
    ADD CONSTRAINT prodcat_pkey PRIMARY KEY (prodcat_id);


--
-- TOC entry 7042 (class 2606 OID 146571365)
-- Dependencies: 314 314 8894
-- Name: prodcat_prodcat_code_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY prodcat
    ADD CONSTRAINT prodcat_prodcat_code_key UNIQUE (prodcat_code);

ALTER TABLE ONLY prospect
    ADD CONSTRAINT prospect_pkey PRIMARY KEY (prospect_id);


--
-- TOC entry 7542 (class 2606 OID 146571371)
-- Dependencies: 742 742 8894
-- Name: qryhead_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY qryhead
    ADD CONSTRAINT qryhead_pkey PRIMARY KEY (qryhead_id);


--
-- TOC entry 7544 (class 2606 OID 146571373)
-- Dependencies: 742 742 8894
-- Name: qryhead_qryhead_name_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY qryhead
    ADD CONSTRAINT qryhead_qryhead_name_key UNIQUE (qryhead_name);


--
-- TOC entry 7546 (class 2606 OID 146571375)
-- Dependencies: 744 744 744 8894
-- Name: qryitem_qryitem_qryhead_id_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY qryitem
    ADD CONSTRAINT qryitem_qryitem_qryhead_id_key UNIQUE (qryitem_qryhead_id, qryitem_name);


--
-- TOC entry 7548 (class 2606 OID 146571377)
-- Dependencies: 744 744 744 8894
-- Name: qryitem_qryitem_qryhead_id_key1; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY qryitem
    ADD CONSTRAINT qryitem_qryitem_qryhead_id_key1 UNIQUE (qryitem_qryhead_id, qryitem_order);


ALTER TABLE ONLY quhead
    ADD CONSTRAINT quhead_pkey PRIMARY KEY (quhead_id);


ALTER TABLE ONLY quitem
    ADD CONSTRAINT quitem_pkey PRIMARY KEY (quitem_id);


--
-- TOC entry 7550 (class 2606 OID 146571385)
-- Dependencies: 748 748 8894
-- Name: rcalitem_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY rcalitem
    ADD CONSTRAINT rcalitem_pkey PRIMARY KEY (rcalitem_id);


--
-- TOC entry 7556 (class 2606 OID 146571391)
-- Dependencies: 751 751 8894
-- Name: recurtype_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY recurtype
    ADD CONSTRAINT recurtype_pkey PRIMARY KEY (recurtype_id);


--
-- TOC entry 7558 (class 2606 OID 146571393)
-- Dependencies: 751 751 8894
-- Name: recurtype_recurtype_type_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY recurtype
    ADD CONSTRAINT recurtype_recurtype_type_key UNIQUE (recurtype_type);


--
-- TOC entry 7520 (class 2606 OID 146571395)
-- Dependencies: 721 721 8894
-- Name: recv_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY recv
    ADD CONSTRAINT recv_pkey PRIMARY KEY (recv_id);


--
-- TOC entry 7185 (class 2606 OID 146571397)
-- Dependencies: 411 411 8894
-- Name: report_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY report
    ADD CONSTRAINT report_pkey PRIMARY KEY (report_id);


--
-- TOC entry 7560 (class 2606 OID 146571399)
-- Dependencies: 755 755 8894
-- Name: rjctcode_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY rjctcode
    ADD CONSTRAINT rjctcode_pkey PRIMARY KEY (rjctcode_id);


--
-- TOC entry 7562 (class 2606 OID 146571401)
-- Dependencies: 755 755 8894
-- Name: rjctcode_rjctcode_code_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY rjctcode
    ADD CONSTRAINT rjctcode_rjctcode_code_key UNIQUE (rjctcode_code);


--
-- TOC entry 6858 (class 2606 OID 146571403)
-- Dependencies: 214 214 8894
-- Name: rsncode_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY rsncode
    ADD CONSTRAINT rsncode_pkey PRIMARY KEY (rsncode_id);


--
-- TOC entry 6860 (class 2606 OID 146571405)
-- Dependencies: 214 214 8894
-- Name: rsncode_rsncode_code_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY rsncode
    ADD CONSTRAINT rsncode_rsncode_code_key UNIQUE (rsncode_code);


--
-- TOC entry 7564 (class 2606 OID 146571407)
-- Dependencies: 758 758 8894
-- Name: sale_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY sale
    ADD CONSTRAINT sale_pkey PRIMARY KEY (sale_id);


--
-- TOC entry 7566 (class 2606 OID 146571409)
-- Dependencies: 758 758 8894
-- Name: sale_sale_name_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY sale
    ADD CONSTRAINT sale_sale_name_key UNIQUE (sale_name);


--
-- TOC entry 7324 (class 2606 OID 146571411)
-- Dependencies: 540 540 8894
-- Name: salesaccnt_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY salesaccnt
    ADD CONSTRAINT salesaccnt_pkey PRIMARY KEY (salesaccnt_id);


--
-- TOC entry 6862 (class 2606 OID 146571413)
-- Dependencies: 215 215 8894
-- Name: salescat_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY salescat
    ADD CONSTRAINT salescat_pkey PRIMARY KEY (salescat_id);


--
-- TOC entry 6864 (class 2606 OID 146571415)
-- Dependencies: 215 215 8894
-- Name: salescat_salescat_name_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY salescat
    ADD CONSTRAINT salescat_salescat_name_key UNIQUE (salescat_name);

ALTER TABLE ONLY salesrep
    ADD CONSTRAINT salesrep_pkey PRIMARY KEY (salesrep_id);

ALTER TABLE ONLY saletype
    ADD CONSTRAINT saletype_pkey PRIMARY KEY (saletype_id);


--
-- TOC entry 7568 (class 2606 OID 146571423)
-- Dependencies: 766 766 8894
-- Name: schemaord_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY schemaord
    ADD CONSTRAINT schemaord_pkey PRIMARY KEY (schemaord_id);


--
-- TOC entry 7570 (class 2606 OID 146571425)
-- Dependencies: 766 766 8894
-- Name: schemaord_schemaord_name_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY schemaord
    ADD CONSTRAINT schemaord_schemaord_name_key UNIQUE (schemaord_name);


--
-- TOC entry 7572 (class 2606 OID 146571427)
-- Dependencies: 766 766 8894
-- Name: schemaord_schemaord_order_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY schemaord
    ADD CONSTRAINT schemaord_schemaord_order_key UNIQUE (schemaord_order);


--
-- TOC entry 7189 (class 2606 OID 146571429)
-- Dependencies: 414 414 8894
-- Name: script_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY script
    ADD CONSTRAINT script_pkey PRIMARY KEY (script_id);


--
-- TOC entry 7005 (class 2606 OID 146571431)
-- Dependencies: 293 293 8894
-- Name: shift_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY shift
    ADD CONSTRAINT shift_pkey PRIMARY KEY (shift_id);


--
-- TOC entry 6983 (class 2606 OID 146571433)
-- Dependencies: 281 281 8894
-- Name: shipchrg_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY shipchrg
    ADD CONSTRAINT shipchrg_pkey PRIMARY KEY (shipchrg_id);


--
-- TOC entry 7008 (class 2606 OID 146571435)
-- Dependencies: 297 297 297 297 297 8894
-- Name: shipdata_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY shipdata
    ADD CONSTRAINT shipdata_pkey PRIMARY KEY (shipdata_cohead_number, shipdata_cosmisc_tracknum, shipdata_cosmisc_packnum_tracknum, shipdata_void_ind);


--
-- TOC entry 7576 (class 2606 OID 146571437)
-- Dependencies: 771 771 771 771 8894
-- Name: shipdatasum_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY shipdatasum
    ADD CONSTRAINT shipdatasum_pkey PRIMARY KEY (shipdatasum_cohead_number, shipdatasum_cosmisc_tracknum, shipdatasum_cosmisc_packnum_tracknum);


--
-- TOC entry 6985 (class 2606 OID 146571439)
-- Dependencies: 282 282 8894
-- Name: shipform_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY shipform
    ADD CONSTRAINT shipform_pkey PRIMARY KEY (shipform_id);


--
-- TOC entry 6987 (class 2606 OID 146571441)
-- Dependencies: 282 282 8894
-- Name: shipform_shipform_name_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY shipform
    ADD CONSTRAINT shipform_shipform_name_key UNIQUE (shipform_name);

ALTER TABLE ONLY shiphead
    ADD CONSTRAINT shiphead_pkey PRIMARY KEY (shiphead_id);

-- required to meet a f-key constraint later
ALTER TABLE ONLY shiphead
    ADD CONSTRAINT shiphead_shiphead_number_key UNIQUE (shiphead_number);

--
-- TOC entry 7311 (class 2606 OID 146571447)
-- Dependencies: 527 527 8894
-- Name: shipitem_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY shipitem
    ADD CONSTRAINT shipitem_pkey PRIMARY KEY (shipitem_id);


ALTER TABLE ONLY shiptoinfo
    ADD CONSTRAINT shipto_pkey PRIMARY KEY (shipto_id);


--
-- TOC entry 7151 (class 2606 OID 146571453)
-- Dependencies: 386 386 8894
-- Name: shipvia_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY shipvia
    ADD CONSTRAINT shipvia_pkey PRIMARY KEY (shipvia_id);


--
-- TOC entry 7153 (class 2606 OID 146571455)
-- Dependencies: 386 386 8894
-- Name: shipvia_shipvia_code_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY shipvia
    ADD CONSTRAINT shipvia_shipvia_code_key UNIQUE (shipvia_code);


--
-- TOC entry 6898 (class 2606 OID 146571457)
-- Dependencies: 227 227 8894
-- Name: shipzone_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY shipzone
    ADD CONSTRAINT shipzone_pkey PRIMARY KEY (shipzone_id);


--
-- TOC entry 6900 (class 2606 OID 146571459)
-- Dependencies: 227 227 8894
-- Name: shipzone_shipzone_name_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY shipzone
    ADD CONSTRAINT shipzone_shipzone_name_key UNIQUE (shipzone_name);


--
-- TOC entry 7155 (class 2606 OID 146571461)
-- Dependencies: 387 387 8894
-- Name: sitetype_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY sitetype
    ADD CONSTRAINT sitetype_pkey PRIMARY KEY (sitetype_id);


--
-- TOC entry 7157 (class 2606 OID 146571463)
-- Dependencies: 387 387 8894
-- Name: sitetype_sitetype_name_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY sitetype
    ADD CONSTRAINT sitetype_sitetype_name_key UNIQUE (sitetype_name);


--
-- TOC entry 7578 (class 2606 OID 146571465)
-- Dependencies: 781 781 8894
-- Name: sltrans_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY sltrans
    ADD CONSTRAINT sltrans_pkey PRIMARY KEY (sltrans_id);

ALTER TABLE ONLY source
    ADD CONSTRAINT source_pkey PRIMARY KEY (source_id);


--
-- TOC entry 7588 (class 2606 OID 146571471)
-- Dependencies: 787 787 8894
-- Name: state_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY state
    ADD CONSTRAINT state_pkey PRIMARY KEY (state_id);


--
-- TOC entry 7590 (class 2606 OID 146571473)
-- Dependencies: 787 787 787 8894
-- Name: state_state_country_id_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY state
    ADD CONSTRAINT state_state_country_id_key UNIQUE (state_country_id, state_name);


--
-- TOC entry 7592 (class 2606 OID 146571475)
-- Dependencies: 789 789 8894
-- Name: status_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY status
    ADD CONSTRAINT status_pkey PRIMARY KEY (status_id);


--
-- TOC entry 7594 (class 2606 OID 146571477)
-- Dependencies: 789 789 789 8894
-- Name: status_status_type_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY status
    ADD CONSTRAINT status_status_type_key UNIQUE (status_type, status_code);


--
-- TOC entry 7596 (class 2606 OID 146571479)
-- Dependencies: 791 791 8894
-- Name: stdjrnl_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY stdjrnl
    ADD CONSTRAINT stdjrnl_pkey PRIMARY KEY (stdjrnl_id);


--
-- TOC entry 7598 (class 2606 OID 146571481)
-- Dependencies: 791 791 8894
-- Name: stdjrnl_stdjrnl_name_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY stdjrnl
    ADD CONSTRAINT stdjrnl_stdjrnl_name_key UNIQUE (stdjrnl_name);


--
-- TOC entry 7600 (class 2606 OID 146571483)
-- Dependencies: 793 793 8894
-- Name: stdjrnlgrp_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY stdjrnlgrp
    ADD CONSTRAINT stdjrnlgrp_pkey PRIMARY KEY (stdjrnlgrp_id);


--
-- TOC entry 7602 (class 2606 OID 146571485)
-- Dependencies: 793 793 8894
-- Name: stdjrnlgrp_stdjrnlgrp_name_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY stdjrnlgrp
    ADD CONSTRAINT stdjrnlgrp_stdjrnlgrp_name_key UNIQUE (stdjrnlgrp_name);


--
-- TOC entry 7604 (class 2606 OID 146571487)
-- Dependencies: 795 795 8894
-- Name: stdjrnlgrpitem_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY stdjrnlgrpitem
    ADD CONSTRAINT stdjrnlgrpitem_pkey PRIMARY KEY (stdjrnlgrpitem_id);


--
-- TOC entry 7606 (class 2606 OID 146571489)
-- Dependencies: 797 797 8894
-- Name: stdjrnlitem_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY stdjrnlitem
    ADD CONSTRAINT stdjrnlitem_pkey PRIMARY KEY (stdjrnlitem_id);


--
-- TOC entry 7608 (class 2606 OID 146571491)
-- Dependencies: 799 799 8894
-- Name: subaccnt_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY subaccnt
    ADD CONSTRAINT subaccnt_pkey PRIMARY KEY (subaccnt_id);


--
-- TOC entry 7610 (class 2606 OID 146571493)
-- Dependencies: 799 799 8894
-- Name: subaccnt_subaccnt_number_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY subaccnt
    ADD CONSTRAINT subaccnt_subaccnt_number_key UNIQUE (subaccnt_number);


--
-- TOC entry 7613 (class 2606 OID 146571495)
-- Dependencies: 801 801 8894
-- Name: subaccnttype_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY subaccnttype
    ADD CONSTRAINT subaccnttype_pkey PRIMARY KEY (subaccnttype_id);

ALTER TABLE ONLY tax
    ADD CONSTRAINT tax_pkey PRIMARY KEY (tax_id);

ALTER TABLE ONLY taxass
    ADD CONSTRAINT taxass_pkey PRIMARY KEY (taxass_id);

ALTER TABLE ONLY taxauth
    ADD CONSTRAINT taxauth_pkey PRIMARY KEY (taxauth_id);


--
-- TOC entry 7619 (class 2606 OID 146571507)
-- Dependencies: 807 807 8894
-- Name: taxclass_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY taxclass
    ADD CONSTRAINT taxclass_pkey PRIMARY KEY (taxclass_id);


--
-- TOC entry 7621 (class 2606 OID 146571509)
-- Dependencies: 807 807 8894
-- Name: taxclass_taxclass_code_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY taxclass
    ADD CONSTRAINT taxclass_taxclass_code_key UNIQUE (taxclass_code);

ALTER TABLE ONLY taxhist
    ADD CONSTRAINT taxhist_pkey PRIMARY KEY (taxhist_id);


--
-- TOC entry 7623 (class 2606 OID 146571513)
-- Dependencies: 809 809 8894
-- Name: taxrate_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY taxrate
    ADD CONSTRAINT taxrate_pkey PRIMARY KEY (taxrate_id);


--
-- TOC entry 6993 (class 2606 OID 146571515)
-- Dependencies: 285 285 8894
-- Name: taxreg_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY taxreg
    ADD CONSTRAINT taxreg_pkey PRIMARY KEY (taxreg_id);


--
-- TOC entry 6797 (class 2606 OID 146571517)
-- Dependencies: 199 199 8894
-- Name: taxtype_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY taxtype
    ADD CONSTRAINT taxtype_pkey PRIMARY KEY (taxtype_id);


--
-- TOC entry 6799 (class 2606 OID 146571519)
-- Dependencies: 199 199 8894
-- Name: taxtype_taxtype_name_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY taxtype
    ADD CONSTRAINT taxtype_taxtype_name_key UNIQUE (taxtype_name);


--
-- TOC entry 6879 (class 2606 OID 146571521)
-- Dependencies: 220 220 8894
-- Name: taxzone_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY taxzone
    ADD CONSTRAINT taxzone_pkey PRIMARY KEY (taxzone_id);


--
-- TOC entry 6881 (class 2606 OID 146571523)
-- Dependencies: 220 220 8894
-- Name: taxzone_taxzone_code_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY taxzone
    ADD CONSTRAINT taxzone_taxzone_code_key UNIQUE (taxzone_code);


--
-- TOC entry 6837 (class 2606 OID 146571525)
-- Dependencies: 209 209 8894
-- Name: terms_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY terms
    ADD CONSTRAINT terms_pkey PRIMARY KEY (terms_id);


--
-- TOC entry 6839 (class 2606 OID 146571527)
-- Dependencies: 209 209 8894
-- Name: terms_terms_code_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY terms
    ADD CONSTRAINT terms_terms_code_key UNIQUE (terms_code);


--
-- TOC entry 6916 (class 2606 OID 146571529)
-- Dependencies: 233 233 8894
-- Name: todoitem_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY todoitem
    ADD CONSTRAINT todoitem_pkey PRIMARY KEY (todoitem_id);


--
-- TOC entry 7626 (class 2606 OID 146571531)
-- Dependencies: 817 817 8894
-- Name: trialbal_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY trialbal
    ADD CONSTRAINT trialbal_pkey PRIMARY KEY (trialbal_id);

ALTER TABLE ONLY uiform
    ADD CONSTRAINT uiform_pkey PRIMARY KEY (uiform_id);


--
-- TOC entry 7540 (class 2606 OID 146571535)
-- Dependencies: 739 739 8894
-- Name: unq_prjtype_code; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY prjtype
    ADD CONSTRAINT unq_prjtype_code UNIQUE (prjtype_code);


--
-- TOC entry 6801 (class 2606 OID 146571537)
-- Dependencies: 200 200 8894
-- Name: uom_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY uom
    ADD CONSTRAINT uom_pkey PRIMARY KEY (uom_id);


--
-- TOC entry 6803 (class 2606 OID 146571539)
-- Dependencies: 200 200 8894
-- Name: uom_uom_name_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY uom
    ADD CONSTRAINT uom_uom_name_key UNIQUE (uom_name);


--
-- TOC entry 7628 (class 2606 OID 146571541)
-- Dependencies: 820 820 8894
-- Name: uomconv_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY uomconv
    ADD CONSTRAINT uomconv_pkey PRIMARY KEY (uomconv_id);


--
-- TOC entry 7630 (class 2606 OID 146571543)
-- Dependencies: 822 822 8894
-- Name: uomtype_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY uomtype
    ADD CONSTRAINT uomtype_pkey PRIMARY KEY (uomtype_id);


--
-- TOC entry 7632 (class 2606 OID 146571545)
-- Dependencies: 822 822 8894
-- Name: uomtype_uomtype_name_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY uomtype
    ADD CONSTRAINT uomtype_uomtype_name_key UNIQUE (uomtype_name);


--
-- TOC entry 6941 (class 2606 OID 146571547)
-- Dependencies: 244 244 8894
-- Name: urlinfo_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY urlinfo
    ADD CONSTRAINT urlinfo_pkey PRIMARY KEY (url_id);


--
-- TOC entry 7637 (class 2606 OID 146571549)
-- Dependencies: 827 827 8894
-- Name: usr_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY usr_bak
    ADD CONSTRAINT usr_pkey PRIMARY KEY (usr_id);


--
-- TOC entry 7639 (class 2606 OID 146571551)
-- Dependencies: 827 827 8894
-- Name: usr_usr_username_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY usr_bak
    ADD CONSTRAINT usr_usr_username_key UNIQUE (usr_username);


--
-- TOC entry 7532 (class 2606 OID 146571553)
-- Dependencies: 732 732 8894
-- Name: usrgrp_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY usrgrp
    ADD CONSTRAINT usrgrp_pkey PRIMARY KEY (usrgrp_id);


--
-- TOC entry 7634 (class 2606 OID 146571555)
-- Dependencies: 825 825 8894
-- Name: usrpref_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY usrpref
    ADD CONSTRAINT usrpref_pkey PRIMARY KEY (usrpref_id);


--
-- TOC entry 7534 (class 2606 OID 146571557)
-- Dependencies: 733 733 8894
-- Name: usrpriv_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY usrpriv
    ADD CONSTRAINT usrpriv_pkey PRIMARY KEY (usrpriv_id);

ALTER TABLE ONLY vendinfo
    ADD CONSTRAINT vend_pkey PRIMARY KEY (vend_id);


--
-- TOC entry 7127 (class 2606 OID 146571561)
-- Dependencies: 364 364 8894
-- Name: vendaddr_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY vendaddrinfo
    ADD CONSTRAINT vendaddr_pkey PRIMARY KEY (vendaddr_id);



--
-- TOC entry 7159 (class 2606 OID 146571565)
-- Dependencies: 393 393 8894
-- Name: vendtype_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY vendtype
    ADD CONSTRAINT vendtype_pkey PRIMARY KEY (vendtype_id);


--
-- TOC entry 7161 (class 2606 OID 146571567)
-- Dependencies: 393 393 8894
-- Name: vendtype_vendtype_code_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY vendtype
    ADD CONSTRAINT vendtype_vendtype_code_key UNIQUE (vendtype_code);

ALTER TABLE ONLY vodist
    ADD CONSTRAINT vodist_pkey PRIMARY KEY (vodist_id);

ALTER TABLE ONLY vohead
    ADD CONSTRAINT vohead_pkey PRIMARY KEY (vohead_id);


--
-- TOC entry 7647 (class 2606 OID 146571575)
-- Dependencies: 841 841 8894
-- Name: voheadtax_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY voheadtax
    ADD CONSTRAINT voheadtax_pkey PRIMARY KEY (taxhist_id);


--
-- TOC entry 7649 (class 2606 OID 146571577)
-- Dependencies: 842 842 8894
-- Name: voitem_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY voitem
    ADD CONSTRAINT voitem_pkey PRIMARY KEY (voitem_id);


--
-- TOC entry 7651 (class 2606 OID 146571579)
-- Dependencies: 844 844 8894
-- Name: voitemtax_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY voitemtax
    ADD CONSTRAINT voitemtax_pkey PRIMARY KEY (taxhist_id);

ALTER TABLE ONLY whsinfo
    ADD CONSTRAINT warehous_pkey PRIMARY KEY (warehous_id);


--
-- TOC entry 7096 (class 2606 OID 146571583)
-- Dependencies: 343 343 8894
-- Name: whsezone_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY whsezone
    ADD CONSTRAINT whsezone_pkey PRIMARY KEY (whsezone_id);


--
-- TOC entry 7345 (class 2606 OID 146571587)
-- Dependencies: 560 560 8894
-- Name: wo_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY wo
    ADD CONSTRAINT wo_pkey PRIMARY KEY (wo_id);


--
-- TOC entry 7122 (class 2606 OID 146571589)
-- Dependencies: 359 359 8894
-- Name: womatl_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY womatl
    ADD CONSTRAINT womatl_pkey PRIMARY KEY (womatl_id);


--
-- TOC entry 7653 (class 2606 OID 146571591)
-- Dependencies: 850 850 8894
-- Name: womatlpost_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY womatlpost
    ADD CONSTRAINT womatlpost_pkey PRIMARY KEY (womatlpost_id);


--
-- TOC entry 7655 (class 2606 OID 146571593)
-- Dependencies: 852 852 8894
-- Name: womatlvar_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY womatlvar
    ADD CONSTRAINT womatlvar_pkey PRIMARY KEY (womatlvar_id);


--
-- TOC entry 7657 (class 2606 OID 146571595)
-- Dependencies: 855 855 8894
-- Name: xsltmap_name_key; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY xsltmap
    ADD CONSTRAINT xsltmap_name_key UNIQUE (xsltmap_name);


--
-- TOC entry 7659 (class 2606 OID 146571597)
-- Dependencies: 855 855 8894
-- Name: xsltmap_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY xsltmap
    ADD CONSTRAINT xsltmap_pkey PRIMARY KEY (xsltmap_id);


--
-- TOC entry 7661 (class 2606 OID 146571599)
-- Dependencies: 857 857 8894
-- Name: yearperiod_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace:
--

ALTER TABLE ONLY yearperiod
    ADD CONSTRAINT yearperiod_pkey PRIMARY KEY (yearperiod_id);


--
-- TOC entry 7248 (class 1259 OID 146571663)
-- Dependencies: 468 468 468 8894
-- Name: bomitemcost_master_idx; Type: INDEX; Schema: public; Owner: admin; Tablespace:
--

CREATE UNIQUE INDEX bomitemcost_master_idx ON bomitemcost USING btree (bomitemcost_bomitem_id, bomitemcost_costelem_id, bomitemcost_lowlevel);


--
-- TOC entry 6772 (class 1259 OID 146571686)
-- Dependencies: 195 8894
-- Name: cohead_number_idx; Type: INDEX; Schema: public; Owner: admin; Tablespace:
--

CREATE UNIQUE INDEX cohead_number_idx ON cohead USING btree (cohead_number);


--
-- TOC entry 6777 (class 1259 OID 146571694)
-- Dependencies: 196 196 196 8894
-- Name: coitem_coitem_cohead_id_key; Type: INDEX; Schema: public; Owner: admin; Tablespace:
--

CREATE UNIQUE INDEX coitem_coitem_cohead_id_key ON coitem USING btree (coitem_cohead_id, coitem_linenumber, coitem_subnumber);


--
-- TOC entry 7063 (class 1259 OID 146571699)
-- Dependencies: 329 329 8894
-- Name: contrct_master_idx; Type: INDEX; Schema: public; Owner: admin; Tablespace:
--

CREATE UNIQUE INDEX contrct_master_idx ON contrct USING btree (contrct_number, contrct_vend_id);


--
-- TOC entry 6852 (class 1259 OID 146571700)
-- Dependencies: 213 8894
-- Name: cust_number_idx; Type: INDEX; Schema: public; Owner: admin; Tablespace:
--

CREATE UNIQUE INDEX cust_number_idx ON custinfo USING btree (cust_number);


--
-- TOC entry 6750 (class 1259 OID 146571724)
-- Dependencies: 191 8894
-- Name: item_number_idx; Type: INDEX; Schema: public; Owner: admin; Tablespace:
--

CREATE UNIQUE INDEX item_number_idx ON item USING btree (item_number);


--
-- TOC entry 7052 (class 1259 OID 146571728)
-- Dependencies: 321 321 321 8894
-- Name: itemcost_master_idx; Type: INDEX; Schema: public; Owner: admin; Tablespace:
--

CREATE UNIQUE INDEX itemcost_master_idx ON itemcost USING btree (itemcost_item_id, itemcost_costelem_id, itemcost_lowlevel);


--
-- TOC entry 6757 (class 1259 OID 146571733)
-- Dependencies: 192 192 8894
-- Name: itemsite_item_warehous_id_key; Type: INDEX; Schema: public; Owner: admin; Tablespace:
--

CREATE UNIQUE INDEX itemsite_item_warehous_id_key ON itemsite USING btree (itemsite_item_id, itemsite_warehous_id);


--
-- TOC entry 7178 (class 1259 OID 146571750)
-- Dependencies: 408 8894
-- Name: priv_name_idx; Type: INDEX; Schema: public; Owner: admin; Tablespace:
--

CREATE UNIQUE INDEX priv_name_idx ON priv USING btree (priv_name);


--
-- TOC entry 7183 (class 1259 OID 146571753)
-- Dependencies: 411 411 8894
-- Name: report_name_grade_idx; Type: INDEX; Schema: public; Owner: admin; Tablespace:
--

CREATE UNIQUE INDEX report_name_grade_idx ON report USING btree (report_name, report_grade);


--
-- TOC entry 7611 (class 1259 OID 146571768)
-- Dependencies: 801 8894
-- Name: subaccnttype_code_idx; Type: INDEX; Schema: public; Owner: admin; Tablespace:
--

CREATE UNIQUE INDEX subaccnttype_code_idx ON subaccnttype USING btree (subaccnttype_code);


--
-- TOC entry 7624 (class 1259 OID 146571770)
-- Dependencies: 817 817 8894
-- Name: trialbal_accnt_period_idx; Type: INDEX; Schema: public; Owner: admin; Tablespace:
--

CREATE UNIQUE INDEX trialbal_accnt_period_idx ON trialbal USING btree (trialbal_accnt_id, trialbal_period_id);


--
-- TOC entry 6840 (class 1259 OID 146571772)
-- Dependencies: 210 8894
-- Name: vend_number_idx; Type: INDEX; Schema: public; Owner: admin; Tablespace:
--

CREATE UNIQUE INDEX vend_number_idx ON vendinfo USING btree (vend_number);


--
-- TOC entry 7979 (class 2606 OID 146572419)
-- Dependencies: 6834 208 434 8894
-- Name: apcreditapply_curr_symbol; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY apcreditapply
    ADD CONSTRAINT apcreditapply_curr_symbol FOREIGN KEY (apcreditapply_curr_id) REFERENCES curr_symbol(curr_id);



--
-- TOC entry 7980 (class 2606 OID 146572434)
-- Dependencies: 7124 363 438 8894
-- Name: apopentax_taxhist_basis_tax_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY apopentax
    ADD CONSTRAINT apopentax_taxhist_basis_tax_id_fkey FOREIGN KEY (taxhist_basis_tax_id) REFERENCES tax(tax_id);


--
-- TOC entry 7981 (class 2606 OID 146572439)
-- Dependencies: 6828 207 438 8894
-- Name: apopentax_taxhist_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY apopentax
    ADD CONSTRAINT apopentax_taxhist_parent_id_fkey FOREIGN KEY (taxhist_parent_id) REFERENCES apopen(apopen_id) ON DELETE CASCADE;


--
-- TOC entry 7982 (class 2606 OID 146572444)
-- Dependencies: 7124 363 438 8894
-- Name: apopentax_taxhist_tax_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY apopentax
    ADD CONSTRAINT apopentax_taxhist_tax_id_fkey FOREIGN KEY (taxhist_tax_id) REFERENCES tax(tax_id);


--
-- TOC entry 7983 (class 2606 OID 146572449)
-- Dependencies: 6796 199 438 8894
-- Name: apopentax_taxhist_taxtype_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY apopentax
    ADD CONSTRAINT apopentax_taxhist_taxtype_id_fkey FOREIGN KEY (taxhist_taxtype_id) REFERENCES taxtype(taxtype_id);


--
-- TOC entry 7984 (class 2606 OID 146572454)
-- Dependencies: 6834 208 439 8894
-- Name: apselect_to_curr_symbol; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY apselect
    ADD CONSTRAINT apselect_to_curr_symbol FOREIGN KEY (apselect_curr_id) REFERENCES curr_symbol(curr_id);



--
-- TOC entry 7986 (class 2606 OID 146572464)
-- Dependencies: 6834 208 446 8894
-- Name: arcreditapply_curr_symbol; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY arcreditapply
    ADD CONSTRAINT arcreditapply_curr_symbol FOREIGN KEY (arcreditapply_curr_id) REFERENCES curr_symbol(curr_id);


--
-- TOC entry 7987 (class 2606 OID 146572484)
-- Dependencies: 7124 363 450 8894
-- Name: aropentax_taxhist_basis_tax_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY aropentax
    ADD CONSTRAINT aropentax_taxhist_basis_tax_id_fkey FOREIGN KEY (taxhist_basis_tax_id) REFERENCES tax(tax_id);


--
-- TOC entry 7988 (class 2606 OID 146572489)
-- Dependencies: 6849 212 450 8894
-- Name: aropentax_taxhist_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY aropentax
    ADD CONSTRAINT aropentax_taxhist_parent_id_fkey FOREIGN KEY (taxhist_parent_id) REFERENCES aropen(aropen_id) ON DELETE CASCADE;


--
-- TOC entry 7989 (class 2606 OID 146572494)
-- Dependencies: 7124 363 450 8894
-- Name: aropentax_taxhist_tax_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY aropentax
    ADD CONSTRAINT aropentax_taxhist_tax_id_fkey FOREIGN KEY (taxhist_tax_id) REFERENCES tax(tax_id);


--
-- TOC entry 7990 (class 2606 OID 146572499)
-- Dependencies: 6796 199 450 8894
-- Name: aropentax_taxhist_taxtype_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY aropentax
    ADD CONSTRAINT aropentax_taxhist_taxtype_id_fkey FOREIGN KEY (taxhist_taxtype_id) REFERENCES taxtype(taxtype_id);


--
-- TOC entry 7994 (class 2606 OID 146572519)
-- Dependencies: 7124 363 453 8894
-- Name: asohisttax_taxhist_basis_tax_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY asohisttax
    ADD CONSTRAINT asohisttax_taxhist_basis_tax_id_fkey FOREIGN KEY (taxhist_basis_tax_id) REFERENCES tax(tax_id);


--
-- TOC entry 7995 (class 2606 OID 146572524)
-- Dependencies: 7229 451 453 8894
-- Name: asohisttax_taxhist_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY asohisttax
    ADD CONSTRAINT asohisttax_taxhist_parent_id_fkey FOREIGN KEY (taxhist_parent_id) REFERENCES asohist(asohist_id) ON DELETE CASCADE;


--
-- TOC entry 7996 (class 2606 OID 146572529)
-- Dependencies: 7124 363 453 8894
-- Name: asohisttax_taxhist_tax_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY asohisttax
    ADD CONSTRAINT asohisttax_taxhist_tax_id_fkey FOREIGN KEY (taxhist_tax_id) REFERENCES tax(tax_id);


--
-- TOC entry 7997 (class 2606 OID 146572534)
-- Dependencies: 6796 199 453 8894
-- Name: asohisttax_taxhist_taxtype_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY asohisttax
    ADD CONSTRAINT asohisttax_taxhist_taxtype_id_fkey FOREIGN KEY (taxhist_taxtype_id) REFERENCES taxtype(taxtype_id);



--
-- TOC entry 7998 (class 2606 OID 146572544)
-- Dependencies: 6834 208 458 8894
-- Name: bankadj_to_curr_symbol; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY bankadj
    ADD CONSTRAINT bankadj_to_curr_symbol FOREIGN KEY (bankadj_curr_id) REFERENCES curr_symbol(curr_id);





--
-- TOC entry 7999 (class 2606 OID 146572574)
-- Dependencies: 6810 203 468 8894
-- Name: bomitemcost_bomitemcost_bomitem_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY bomitemcost
    ADD CONSTRAINT bomitemcost_bomitemcost_bomitem_id_fkey FOREIGN KEY (bomitemcost_bomitem_id) REFERENCES bomitem(bomitem_id);


--
-- TOC entry 8000 (class 2606 OID 146572579)
-- Dependencies: 7049 320 468 8894
-- Name: bomitemcost_bomitemcost_costelem_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY bomitemcost
    ADD CONSTRAINT bomitemcost_bomitemcost_costelem_id_fkey FOREIGN KEY (bomitemcost_costelem_id) REFERENCES costelem(costelem_id);


--
-- TOC entry 8001 (class 2606 OID 146572584)
-- Dependencies: 6834 208 468 8894
-- Name: bomitemcost_bomitemcost_curr_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY bomitemcost
    ADD CONSTRAINT bomitemcost_bomitemcost_curr_id_fkey FOREIGN KEY (bomitemcost_curr_id) REFERENCES curr_symbol(curr_id);


--
-- TOC entry 7861 (class 2606 OID 146572589)
-- Dependencies: 6810 203 258 8894
-- Name: bomitemsub_bomitemsub_bomitem_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY bomitemsub
    ADD CONSTRAINT bomitemsub_bomitemsub_bomitem_id_fkey FOREIGN KEY (bomitemsub_bomitem_id) REFERENCES bomitem(bomitem_id) ON UPDATE RESTRICT ON DELETE CASCADE;


--
-- TOC entry 7862 (class 2606 OID 146572594)
-- Dependencies: 6751 191 258 8894
-- Name: bomitemsub_bomitemsub_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY bomitemsub
    ADD CONSTRAINT bomitemsub_bomitemsub_item_id_fkey FOREIGN KEY (bomitemsub_item_id) REFERENCES item(item_id) ON UPDATE RESTRICT ON DELETE CASCADE;


--
-- TOC entry 8002 (class 2606 OID 146572599)
-- Dependencies: 6924 236 471 8894
-- Name: bomwork_bomwork_char_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY bomwork
    ADD CONSTRAINT bomwork_bomwork_char_id_fkey FOREIGN KEY (bomwork_char_id) REFERENCES "char"(char_id);


--
-- TOC entry 7865 (class 2606 OID 146572604)
-- Dependencies: 6952 260 263 8894
-- Name: budgitem_budgitem_budghead_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY budgitem
    ADD CONSTRAINT budgitem_budgitem_budghead_id_fkey FOREIGN KEY (budgitem_budghead_id) REFERENCES budghead(budghead_id);


--
-- TOC entry 7866 (class 2606 OID 146572609)
-- Dependencies: 6959 264 263 8894
-- Name: budgitem_budgitem_period_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY budgitem
    ADD CONSTRAINT budgitem_budgitem_period_id_fkey FOREIGN KEY (budgitem_period_id) REFERENCES period(period_id);


--
-- TOC entry 7868 (class 2606 OID 146572614)
-- Dependencies: 6963 266 267 8894
-- Name: cashrcpt_bankaccnt_bankaccnt_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY cashrcpt
    ADD CONSTRAINT cashrcpt_bankaccnt_bankaccnt_id_fkey FOREIGN KEY (cashrcpt_bankaccnt_id) REFERENCES bankaccnt(bankaccnt_id);


--
-- TOC entry 7869 (class 2606 OID 146572619)
-- Dependencies: 6853 213 267 8894
-- Name: cashrcpt_cust_cust_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY cashrcpt
    ADD CONSTRAINT cashrcpt_cust_cust_id_fkey FOREIGN KEY (cashrcpt_cust_id) REFERENCES custinfo(cust_id);


--
-- TOC entry 7870 (class 2606 OID 146572624)
-- Dependencies: 6834 208 267 8894
-- Name: cashrcpt_to_curr_symbol; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY cashrcpt
    ADD CONSTRAINT cashrcpt_to_curr_symbol FOREIGN KEY (cashrcpt_curr_id) REFERENCES curr_symbol(curr_id);




--
-- TOC entry 7875 (class 2606 OID 146572649)
-- Dependencies: 6853 213 278 8894
-- Name: ccard_ccard_cust_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY ccard
    ADD CONSTRAINT ccard_ccard_cust_id_fkey FOREIGN KEY (ccard_cust_id) REFERENCES custinfo(cust_id);



--
-- TOC entry 8004 (class 2606 OID 146572659)
-- Dependencies: 6924 236 490 8894
-- Name: charopt_charopt_char_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY charopt
    ADD CONSTRAINT charopt_charopt_char_id_fkey FOREIGN KEY (charopt_char_id) REFERENCES "char"(char_id) ON DELETE CASCADE;



--
-- TOC entry 7975 (class 2606 OID 146572679)
-- Dependencies: 6828 207 432 8894
-- Name: checkitem_checkitem_apopen_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY checkitem
    ADD CONSTRAINT checkitem_checkitem_apopen_id_fkey FOREIGN KEY (checkitem_apopen_id) REFERENCES apopen(apopen_id);


--
-- TOC entry 7976 (class 2606 OID 146572684)
-- Dependencies: 6849 212 432 8894
-- Name: checkitem_checkitem_aropen_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY checkitem
    ADD CONSTRAINT checkitem_checkitem_aropen_id_fkey FOREIGN KEY (checkitem_aropen_id) REFERENCES aropen(aropen_id);


--
-- TOC entry 7977 (class 2606 OID 146572689)
-- Dependencies: 7204 430 432 8894
-- Name: checkitem_checkitem_checkhead_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY checkitem
    ADD CONSTRAINT checkitem_checkitem_checkhead_id_fkey FOREIGN KEY (checkitem_checkhead_id) REFERENCES checkhead(checkhead_id);


--
-- TOC entry 7978 (class 2606 OID 146572694)
-- Dependencies: 6834 208 432 8894
-- Name: checkitem_checkitem_curr_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY checkitem
    ADD CONSTRAINT checkitem_checkitem_curr_id_fkey FOREIGN KEY (checkitem_curr_id) REFERENCES curr_symbol(curr_id);


--
-- TOC entry 7967 (class 2606 OID 146572699)
-- Dependencies: 7162 397 400 8894
-- Name: cmdarg_cmdarg_cmd_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY cmdarg
    ADD CONSTRAINT cmdarg_cmdarg_cmd_id_fkey FOREIGN KEY (cmdarg_cmd_id) REFERENCES cmd(cmd_id) ON DELETE CASCADE;


--
-- TOC entry 7813 (class 2606 OID 146572704)
-- Dependencies: 6853 213 218 8894
-- Name: cmhead_cmhead_cust_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY cmhead
    ADD CONSTRAINT cmhead_cmhead_cust_id_fkey FOREIGN KEY (cmhead_cust_id) REFERENCES custinfo(cust_id);


--
-- TOC entry 7814 (class 2606 OID 146572709)
-- Dependencies: 6796 199 218 8894
-- Name: cmhead_cmhead_freighttaxtype_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY cmhead
    ADD CONSTRAINT cmhead_cmhead_freighttaxtype_id_fkey FOREIGN KEY (cmhead_freighttaxtype_id) REFERENCES taxtype(taxtype_id);


--
-- TOC entry 7815 (class 2606 OID 146572714)
-- Dependencies: 6891 225 218 8894
-- Name: cmhead_cmhead_prj_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY cmhead
    ADD CONSTRAINT cmhead_cmhead_prj_id_fkey FOREIGN KEY (cmhead_prj_id) REFERENCES prj(prj_id);


--
-- TOC entry 7816 (class 2606 OID 146572719)
-- Dependencies: 6865 216 218 8894
-- Name: cmhead_cmhead_salesrep_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY cmhead
    ADD CONSTRAINT cmhead_cmhead_salesrep_id_fkey FOREIGN KEY (cmhead_salesrep_id) REFERENCES salesrep(salesrep_id);


--
-- TOC entry 7817 (class 2606 OID 146572724)
-- Dependencies: 6895 226 218 8894
-- Name: cmhead_cmhead_saletype_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY cmhead
    ADD CONSTRAINT cmhead_cmhead_saletype_id_fkey FOREIGN KEY (cmhead_saletype_id) REFERENCES saletype(saletype_id);


--
-- TOC entry 7818 (class 2606 OID 146572729)
-- Dependencies: 6897 227 218 8894
-- Name: cmhead_cmhead_shipzone_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY cmhead
    ADD CONSTRAINT cmhead_cmhead_shipzone_id_fkey FOREIGN KEY (cmhead_shipzone_id) REFERENCES shipzone(shipzone_id);


--
-- TOC entry 7819 (class 2606 OID 146572734)
-- Dependencies: 6878 220 218 8894
-- Name: cmhead_cmhead_taxzone_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY cmhead
    ADD CONSTRAINT cmhead_cmhead_taxzone_id_fkey FOREIGN KEY (cmhead_taxzone_id) REFERENCES taxzone(taxzone_id);


--
-- TOC entry 7820 (class 2606 OID 146572739)
-- Dependencies: 6834 208 218 8894
-- Name: cmhead_to_curr_symbol; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY cmhead
    ADD CONSTRAINT cmhead_to_curr_symbol FOREIGN KEY (cmhead_curr_id) REFERENCES curr_symbol(curr_id);


--
-- TOC entry 8005 (class 2606 OID 146572744)
-- Dependencies: 7124 363 497 8894
-- Name: cmheadtax_taxhist_basis_tax_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY cmheadtax
    ADD CONSTRAINT cmheadtax_taxhist_basis_tax_id_fkey FOREIGN KEY (taxhist_basis_tax_id) REFERENCES tax(tax_id);


--
-- TOC entry 8006 (class 2606 OID 146572749)
-- Dependencies: 6872 218 497 8894
-- Name: cmheadtax_taxhist_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY cmheadtax
    ADD CONSTRAINT cmheadtax_taxhist_parent_id_fkey FOREIGN KEY (taxhist_parent_id) REFERENCES cmhead(cmhead_id) ON DELETE CASCADE;


--
-- TOC entry 8007 (class 2606 OID 146572754)
-- Dependencies: 7124 363 497 8894
-- Name: cmheadtax_taxhist_tax_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY cmheadtax
    ADD CONSTRAINT cmheadtax_taxhist_tax_id_fkey FOREIGN KEY (taxhist_tax_id) REFERENCES tax(tax_id);


--
-- TOC entry 8008 (class 2606 OID 146572759)
-- Dependencies: 6796 199 497 8894
-- Name: cmheadtax_taxhist_taxtype_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY cmheadtax
    ADD CONSTRAINT cmheadtax_taxhist_taxtype_id_fkey FOREIGN KEY (taxhist_taxtype_id) REFERENCES taxtype(taxtype_id);



--
-- TOC entry 8009 (class 2606 OID 146572784)
-- Dependencies: 7124 363 499 8894
-- Name: cmitemtax_taxhist_basis_tax_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY cmitemtax
    ADD CONSTRAINT cmitemtax_taxhist_basis_tax_id_fkey FOREIGN KEY (taxhist_basis_tax_id) REFERENCES tax(tax_id);


--
-- TOC entry 8010 (class 2606 OID 146572789)
-- Dependencies: 6884 222 499 8894
-- Name: cmitemtax_taxhist_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY cmitemtax
    ADD CONSTRAINT cmitemtax_taxhist_parent_id_fkey FOREIGN KEY (taxhist_parent_id) REFERENCES cmitem(cmitem_id) ON DELETE CASCADE;


--
-- TOC entry 8011 (class 2606 OID 146572794)
-- Dependencies: 7124 363 499 8894
-- Name: cmitemtax_taxhist_tax_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY cmitemtax
    ADD CONSTRAINT cmitemtax_taxhist_tax_id_fkey FOREIGN KEY (taxhist_tax_id) REFERENCES tax(tax_id);


--
-- TOC entry 8012 (class 2606 OID 146572799)
-- Dependencies: 6796 199 499 8894
-- Name: cmitemtax_taxhist_taxtype_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY cmitemtax
    ADD CONSTRAINT cmitemtax_taxhist_taxtype_id_fkey FOREIGN KEY (taxhist_taxtype_id) REFERENCES taxtype(taxtype_id);



--
-- TOC entry 8013 (class 2606 OID 146572814)
-- Dependencies: 6920 234 504 8894
-- Name: cntctaddr_cntctaddr_addr_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY cntctaddr
    ADD CONSTRAINT cntctaddr_cntctaddr_addr_id_fkey FOREIGN KEY (cntctaddr_addr_id) REFERENCES addr(addr_id);


--
-- TOC entry 8014 (class 2606 OID 146572819)
-- Dependencies: 6816 204 504 8894
-- Name: cntctaddr_cntctaddr_cntct_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY cntctaddr
    ADD CONSTRAINT cntctaddr_cntctaddr_cntct_id_fkey FOREIGN KEY (cntctaddr_cntct_id) REFERENCES cntct(cntct_id) ON DELETE CASCADE;


--
-- TOC entry 8015 (class 2606 OID 146572824)
-- Dependencies: 6816 204 506 8894
-- Name: cntctdata_cntctdata_cntct_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY cntctdata
    ADD CONSTRAINT cntctdata_cntctdata_cntct_id_fkey FOREIGN KEY (cntctdata_cntct_id) REFERENCES cntct(cntct_id) ON DELETE CASCADE;


--
-- TOC entry 8016 (class 2606 OID 146572829)
-- Dependencies: 6816 204 508 8894
-- Name: cntcteml_cntcteml_cntct_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY cntcteml
    ADD CONSTRAINT cntcteml_cntcteml_cntct_id_fkey FOREIGN KEY (cntcteml_cntct_id) REFERENCES cntct(cntct_id) ON DELETE CASCADE;


--
-- TOC entry 8017 (class 2606 OID 146572834)
-- Dependencies: 6816 204 510 8894
-- Name: cntctmrgd_cntctmrgd_cntct_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY cntctmrgd
    ADD CONSTRAINT cntctmrgd_cntctmrgd_cntct_id_fkey FOREIGN KEY (cntctmrgd_cntct_id) REFERENCES cntct(cntct_id) ON DELETE CASCADE;


--
-- TOC entry 8018 (class 2606 OID 146572839)
-- Dependencies: 6816 204 511 8894
-- Name: cntctsel_cntctsel_cntct_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY cntctsel
    ADD CONSTRAINT cntctsel_cntctsel_cntct_id_fkey FOREIGN KEY (cntctsel_cntct_id) REFERENCES cntct(cntct_id) ON DELETE CASCADE;


--
-- TOC entry 8019 (class 2606 OID 146572844)
-- Dependencies: 6905 229 513 8894
-- Name: cobill_cobill_invcitem_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY cobill
    ADD CONSTRAINT cobill_cobill_invcitem_id_fkey FOREIGN KEY (cobill_invcitem_id) REFERENCES invcitem(invcitem_id);


--
-- TOC entry 8020 (class 2606 OID 146572849)
-- Dependencies: 6796 199 513 8894
-- Name: cobill_cobill_taxtype_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY cobill
    ADD CONSTRAINT cobill_cobill_taxtype_id_fkey FOREIGN KEY (cobill_taxtype_id) REFERENCES taxtype(taxtype_id);


--
-- TOC entry 8021 (class 2606 OID 146572854)
-- Dependencies: 7124 363 515 8894
-- Name: cobilltax_taxhist_basis_tax_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY cobilltax
    ADD CONSTRAINT cobilltax_taxhist_basis_tax_id_fkey FOREIGN KEY (taxhist_basis_tax_id) REFERENCES tax(tax_id);


--
-- TOC entry 8022 (class 2606 OID 146572859)
-- Dependencies: 7288 513 515 8894
-- Name: cobilltax_taxhist_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY cobilltax
    ADD CONSTRAINT cobilltax_taxhist_parent_id_fkey FOREIGN KEY (taxhist_parent_id) REFERENCES cobill(cobill_id) ON DELETE CASCADE;


--
-- TOC entry 8023 (class 2606 OID 146572864)
-- Dependencies: 7124 363 515 8894
-- Name: cobilltax_taxhist_tax_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY cobilltax
    ADD CONSTRAINT cobilltax_taxhist_tax_id_fkey FOREIGN KEY (taxhist_tax_id) REFERENCES tax(tax_id);


--
-- TOC entry 8024 (class 2606 OID 146572869)
-- Dependencies: 6796 199 515 8894
-- Name: cobilltax_taxhist_taxtype_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY cobilltax
    ADD CONSTRAINT cobilltax_taxhist_taxtype_id_fkey FOREIGN KEY (taxhist_taxtype_id) REFERENCES taxtype(taxtype_id);


--
-- TOC entry 8025 (class 2606 OID 146572874)
-- Dependencies: 6889 224 516 8894
-- Name: cobmisc_cobmisc_invchead_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY cobmisc
    ADD CONSTRAINT cobmisc_cobmisc_invchead_id_fkey FOREIGN KEY (cobmisc_invchead_id) REFERENCES invchead(invchead_id);


--
-- TOC entry 8026 (class 2606 OID 146572879)
-- Dependencies: 6796 199 516 8894
-- Name: cobmisc_cobmisc_taxtype_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY cobmisc
    ADD CONSTRAINT cobmisc_cobmisc_taxtype_id_fkey FOREIGN KEY (cobmisc_taxtype_id) REFERENCES taxtype(taxtype_id);


--
-- TOC entry 8027 (class 2606 OID 146572884)
-- Dependencies: 6878 220 516 8894
-- Name: cobmisc_cobmisc_taxzone_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY cobmisc
    ADD CONSTRAINT cobmisc_cobmisc_taxzone_id_fkey FOREIGN KEY (cobmisc_taxzone_id) REFERENCES taxzone(taxzone_id);


--
-- TOC entry 8028 (class 2606 OID 146572889)
-- Dependencies: 6834 208 516 8894
-- Name: cobmisc_to_curr_symbol; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY cobmisc
    ADD CONSTRAINT cobmisc_to_curr_symbol FOREIGN KEY (cobmisc_curr_id) REFERENCES curr_symbol(curr_id);


--
-- TOC entry 8029 (class 2606 OID 146572894)
-- Dependencies: 7124 363 518 8894
-- Name: cobmisctax_taxhist_basis_tax_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY cobmisctax
    ADD CONSTRAINT cobmisctax_taxhist_basis_tax_id_fkey FOREIGN KEY (taxhist_basis_tax_id) REFERENCES tax(tax_id);


--
-- TOC entry 8030 (class 2606 OID 146572899)
-- Dependencies: 7293 516 518 8894
-- Name: cobmisctax_taxhist_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY cobmisctax
    ADD CONSTRAINT cobmisctax_taxhist_parent_id_fkey FOREIGN KEY (taxhist_parent_id) REFERENCES cobmisc(cobmisc_id) ON DELETE CASCADE;


--
-- TOC entry 8031 (class 2606 OID 146572904)
-- Dependencies: 7124 363 518 8894
-- Name: cobmisctax_taxhist_tax_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY cobmisctax
    ADD CONSTRAINT cobmisctax_taxhist_tax_id_fkey FOREIGN KEY (taxhist_tax_id) REFERENCES tax(tax_id);


--
-- TOC entry 8032 (class 2606 OID 146572909)
-- Dependencies: 6796 199 518 8894
-- Name: cobmisctax_taxhist_taxtype_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY cobmisctax
    ADD CONSTRAINT cobmisctax_taxhist_taxtype_id_fkey FOREIGN KEY (taxhist_taxtype_id) REFERENCES taxtype(taxtype_id);

ALTER TABLE ONLY cohist
    ADD CONSTRAINT cohist_pkey PRIMARY KEY (cohist_id);

--
-- TOC entry 7963 (class 2606 OID 146573024)
-- Dependencies: 7124 363 379 8894
-- Name: cohisttax_taxhist_basis_tax_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY cohisttax
    ADD CONSTRAINT cohisttax_taxhist_basis_tax_id_fkey FOREIGN KEY (taxhist_basis_tax_id) REFERENCES tax(tax_id);


--
-- TOC entry 7964 (class 2606 OID 146573029)
-- Dependencies: 7142 376 379 8894
-- Name: cohisttax_taxhist_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY cohisttax
    ADD CONSTRAINT cohisttax_taxhist_parent_id_fkey FOREIGN KEY (taxhist_parent_id) REFERENCES cohist(cohist_id) ON DELETE CASCADE;


--
-- TOC entry 7965 (class 2606 OID 146573034)
-- Dependencies: 7124 363 379 8894
-- Name: cohisttax_taxhist_tax_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY cohisttax
    ADD CONSTRAINT cohisttax_taxhist_tax_id_fkey FOREIGN KEY (taxhist_tax_id) REFERENCES tax(tax_id);


--
-- TOC entry 7966 (class 2606 OID 146573039)
-- Dependencies: 6796 199 379 8894
-- Name: cohisttax_taxhist_taxtype_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY cohisttax
    ADD CONSTRAINT cohisttax_taxhist_taxtype_id_fkey FOREIGN KEY (taxhist_taxtype_id) REFERENCES taxtype(taxtype_id);



--
-- TOC entry 7859 (class 2606 OID 146573084)
-- Dependencies: 6931 239 240 8894
-- Name: comment_comment_cmnttype_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY comment
    ADD CONSTRAINT comment_comment_cmnttype_id_fkey FOREIGN KEY (comment_cmnttype_id) REFERENCES cmnttype(cmnttype_id);



--
-- TOC entry 7902 (class 2606 OID 146573114)
-- Dependencies: 6841 210 329 8894
-- Name: contrct_contrct_vend_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY contrct
    ADD CONSTRAINT contrct_contrct_vend_id_fkey FOREIGN KEY (contrct_vend_id) REFERENCES vendinfo(vend_id);


--
-- TOC entry 8044 (class 2606 OID 146573119)
-- Dependencies: 6834 208 535 8894
-- Name: costhist_new_to_curr_symbol; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY costhist
    ADD CONSTRAINT costhist_new_to_curr_symbol FOREIGN KEY (costhist_newcurr_id) REFERENCES curr_symbol(curr_id);


--
-- TOC entry 8045 (class 2606 OID 146573124)
-- Dependencies: 6834 208 535 8894
-- Name: costhist_old_to_curr_symbol; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY costhist
    ADD CONSTRAINT costhist_old_to_curr_symbol FOREIGN KEY (costhist_oldcurr_id) REFERENCES curr_symbol(curr_id);



--
-- TOC entry 8046 (class 2606 OID 146573174)
-- Dependencies: 6820 205 544 8894
-- Name: crmacctsel_crmacctsel_dest_crmacct_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY crmacctsel
    ADD CONSTRAINT crmacctsel_crmacctsel_dest_crmacct_id_fkey FOREIGN KEY (crmacctsel_dest_crmacct_id) REFERENCES crmacct(crmacct_id) ON DELETE CASCADE;


--
-- TOC entry 8047 (class 2606 OID 146573179)
-- Dependencies: 6820 205 544 8894
-- Name: crmacctsel_crmacctsel_src_crmacct_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY crmacctsel
    ADD CONSTRAINT crmacctsel_crmacctsel_src_crmacct_id_fkey FOREIGN KEY (crmacctsel_src_crmacct_id) REFERENCES crmacct(crmacct_id) ON DELETE CASCADE;


--
-- TOC entry 8050 (class 2606 OID 146573269)
-- Dependencies: 7002 292 565 8894
-- Name: empgrpitem_empgrpitem_emp_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY empgrpitem
    ADD CONSTRAINT empgrpitem_empgrpitem_emp_id_fkey FOREIGN KEY (empgrpitem_emp_id) REFERENCES emp(emp_id);


--
-- TOC entry 8051 (class 2606 OID 146573274)
-- Dependencies: 7350 563 565 8894
-- Name: empgrpitem_empgrpitem_empgrp_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY empgrpitem
    ADD CONSTRAINT empgrpitem_empgrpitem_empgrp_id_fkey FOREIGN KEY (empgrpitem_empgrp_id) REFERENCES empgrp(empgrp_id);


--
-- TOC entry 8052 (class 2606 OID 146573279)
-- Dependencies: 7373 579 588 8894
-- Name: flnotes_flnotes_flhead_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY flnotes
    ADD CONSTRAINT flnotes_flnotes_flhead_id_fkey FOREIGN KEY (flnotes_flhead_id) REFERENCES flhead(flhead_id) ON DELETE CASCADE;


--
-- TOC entry 8053 (class 2606 OID 146573284)
-- Dependencies: 6959 264 588 8894
-- Name: flnotes_flnotes_period_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY flnotes
    ADD CONSTRAINT flnotes_flnotes_period_id_fkey FOREIGN KEY (flnotes_period_id) REFERENCES period(period_id) ON DELETE CASCADE;


--
-- TOC entry 8054 (class 2606 OID 146573289)
-- Dependencies: 7395 601 603 8894
-- Name: grppriv_grppriv_grp_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY grppriv
    ADD CONSTRAINT grppriv_grppriv_grp_id_fkey FOREIGN KEY (grppriv_grp_id) REFERENCES grp(grp_id);



--
-- TOC entry 8055 (class 2606 OID 146573344)
-- Dependencies: 6824 206 609 8894
-- Name: incdthist_incdthist_incdt_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY incdthist
    ADD CONSTRAINT incdthist_incdthist_incdt_id_fkey FOREIGN KEY (incdthist_incdt_id) REFERENCES incdt(incdt_id);


--
-- TOC entry 7765 (class 2606 OID 146573349)
-- Dependencies: 6758 192 202 8894
-- Name: invbal_invbal_itemsite_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY invbal
    ADD CONSTRAINT invbal_invbal_itemsite_id_fkey FOREIGN KEY (invbal_itemsite_id) REFERENCES itemsite(itemsite_id) ON DELETE CASCADE;


--
-- TOC entry 7766 (class 2606 OID 146573354)
-- Dependencies: 6959 264 202 8894
-- Name: invbal_invbal_period_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY invbal
    ADD CONSTRAINT invbal_invbal_period_id_fkey FOREIGN KEY (invbal_period_id) REFERENCES period(period_id) ON DELETE CASCADE;


--
-- TOC entry 8056 (class 2606 OID 146573379)
-- Dependencies: 7124 363 617 8894
-- Name: invcheadtax_taxhist_basis_tax_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY invcheadtax
    ADD CONSTRAINT invcheadtax_taxhist_basis_tax_id_fkey FOREIGN KEY (taxhist_basis_tax_id) REFERENCES tax(tax_id);


--
-- TOC entry 8057 (class 2606 OID 146573384)
-- Dependencies: 6889 224 617 8894
-- Name: invcheadtax_taxhist_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY invcheadtax
    ADD CONSTRAINT invcheadtax_taxhist_parent_id_fkey FOREIGN KEY (taxhist_parent_id) REFERENCES invchead(invchead_id) ON DELETE CASCADE;


--
-- TOC entry 8058 (class 2606 OID 146573389)
-- Dependencies: 7124 363 617 8894
-- Name: invcheadtax_taxhist_tax_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY invcheadtax
    ADD CONSTRAINT invcheadtax_taxhist_tax_id_fkey FOREIGN KEY (taxhist_tax_id) REFERENCES tax(tax_id);


--
-- TOC entry 8059 (class 2606 OID 146573394)
-- Dependencies: 6796 199 617 8894
-- Name: invcheadtax_taxhist_taxtype_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY invcheadtax
    ADD CONSTRAINT invcheadtax_taxhist_taxtype_id_fkey FOREIGN KEY (taxhist_taxtype_id) REFERENCES taxtype(taxtype_id);



--
-- TOC entry 8060 (class 2606 OID 146573424)
-- Dependencies: 7124 363 619 8894
-- Name: invcitemtax_taxhist_basis_tax_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY invcitemtax
    ADD CONSTRAINT invcitemtax_taxhist_basis_tax_id_fkey FOREIGN KEY (taxhist_basis_tax_id) REFERENCES tax(tax_id);


--
-- TOC entry 8061 (class 2606 OID 146573429)
-- Dependencies: 6905 229 619 8894
-- Name: invcitemtax_taxhist_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY invcitemtax
    ADD CONSTRAINT invcitemtax_taxhist_parent_id_fkey FOREIGN KEY (taxhist_parent_id) REFERENCES invcitem(invcitem_id) ON DELETE CASCADE;


--
-- TOC entry 8062 (class 2606 OID 146573434)
-- Dependencies: 7124 363 619 8894
-- Name: invcitemtax_taxhist_tax_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY invcitemtax
    ADD CONSTRAINT invcitemtax_taxhist_tax_id_fkey FOREIGN KEY (taxhist_tax_id) REFERENCES tax(tax_id);


--
-- TOC entry 8063 (class 2606 OID 146573439)
-- Dependencies: 6796 199 619 8894
-- Name: invcitemtax_taxhist_taxtype_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY invcitemtax
    ADD CONSTRAINT invcitemtax_taxhist_taxtype_id_fkey FOREIGN KEY (taxhist_taxtype_id) REFERENCES taxtype(taxtype_id);


--
-- TOC entry 8064 (class 2606 OID 146573444)
-- Dependencies: 7118 358 625 8894
-- Name: invhistexpcat_invhistexpcat_expcat_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY invhistexpcat
    ADD CONSTRAINT invhistexpcat_invhistexpcat_expcat_id_fkey FOREIGN KEY (invhistexpcat_expcat_id) REFERENCES expcat(expcat_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 8065 (class 2606 OID 146573449)
-- Dependencies: 7417 623 625 8894
-- Name: invhistexpcat_invhistexpcat_invhist_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY invhistexpcat
    ADD CONSTRAINT invhistexpcat_invhistexpcat_invhist_id_fkey FOREIGN KEY (invhistexpcat_invhist_id) REFERENCES invhist(invhist_id) ON UPDATE CASCADE ON DELETE CASCADE;



--
-- TOC entry 7891 (class 2606 OID 146573459)
-- Dependencies: 7011 299 300 8894
-- Name: ipsfreight_ipsfreight_freightclass_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY ipsfreight
    ADD CONSTRAINT ipsfreight_ipsfreight_freightclass_id_fkey FOREIGN KEY (ipsfreight_freightclass_id) REFERENCES freightclass(freightclass_id);


--
-- TOC entry 7892 (class 2606 OID 146573464)
-- Dependencies: 7017 301 300 8894
-- Name: ipsfreight_ipsfreight_ipshead_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY ipsfreight
    ADD CONSTRAINT ipsfreight_ipsfreight_ipshead_id_fkey FOREIGN KEY (ipsfreight_ipshead_id) REFERENCES ipshead(ipshead_id);


--
-- TOC entry 7893 (class 2606 OID 146573469)
-- Dependencies: 6897 227 300 8894
-- Name: ipsfreight_ipsfreight_shipzone_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY ipsfreight
    ADD CONSTRAINT ipsfreight_ipsfreight_shipzone_id_fkey FOREIGN KEY (ipsfreight_shipzone_id) REFERENCES shipzone(shipzone_id);


--
-- TOC entry 7894 (class 2606 OID 146573474)
-- Dependencies: 6763 193 300 8894
-- Name: ipsfreight_ipsfreight_warehous_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY ipsfreight
    ADD CONSTRAINT ipsfreight_ipsfreight_warehous_id_fkey FOREIGN KEY (ipsfreight_warehous_id) REFERENCES whsinfo(warehous_id);


--
-- TOC entry 7917 (class 2606 OID 146573484)
-- Dependencies: 7017 301 349 8894
-- Name: ipsitem_ipshead_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY ipsiteminfo
    ADD CONSTRAINT ipsitem_ipshead_id_fk FOREIGN KEY (ipsitem_ipshead_id) REFERENCES ipshead(ipshead_id) ON DELETE CASCADE;


--
-- TOC entry 7918 (class 2606 OID 146573489)
-- Dependencies: 6800 200 349 8894
-- Name: ipsitem_ipsitem_price_uom_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY ipsiteminfo
    ADD CONSTRAINT ipsitem_ipsitem_price_uom_id_fkey FOREIGN KEY (ipsitem_price_uom_id) REFERENCES uom(uom_id);


--
-- TOC entry 7919 (class 2606 OID 146573494)
-- Dependencies: 6800 200 349 8894
-- Name: ipsitem_ipsitem_qty_uom_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY ipsiteminfo
    ADD CONSTRAINT ipsitem_ipsitem_qty_uom_id_fkey FOREIGN KEY (ipsitem_qty_uom_id) REFERENCES uom(uom_id);


--
-- TOC entry 7920 (class 2606 OID 146573499)
-- Dependencies: 6763 193 349 8894
-- Name: ipsitem_ipsitem_warehous_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY ipsiteminfo
    ADD CONSTRAINT ipsitem_ipsitem_warehous_id_fkey FOREIGN KEY (ipsitem_warehous_id) REFERENCES whsinfo(warehous_id);


--
-- TOC entry 7921 (class 2606 OID 146573504)
-- Dependencies: 6751 191 349 8894
-- Name: ipsitem_item_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY ipsiteminfo
    ADD CONSTRAINT ipsitem_item_id_fk FOREIGN KEY (ipsitem_item_id) REFERENCES item(item_id);


--
-- TOC entry 7922 (class 2606 OID 146573509)
-- Dependencies: 6924 236 351 8894
-- Name: ipsitemchar_ipsitemchar_char_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY ipsitemchar
    ADD CONSTRAINT ipsitemchar_ipsitemchar_char_id_fkey FOREIGN KEY (ipsitemchar_char_id) REFERENCES "char"(char_id);


--
-- TOC entry 7923 (class 2606 OID 146573514)
-- Dependencies: 7104 349 351 8894
-- Name: ipsitemchar_ipsitemchar_ipsitem_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY ipsitemchar
    ADD CONSTRAINT ipsitemchar_ipsitemchar_ipsitem_id_fkey FOREIGN KEY (ipsitemchar_ipsitem_id) REFERENCES ipsiteminfo(ipsitem_id) ON DELETE CASCADE;



--
-- TOC entry 7898 (class 2606 OID 146573549)
-- Dependencies: 7049 320 321 8894
-- Name: itemcost_itemcost_costelem_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY itemcost
    ADD CONSTRAINT itemcost_itemcost_costelem_id_fkey FOREIGN KEY (itemcost_costelem_id) REFERENCES costelem(costelem_id);


--
-- TOC entry 7899 (class 2606 OID 146573554)
-- Dependencies: 6834 208 321 8894
-- Name: itemcost_itemcost_curr_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY itemcost
    ADD CONSTRAINT itemcost_itemcost_curr_id_fkey FOREIGN KEY (itemcost_curr_id) REFERENCES curr_symbol(curr_id);


--
-- TOC entry 7900 (class 2606 OID 146573559)
-- Dependencies: 6751 191 321 8894
-- Name: itemcost_itemcost_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY itemcost
    ADD CONSTRAINT itemcost_itemcost_item_id_fkey FOREIGN KEY (itemcost_item_id) REFERENCES item(item_id);


--
-- TOC entry 7901 (class 2606 OID 146573564)
-- Dependencies: 6834 208 321 8894
-- Name: itemcost_to_curr_symbol; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY itemcost
    ADD CONSTRAINT itemcost_to_curr_symbol FOREIGN KEY (itemcost_curr_id) REFERENCES curr_symbol(curr_id);


--
-- TOC entry 7903 (class 2606 OID 146573589)
-- Dependencies: 7064 329 330 8894
-- Name: itemsrc_itemsrc_contrct_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY itemsrc
    ADD CONSTRAINT itemsrc_itemsrc_contrct_id_fkey FOREIGN KEY (itemsrc_contrct_id) REFERENCES contrct(contrct_id);


--
-- TOC entry 7904 (class 2606 OID 146573594)
-- Dependencies: 6751 191 330 8894
-- Name: itemsrc_itemsrc_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY itemsrc
    ADD CONSTRAINT itemsrc_itemsrc_item_id_fkey FOREIGN KEY (itemsrc_item_id) REFERENCES item(item_id) ON DELETE CASCADE;


--
-- TOC entry 7905 (class 2606 OID 146573599)
-- Dependencies: 6841 210 330 8894
-- Name: itemsrc_itemsrc_vend_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY itemsrc
    ADD CONSTRAINT itemsrc_itemsrc_vend_id_fkey FOREIGN KEY (itemsrc_vend_id) REFERENCES vendinfo(vend_id) ON DELETE CASCADE;


--
-- TOC entry 7906 (class 2606 OID 146573604)
-- Dependencies: 7068 330 332 8894
-- Name: itemsrcp_itemsrcp_itemsrc_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY itemsrcp
    ADD CONSTRAINT itemsrcp_itemsrcp_itemsrc_id_fkey FOREIGN KEY (itemsrcp_itemsrc_id) REFERENCES itemsrc(itemsrc_id) ON DELETE CASCADE;


--
-- TOC entry 7907 (class 2606 OID 146573609)
-- Dependencies: 6834 208 332 8894
-- Name: itemsrcp_to_curr_symbol; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY itemsrcp
    ADD CONSTRAINT itemsrcp_to_curr_symbol FOREIGN KEY (itemsrcp_curr_id) REFERENCES curr_symbol(curr_id);


--
-- TOC entry 7908 (class 2606 OID 146573614)
-- Dependencies: 6751 191 334 8894
-- Name: itemsub_itemsub_parent_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY itemsub
    ADD CONSTRAINT itemsub_itemsub_parent_item_id_fkey FOREIGN KEY (itemsub_parent_item_id) REFERENCES item(item_id);


--
-- TOC entry 7909 (class 2606 OID 146573619)
-- Dependencies: 6751 191 334 8894
-- Name: itemsub_itemsub_sub_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY itemsub
    ADD CONSTRAINT itemsub_itemsub_sub_item_id_fkey FOREIGN KEY (itemsub_sub_item_id) REFERENCES item(item_id);


--
-- TOC entry 7910 (class 2606 OID 146573624)
-- Dependencies: 6751 191 336 8894
-- Name: itemtax_itemtax_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY itemtax
    ADD CONSTRAINT itemtax_itemtax_item_id_fkey FOREIGN KEY (itemtax_item_id) REFERENCES item(item_id);


--
-- TOC entry 7911 (class 2606 OID 146573629)
-- Dependencies: 6796 199 336 8894
-- Name: itemtax_itemtax_taxtype_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY itemtax
    ADD CONSTRAINT itemtax_itemtax_taxtype_id_fkey FOREIGN KEY (itemtax_taxtype_id) REFERENCES taxtype(taxtype_id);


--
-- TOC entry 7912 (class 2606 OID 146573634)
-- Dependencies: 6878 220 336 8894
-- Name: itemtax_itemtax_taxzone_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY itemtax
    ADD CONSTRAINT itemtax_itemtax_taxzone_id_fkey FOREIGN KEY (itemtax_taxzone_id) REFERENCES taxzone(taxzone_id);


--
-- TOC entry 8066 (class 2606 OID 146573639)
-- Dependencies: 6751 191 662 8894
-- Name: itemtrans_itemtrans_source_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY itemtrans
    ADD CONSTRAINT itemtrans_itemtrans_source_item_id_fkey FOREIGN KEY (itemtrans_source_item_id) REFERENCES item(item_id);


--
-- TOC entry 8067 (class 2606 OID 146573644)
-- Dependencies: 6751 191 662 8894
-- Name: itemtrans_itemtrans_target_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY itemtrans
    ADD CONSTRAINT itemtrans_itemtrans_target_item_id_fkey FOREIGN KEY (itemtrans_target_item_id) REFERENCES item(item_id);


--
-- TOC entry 8068 (class 2606 OID 146573649)
-- Dependencies: 7084 338 664 8894
-- Name: itemuom_itemuom_itemuomconv_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY itemuom
    ADD CONSTRAINT itemuom_itemuom_itemuomconv_id_fkey FOREIGN KEY (itemuom_itemuomconv_id) REFERENCES itemuomconv(itemuomconv_id);


--
-- TOC entry 8069 (class 2606 OID 146573654)
-- Dependencies: 7629 822 664 8894
-- Name: itemuom_itemuom_uomtype_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY itemuom
    ADD CONSTRAINT itemuom_itemuom_uomtype_id_fkey FOREIGN KEY (itemuom_uomtype_id) REFERENCES uomtype(uomtype_id);



--
-- TOC entry 8070 (class 2606 OID 146573674)
-- Dependencies: 6816 204 687 8894
-- Name: mrghist_mrghist_cntct_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY mrghist
    ADD CONSTRAINT mrghist_mrghist_cntct_id_fkey FOREIGN KEY (mrghist_cntct_id) REFERENCES cntct(cntct_id) ON DELETE CASCADE;


--
-- TOC entry 8088 (class 2606 OID 146573874)
-- Dependencies: 7541 742 744 8894
-- Name: qryitem_qryitem_qryhead_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY qryitem
    ADD CONSTRAINT qryitem_qryitem_qryhead_id_fkey FOREIGN KEY (qryitem_qryhead_id) REFERENCES qryhead(qryhead_id);


--
-- TOC entry 8077 (class 2606 OID 146573969)
-- Dependencies: 6834 208 721 8894
-- Name: recv_recv_freight_curr_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY recv
    ADD CONSTRAINT recv_recv_freight_curr_id_fkey FOREIGN KEY (recv_freight_curr_id) REFERENCES curr_symbol(curr_id);


--
-- TOC entry 8078 (class 2606 OID 146573974)
-- Dependencies: 6758 192 721 8894
-- Name: recv_recv_itemsite_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY recv
    ADD CONSTRAINT recv_recv_itemsite_id_fkey FOREIGN KEY (recv_itemsite_id) REFERENCES itemsite(itemsite_id);


--
-- TOC entry 8079 (class 2606 OID 146573979)
-- Dependencies: 6834 208 721 8894
-- Name: recv_recv_purchcost_curr_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY recv
    ADD CONSTRAINT recv_recv_purchcost_curr_id_fkey FOREIGN KEY (recv_purchcost_curr_id) REFERENCES curr_symbol(curr_id);


--
-- TOC entry 8080 (class 2606 OID 146573984)
-- Dependencies: 6834 208 721 8894
-- Name: recv_recv_recvcost_curr_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY recv
    ADD CONSTRAINT recv_recv_recvcost_curr_id_fkey FOREIGN KEY (recv_recvcost_curr_id) REFERENCES curr_symbol(curr_id);


--
-- TOC entry 8081 (class 2606 OID 146573989)
-- Dependencies: 7519 721 721 8894
-- Name: recv_recv_splitfrom_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY recv
    ADD CONSTRAINT recv_recv_splitfrom_id_fkey FOREIGN KEY (recv_splitfrom_id) REFERENCES recv(recv_id);


--
-- TOC entry 8082 (class 2606 OID 146573994)
-- Dependencies: 6841 210 721 8894
-- Name: recv_recv_vend_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY recv
    ADD CONSTRAINT recv_recv_vend_id_fkey FOREIGN KEY (recv_vend_id) REFERENCES vendinfo(vend_id);


--
-- TOC entry 8083 (class 2606 OID 146573999)
-- Dependencies: 7642 839 721 8894
-- Name: recv_recv_vohead_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY recv
    ADD CONSTRAINT recv_recv_vohead_id_fkey FOREIGN KEY (recv_vohead_id) REFERENCES vohead(vohead_id);


--
-- TOC entry 8084 (class 2606 OID 146574004)
-- Dependencies: 7648 842 721 8894
-- Name: recv_recv_voitem_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY recv
    ADD CONSTRAINT recv_recv_voitem_id_fkey FOREIGN KEY (recv_voitem_id) REFERENCES voitem(voitem_id);



--
-- TOC entry 7888 (class 2606 OID 146574014)
-- Dependencies: 6834 208 297 8894
-- Name: shipdata_shipdata_base_freight_curr_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY shipdata
    ADD CONSTRAINT shipdata_shipdata_base_freight_curr_id_fkey FOREIGN KEY (shipdata_base_freight_curr_id) REFERENCES curr_symbol(curr_id);


--
-- TOC entry 7889 (class 2606 OID 146574019)
-- Dependencies: 7305 526 297 8894
-- Name: shipdata_shipdata_shiphead_number_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY shipdata
    ADD CONSTRAINT shipdata_shipdata_shiphead_number_fkey FOREIGN KEY (shipdata_shiphead_number) REFERENCES shiphead(shiphead_number);


--
-- TOC entry 7890 (class 2606 OID 146574024)
-- Dependencies: 6834 208 297 8894
-- Name: shipdata_shipdata_total_freight_curr_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY shipdata
    ADD CONSTRAINT shipdata_shipdata_total_freight_curr_id_fkey FOREIGN KEY (shipdata_total_freight_curr_id) REFERENCES curr_symbol(curr_id);


--
-- TOC entry 8089 (class 2606 OID 146574029)
-- Dependencies: 6834 208 771 8894
-- Name: shipdatasum_shipdatasum_base_freight_curr_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY shipdatasum
    ADD CONSTRAINT shipdatasum_shipdatasum_base_freight_curr_id_fkey FOREIGN KEY (shipdatasum_base_freight_curr_id) REFERENCES curr_symbol(curr_id);


--
-- TOC entry 8090 (class 2606 OID 146574034)
-- Dependencies: 7305 526 771 8894
-- Name: shipdatasum_shipdatasum_shiphead_number_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY shipdatasum
    ADD CONSTRAINT shipdatasum_shipdatasum_shiphead_number_fkey FOREIGN KEY (shipdatasum_shiphead_number) REFERENCES shiphead(shiphead_number);


--
-- TOC entry 8091 (class 2606 OID 146574039)
-- Dependencies: 6834 208 771 8894
-- Name: shipdatasum_shipdatasum_total_freight_curr_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY shipdatasum
    ADD CONSTRAINT shipdatasum_shipdatasum_total_freight_curr_id_fkey FOREIGN KEY (shipdatasum_total_freight_curr_id) REFERENCES curr_symbol(curr_id);



--
-- TOC entry 8041 (class 2606 OID 146574059)
-- Dependencies: 6905 229 527 8894
-- Name: shipitem_shipitem_invcitem_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY shipitem
    ADD CONSTRAINT shipitem_shipitem_invcitem_id_fkey FOREIGN KEY (shipitem_invcitem_id) REFERENCES invcitem(invcitem_id);


--
-- TOC entry 8042 (class 2606 OID 146574064)
-- Dependencies: 7417 623 527 8894
-- Name: shipitem_shipitem_invhist_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY shipitem
    ADD CONSTRAINT shipitem_shipitem_invhist_id_fkey FOREIGN KEY (shipitem_invhist_id) REFERENCES invhist(invhist_id);


--
-- TOC entry 8043 (class 2606 OID 146574069)
-- Dependencies: 7303 526 527 8894
-- Name: shipitem_shipitem_shiphead_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY shipitem
    ADD CONSTRAINT shipitem_shipitem_shiphead_id_fkey FOREIGN KEY (shipitem_shiphead_id) REFERENCES shiphead(shiphead_id);


--
-- TOC entry 8092 (class 2606 OID 146574119)
-- Dependencies: 7321 538 787 8894
-- Name: state_state_country_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY state
    ADD CONSTRAINT state_state_country_id_fkey FOREIGN KEY (state_country_id) REFERENCES country(country_id);


--
-- TOC entry 8096 (class 2606 OID 146574189)
-- Dependencies: 6834 208 809 8894
-- Name: taxrate_taxrate_curr_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY taxrate
    ADD CONSTRAINT taxrate_taxrate_curr_id_fkey FOREIGN KEY (taxrate_curr_id) REFERENCES curr_symbol(curr_id);


--
-- TOC entry 8097 (class 2606 OID 146574194)
-- Dependencies: 7124 363 809 8894
-- Name: taxrate_taxrate_tax_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY taxrate
    ADD CONSTRAINT taxrate_taxrate_tax_id_fkey FOREIGN KEY (taxrate_tax_id) REFERENCES tax(tax_id);


--
-- TOC entry 7879 (class 2606 OID 146574199)
-- Dependencies: 6988 284 285 8894
-- Name: taxreg_taxreg_taxauth_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY taxreg
    ADD CONSTRAINT taxreg_taxreg_taxauth_id_fkey FOREIGN KEY (taxreg_taxauth_id) REFERENCES taxauth(taxauth_id);


--
-- TOC entry 7880 (class 2606 OID 146574204)
-- Dependencies: 6878 220 285 8894
-- Name: taxreg_taxreg_taxzone_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY taxreg
    ADD CONSTRAINT taxreg_taxreg_taxzone_id_fkey FOREIGN KEY (taxreg_taxzone_id) REFERENCES taxzone(taxzone_id);


--
-- TOC entry 7854 (class 2606 OID 146574209)
-- Dependencies: 6816 204 233 8894
-- Name: todoitem_todoitem_cntct_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY todoitem
    ADD CONSTRAINT todoitem_todoitem_cntct_id_fkey FOREIGN KEY (todoitem_cntct_id) REFERENCES cntct(cntct_id);


--
-- TOC entry 7855 (class 2606 OID 146574214)
-- Dependencies: 6820 205 233 8894
-- Name: todoitem_todoitem_crmacct_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY todoitem
    ADD CONSTRAINT todoitem_todoitem_crmacct_id_fkey FOREIGN KEY (todoitem_crmacct_id) REFERENCES crmacct(crmacct_id);


--
-- TOC entry 7856 (class 2606 OID 146574219)
-- Dependencies: 6824 206 233 8894
-- Name: todoitem_todoitem_incdt_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY todoitem
    ADD CONSTRAINT todoitem_todoitem_incdt_id_fkey FOREIGN KEY (todoitem_incdt_id) REFERENCES incdt(incdt_id);


--
-- TOC entry 7857 (class 2606 OID 146574224)
-- Dependencies: 6909 231 233 8894
-- Name: todoitem_todoitem_ophead_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY todoitem
    ADD CONSTRAINT todoitem_todoitem_ophead_id_fkey FOREIGN KEY (todoitem_ophead_id) REFERENCES ophead(ophead_id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 7858 (class 2606 OID 146574229)
-- Dependencies: 6915 233 233 8894
-- Name: todoitem_todoitem_recurring_todoitem_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY todoitem
    ADD CONSTRAINT todoitem_todoitem_recurring_todoitem_id_fkey FOREIGN KEY (todoitem_recurring_todoitem_id) REFERENCES todoitem(todoitem_id);


--
-- TOC entry 8098 (class 2606 OID 146574234)
-- Dependencies: 7282 510 816 8894
-- Name: trgthist_trgthist_src_cntct_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY trgthist
    ADD CONSTRAINT trgthist_trgthist_src_cntct_id_fkey FOREIGN KEY (trgthist_src_cntct_id) REFERENCES cntctmrgd(cntctmrgd_cntct_id) ON DELETE CASCADE;


--
-- TOC entry 8099 (class 2606 OID 146574239)
-- Dependencies: 6816 204 816 8894
-- Name: trgthist_trgthist_trgt_cntct_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY trgthist
    ADD CONSTRAINT trgthist_trgthist_trgt_cntct_id_fkey FOREIGN KEY (trgthist_trgt_cntct_id) REFERENCES cntct(cntct_id) ON DELETE CASCADE;


--
-- TOC entry 8100 (class 2606 OID 146574244)
-- Dependencies: 6800 200 820 8894
-- Name: uomconv_uomconv_from_uom_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY uomconv
    ADD CONSTRAINT uomconv_uomconv_from_uom_id_fkey FOREIGN KEY (uomconv_from_uom_id) REFERENCES uom(uom_id);


--
-- TOC entry 8101 (class 2606 OID 146574249)
-- Dependencies: 6800 200 820 8894
-- Name: uomconv_uomconv_to_uom_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY uomconv
    ADD CONSTRAINT uomconv_uomconv_to_uom_id_fkey FOREIGN KEY (uomconv_to_uom_id) REFERENCES uom(uom_id);


--
-- TOC entry 8087 (class 2606 OID 146574254)
-- Dependencies: 7395 601 732 8894
-- Name: usrgrp_usrgrp_grp_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY usrgrp
    ADD CONSTRAINT usrgrp_usrgrp_grp_id_fkey FOREIGN KEY (usrgrp_grp_id) REFERENCES grp(grp_id);



--
-- TOC entry 7934 (class 2606 OID 146574279)
-- Dependencies: 6816 204 364 8894
-- Name: vendaddrinfo_vendaddr_cntct_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY vendaddrinfo
    ADD CONSTRAINT vendaddrinfo_vendaddr_cntct_id_fkey FOREIGN KEY (vendaddr_cntct_id) REFERENCES cntct(cntct_id);


--
-- TOC entry 7935 (class 2606 OID 146574284)
-- Dependencies: 6878 220 364 8894
-- Name: vendaddrinfo_vendaddr_taxzone_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY vendaddrinfo
    ADD CONSTRAINT vendaddrinfo_vendaddr_taxzone_id_fkey FOREIGN KEY (vendaddr_taxzone_id) REFERENCES taxzone(taxzone_id);


--
-- TOC entry 8108 (class 2606 OID 146574334)
-- Dependencies: 7124 363 841 8894
-- Name: voheadtax_taxhist_basis_tax_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY voheadtax
    ADD CONSTRAINT voheadtax_taxhist_basis_tax_id_fkey FOREIGN KEY (taxhist_basis_tax_id) REFERENCES tax(tax_id);


--
-- TOC entry 8109 (class 2606 OID 146574339)
-- Dependencies: 7642 839 841 8894
-- Name: voheadtax_taxhist_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY voheadtax
    ADD CONSTRAINT voheadtax_taxhist_parent_id_fkey FOREIGN KEY (taxhist_parent_id) REFERENCES vohead(vohead_id) ON DELETE CASCADE;


--
-- TOC entry 8110 (class 2606 OID 146574344)
-- Dependencies: 7124 363 841 8894
-- Name: voheadtax_taxhist_tax_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY voheadtax
    ADD CONSTRAINT voheadtax_taxhist_tax_id_fkey FOREIGN KEY (taxhist_tax_id) REFERENCES tax(tax_id);


--
-- TOC entry 8111 (class 2606 OID 146574349)
-- Dependencies: 6796 199 841 8894
-- Name: voheadtax_taxhist_taxtype_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY voheadtax
    ADD CONSTRAINT voheadtax_taxhist_taxtype_id_fkey FOREIGN KEY (taxhist_taxtype_id) REFERENCES taxtype(taxtype_id);


--
-- TOC entry 8112 (class 2606 OID 146574354)
-- Dependencies: 6796 199 842 8894
-- Name: voitem_voitem_taxtype_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY voitem
    ADD CONSTRAINT voitem_voitem_taxtype_id_fkey FOREIGN KEY (voitem_taxtype_id) REFERENCES taxtype(taxtype_id);


--
-- TOC entry 8113 (class 2606 OID 146574359)
-- Dependencies: 7124 363 844 8894
-- Name: voitemtax_taxhist_basis_tax_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY voitemtax
    ADD CONSTRAINT voitemtax_taxhist_basis_tax_id_fkey FOREIGN KEY (taxhist_basis_tax_id) REFERENCES tax(tax_id);


--
-- TOC entry 8114 (class 2606 OID 146574364)
-- Dependencies: 7648 842 844 8894
-- Name: voitemtax_taxhist_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY voitemtax
    ADD CONSTRAINT voitemtax_taxhist_parent_id_fkey FOREIGN KEY (taxhist_parent_id) REFERENCES voitem(voitem_id) ON DELETE CASCADE;


--
-- TOC entry 8115 (class 2606 OID 146574369)
-- Dependencies: 7124 363 844 8894
-- Name: voitemtax_taxhist_tax_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY voitemtax
    ADD CONSTRAINT voitemtax_taxhist_tax_id_fkey FOREIGN KEY (taxhist_tax_id) REFERENCES tax(tax_id);


--
-- TOC entry 8116 (class 2606 OID 146574374)
-- Dependencies: 6796 199 844 8894
-- Name: voitemtax_taxhist_taxtype_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY voitemtax
    ADD CONSTRAINT voitemtax_taxhist_taxtype_id_fkey FOREIGN KEY (taxhist_taxtype_id) REFERENCES taxtype(taxtype_id);



--
-- TOC entry 7928 (class 2606 OID 146574424)
-- Dependencies: 6800 200 359 8894
-- Name: womatl_womatl_uom_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY womatl
    ADD CONSTRAINT womatl_womatl_uom_id_fkey FOREIGN KEY (womatl_uom_id) REFERENCES uom(uom_id);


--
-- TOC entry 8117 (class 2606 OID 146574429)
-- Dependencies: 7417 623 850 8894
-- Name: womatlpost_womatlpost_invhist_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY womatlpost
    ADD CONSTRAINT womatlpost_womatlpost_invhist_id_fkey FOREIGN KEY (womatlpost_invhist_id) REFERENCES invhist(invhist_id);


--
-- TOC entry 8118 (class 2606 OID 146574434)
-- Dependencies: 7121 359 850 8894
-- Name: womatlpost_womatlpost_womatl_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY womatlpost
    ADD CONSTRAINT womatlpost_womatlpost_womatl_id_fkey FOREIGN KEY (womatlpost_womatl_id) REFERENCES womatl(womatl_id) ON DELETE CASCADE;


DO $$
  DECLARE
    _pkgheadExists BOOLEAN;
  BEGIN
    _pkgheadExists := EXISTS(SELECT 1 FROM pg_class WHERE relname = 'pkghead');
    IF NOT _pkgheadExists THEN
      -- dummy pkghead table to allow fixacl() to run
      CREATE TABLE pkghead (pkghead_name TEXT);
    END IF;

    PERFORM fixACL();

    IF NOT _pkgheadExists THEN DROP TABLE pkghead; END IF;
  END
$$ LANGUAGE plpgsql;


-- 2018-03-23 Add new column that did not exist in the 440 schema so it can be
-- populated by demo_data.sql. Data is populated on this 440 schema before it is
-- upgraded to the latest version.
ALTER TABLE company
  ADD COLUMN company_unassigned_accnt_id integer;
