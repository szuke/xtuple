INSERT INTO xt.oa2client (
  oa2client_client_id,
  oa2client_client_secret,
  oa2client_client_name,
  oa2client_client_email,
  oa2client_client_web_site,
  oa2client_client_logo,
  oa2client_client_type,
  oa2client_active,
  oa2client_issued,
  oa2client_auth_uri,
  oa2client_token_uri,
  oa2client_delegated_access,
  oa2client_client_x509_pub_cert
)
VALUES (
  $1,
  xt.uuid_generate_v4(),
  $2,
  '',
  '',
  null,
  'jwt bearer',
  true,
  now(),
  null,
  null,
  true,
  $3
)
ON CONFLICT (oa2client_client_id) DO UPDATE
SET oa2client_issued = now(),
    oa2client_client_name = $2,
    oa2client_client_x509_pub_cert = $3
