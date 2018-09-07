DROP VIEW IF EXISTS public.files;

CREATE OR REPLACE VIEW public.files AS 
 SELECT file_id AS files_id,
    'FILE' AS files_type,
    file.file_title AS files_title,
    file.file_descrip AS files_descrip,
    file.file_stream AS files_stream,
    file.file_mime_type AS files_mime_type
   FROM file
   WHERE checkfileprivs(file_id)
UNION ALL
 SELECT url_id,
    'URL',
    urlinfo.url_title,
    urlinfo.url_url,
    NULL::bytea AS url_stream,
    NULL::text AS url_mime_type
   FROM urlinfo
   WHERE url_url LIKE 'file%'
     AND checkfileprivs(url_id)
;
