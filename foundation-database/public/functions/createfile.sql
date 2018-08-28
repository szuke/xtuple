create or replace function createFile(pTitle TEXT, pDescription TEXT, pStream BYTEA, pMimeType TEXT) returns integer as $$
declare
  _id integer;
begin
  _id := nextval('file_file_id_seq');
  insert into file (file_id, file_title, file_descrip, file_stream, file_mime_type) values (_id, pTitle, pDescription, pStream, COALESCE(pMimeType, 'application/octet-stream'));
  return _id;
end;
$$ language 'plpgsql';
