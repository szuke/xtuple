DROP VIEW IF EXISTS public.documentimport CASCADE;

CREATE OR REPLACE VIEW public.documentimport AS 
SELECT 'target number'::TEXT AS target_code, 'target type'::TEXT AS target_type, 'title'::TEXT AS doc_title, 'file_data'::BYTEA AS file_data, 'file_mime_type'::TEXT AS file_mime_type,
       'file location/url'::TEXT AS file_url;

CREATE OR REPLACE VIEW public.imagesimport AS 
SELECT 'target number'::TEXT AS target_code, 'target type'::TEXT AS target_type, 'title'::TEXT AS doc_title, 'file_data'::TEXT AS file_data,
       'file location/url'::TEXT AS file_url;
       
--  =========================================================================
--  Document (and URL) Import Helper function
--  ========================================================================= 
CREATE OR REPLACE FUNCTION public.importdocument(public.documentimport)
  RETURNS INTEGER AS $$
DECLARE
  pNew ALIAS FOR $1; 
  _tgtid  INTEGER;
  _fileid INTEGER;
  _source RECORD;
BEGIN
  IF ((pNEW.target_code IS NULL AND pNew.target_type IS NOT NULL) OR
      (pNEW.target_code IS NOT NULL AND pNew.target_type IS NULL)) THEN
    RAISE EXCEPTION 'You must provide both file type and code in order to link the imported document';
  END IF;

  IF (pNEW.target_code IS NULL OR pNew.target_type IS NULL) THEN
    RAISE EXCEPTION 'Files and URLs must be linked to a target document';
  END IF;  

-- Determine Correct assignment Id, if necessary
  IF (pNew.target_type IS NOT NULL) THEN
    SELECT * INTO _source
    FROM source
    WHERE source_docass = pNEW.target_type;
    
    IF (NOT FOUND) THEN
      RAISE EXCEPTION 'Invalid Target Type.  Please check the source table';
    END IF;  

    EXECUTE format('SELECT %I FROM %I WHERE %I = %L', _source.source_key_field,
                                                      _source.source_table,
                                                      _source.source_number_field,
                                                      pNEW.target_code) INTO _tgtid;

    IF (_tgtid IS NULL) THEN
      RAISE EXCEPTION 'Target % was not found', pNEW.target_code;
    END IF;
  END IF;

-- Import file data in to correct table and make the correct associations
    INSERT INTO url ( url_source, url_source_id, url_title, url_url, url_stream, url_mime_type ) 
      VALUES(pNEW.target_type, _tgtid, pNEW.doc_title, pNEW.file_url, pNEW.file_data, pNEW.file_mime_type);
      
  RETURN _tgtid;
END; $$
  LANGUAGE plpgsql;

--  =========================================================================
--  Image Import Helper function
--  =========================================================================
CREATE OR REPLACE FUNCTION public.importimages(public.imagesimport)
  RETURNS INTEGER AS $$
DECLARE
  pNew ALIAS FOR $1; 
  _tgtid  INTEGER;
  _fileid INTEGER;
  _source RECORD;
BEGIN
-- Determine Correct assignment Id, if necessary
  IF (pNew.target_type IS NOT NULL) THEN
    SELECT * INTO _source
    FROM source
    WHERE source_docass = pNEW.target_type;
    
    IF (NOT FOUND) THEN
      RAISE EXCEPTION 'Invalid Target Type.  Please check the source table';
    END IF;  

    EXECUTE format('SELECT %I FROM %I WHERE %I = %L', _source.source_key_field,
                                                      _source.source_table,
                                                      _source.source_number_field,
                                                      pNEW.target_code) INTO _tgtid;
  END IF;

-- Import file data in to correct table and make the correct associations
  IF (_tgtid IS NOT NULL) THEN
    INSERT INTO imageass (imageass_source_id, imageass_source, imageass_image_id, imageass_purpose)
      VALUES (_tgtid, pNEW.target_type, createimage(pNEW.doc_title, pNEW.file_url, pNEW.file_data), 'I');
  ELSE
      PERFORM createimage(pNEW.doc_title, pNEW.file_url, pNEW.file_data);
  END IF;
      
  RETURN _tgtid;
END; $$
  LANGUAGE plpgsql;

--  =========================================================================
-- Corresponding RULES for import views
--  =========================================================================
CREATE OR REPLACE RULE "_INSERT" AS
    ON INSERT TO public.documentimport DO INSTEAD SELECT public.importdocument(new.*) AS insertdocuments;

CREATE OR REPLACE RULE "_INSERT" AS
    ON INSERT TO public.imagesimport DO INSTEAD SELECT public.importimages(new.*) AS insertimages;

