-- some postgres versions cannot create an extension if its functions exist
DO $DROP$ BEGIN
  IF NOT EXISTS(SELECT 1 FROM pg_extension WHERE extname = 'pgcrypto') THEN
    DROP FUNCTION IF EXISTS public.armor(bytea);
    DROP FUNCTION IF EXISTS public.crypt(text, text);
    DROP FUNCTION IF EXISTS public.dearmor(text);
    DROP FUNCTION IF EXISTS public.decrypt(bytea, bytea, text);
    DROP FUNCTION IF EXISTS public.decrypt_iv(bytea, bytea, bytea, text);
    DROP FUNCTION IF EXISTS public.digest(bytea, text);
    DROP FUNCTION IF EXISTS public.digest(text, text);
    DROP FUNCTION IF EXISTS public.encrypt(bytea, bytea, text);
    DROP FUNCTION IF EXISTS public.encrypt_iv(bytea, bytea, bytea, text);
    DROP FUNCTION IF EXISTS public.gen_random_bytes(integer);
    DROP FUNCTION IF EXISTS public.gen_salt(text);
    DROP FUNCTION IF EXISTS public.gen_salt(text, integer);
    DROP FUNCTION IF EXISTS public.hmac(bytea, bytea, text);
    DROP FUNCTION IF EXISTS public.hmac(text, text, text);
    DROP FUNCTION IF EXISTS public.pgp_key_id(bytea);
    DROP FUNCTION IF EXISTS public.pgp_pub_decrypt(bytea, bytea);
    DROP FUNCTION IF EXISTS public.pgp_pub_decrypt(bytea, bytea, text);
    DROP FUNCTION IF EXISTS public.pgp_pub_decrypt(bytea, bytea, text, text);
    DROP FUNCTION IF EXISTS public.pgp_pub_decrypt_bytea(bytea, bytea);
    DROP FUNCTION IF EXISTS public.pgp_pub_decrypt_bytea(bytea, bytea, text);
    DROP FUNCTION IF EXISTS public.pgp_pub_decrypt_bytea(bytea, bytea, text, text);
    DROP FUNCTION IF EXISTS public.pgp_pub_encrypt(text, bytea);
    DROP FUNCTION IF EXISTS public.pgp_pub_encrypt(text, bytea, text);
    DROP FUNCTION IF EXISTS public.pgp_pub_encrypt_bytea(bytea, bytea);
    DROP FUNCTION IF EXISTS public.pgp_pub_encrypt_bytea(bytea, bytea, text);
    DROP FUNCTION IF EXISTS public.pgp_sym_decrypt(bytea, text);
    DROP FUNCTION IF EXISTS public.pgp_sym_decrypt(bytea, text, text);
    DROP FUNCTION IF EXISTS public.pgp_sym_decrypt_bytea(bytea, text);
    DROP FUNCTION IF EXISTS public.pgp_sym_decrypt_bytea(bytea, text, text);
    DROP FUNCTION IF EXISTS public.pgp_sym_encrypt(text, text);
    DROP FUNCTION IF EXISTS public.pgp_sym_encrypt(text, text, text);
    DROP FUNCTION IF EXISTS public.pgp_sym_encrypt_bytea(bytea, text);
    DROP FUNCTION IF EXISTS public.pgp_sym_encrypt_bytea(bytea, text, text);
  END IF;
END; $DROP$;

CREATE EXTENSION IF NOT EXISTS "pgcrypto";
