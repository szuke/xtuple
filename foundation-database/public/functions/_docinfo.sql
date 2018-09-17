DROP VIEW IF EXISTS docinfo;
DROP FUNCTION IF EXISTS _docinfo(INTEGER, TEXT);
CREATE OR REPLACE FUNCTION _docinfo(pRefId INTEGER, pRefType TEXT, pRecursive BOOLEAN = false)
  RETURNS SETOF _docinfo AS
$$
DECLARE
  _crmacct      RECORD;
  _id           INTEGER;
  _column       TEXT;
  _target       RECORD;
BEGIN

  RETURN QUERY
    SELECT imageass_id            AS doc_id,
           image_id::text         AS doc_target_number,
           'IMG'::text            AS doc_target_type,
           imageass_image_id      AS doc_target_id,
           imageass_source::text  AS doc_source_type,
           imageass_source_id     AS doc_source_id,
           image_name::text       AS doc_name,
           image_descrip::text    AS doc_descrip,
           imageass_purpose::text AS doc_purpose,
           NULL::TEXT             AS doc_notes
      FROM imageass
      JOIN image ON image_id = imageass_image_id
     WHERE imageass_source_id = pRefId
       AND imageass_source = pRefType;

  RETURN QUERY
    SELECT url_id                 AS doc_id,
           url_id::text           AS doc_target_number,
           CASE WHEN url_stream IS NULL
                THEN 'URL'
                ELSE 'FILE'
           END                    AS doc_target_type,
           url_file_id            AS doc_target_id,
           url_source             AS doc_source_type,
           url_source_id          AS doc_source_id,
           url_title              AS doc_name,
           url_url                AS doc_descrip,
           'S'::text              AS doc_purpose,
           url_notes              AS doc_notes  
      FROM url
     WHERE url_source_id = pRefId
       AND url_source = pRefType;

  FOR _target IN SELECT docass_id,        docass_purpose,
                        docass_target_id, docass_target_type,
                        source_id, docass_notes
                   FROM docass
                   JOIN source         ON docass_target_type = source_docass
                   JOIN pg_class c     ON source_table = relname
                   JOIN pg_namespace n ON relnamespace = n.oid
                   JOIN regexp_split_to_table(buildSearchPath(), E',\\s*') sp ON nspname = sp
                  WHERE relkind = 'r'
                    AND docass_source_id = pRefId
                    AND docass_source_type = pRefType

           UNION SELECT docass_id,        docass_purpose,
                        docass_source_id, docass_source_type,
                        source_id, docass_notes
                   FROM docass
                   JOIN source         ON docass_source_type = source_docass
                   JOIN pg_class c     ON source_table = relname
                   JOIN pg_namespace n ON relnamespace = n.oid
                   JOIN regexp_split_to_table(buildSearchPath(), E',\\s*') sp ON nspname = sp
                  WHERE relkind = 'r'
                    AND docass_target_id = pRefId
                    AND docass_target_type = pRefType

  LOOP
    RETURN QUERY SELECT _target.docass_id::INTEGER,
                         target_doc_number::TEXT,
                         _target.docass_target_type::TEXT,
                         _target.docass_target_id::INTEGER,
                         pRefType::TEXT,
                         pRefId::INTEGER,
                         target_doc_name::TEXT,
                         target_doc_descrip::TEXT,
                         _target.docass_purpose::TEXT,
                         _target.docass_notes::TEXT
                    FROM _getTargetDocument(_target.docass_id, _target.source_id, pRefId);
  END LOOP;

  IF NOT pRecursive THEN
    -- get child document associations for CRM Account records
    IF pRefType = 'CRMA' THEN
      SELECT * INTO _crmacct FROM crmacct WHERE crmacct_id = pRefId;
      IF _crmacct.crmacct_cust_id IS NOT NULL THEN
        RETURN QUERY SELECT * FROM _docinfo(_crmacct.crmacct_cust_id, 'C', TRUE);
      END IF;
      IF _crmacct.crmacct_prospect_id IS NOT NULL THEN
        RETURN QUERY SELECT * FROM _docinfo(_crmacct.crmacct_prospect_id, 'PSPCT', TRUE);
      END IF;
      IF _crmacct.crmacct_vend_id IS NOT NULL THEN
        RETURN QUERY SELECT * FROM _docinfo(_crmacct.crmacct_vend_id, 'V', TRUE);
      END IF;
      IF _crmacct.crmacct_taxauth_id IS NOT NULL THEN
        RETURN QUERY SELECT * FROM _docinfo(_crmacct.crmacct_taxauth_id, 'TAXAUTH', TRUE);
      END IF;
      IF _crmacct.crmacct_emp_id IS NOT NULL THEN
        RETURN QUERY SELECT * FROM _docinfo(_crmacct.crmacct_emp_id, 'EMP', TRUE);
      END IF;
      IF _crmacct.crmacct_salesrep_id IS NOT NULL THEN
        RETURN QUERY SELECT * FROM _docinfo(_crmacct.crmacct_salesrep_id, 'SR', TRUE);
      END IF;
    END IF;

    -- get CRM Account document associations for child records
    _column := CASE pRefType WHEN 'C'       THEN 'crmacct_cust_id'
                             WHEN 'PSPCT'   THEN 'crmacct_prospect_id'
                             WHEN 'V'       THEN 'crmacct_vend_id'
                             WHEN 'TAXAUTH' THEN 'crmacct_taxauth_id'
                             WHEN 'EMP'     THEN 'crmacct_emp_id'
                             WHEN 'SR'      THEN 'crmacct_salesrep_ic'
               END;
    IF _column IS NOT NULL THEN
      EXECUTE format('SELECT crmacct_id FROM crmacct WHERE %I = %L;', _column, pRefId) INTO _id;
      RETURN QUERY SELECT * FROM _docinfo(_id, 'CRMA', TRUE);
    END IF;
  END IF;

END;
$$ LANGUAGE plpgsql;

