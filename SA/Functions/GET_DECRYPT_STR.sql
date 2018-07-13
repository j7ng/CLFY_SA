CREATE OR REPLACE function sa.get_decrypt_str(l_encrypted_raw raw, key1 varchar2) return varchar2 is
    l_key     RAW(128);
    l_decrypted_raw RAW(2048);
   -- l_encrypted_raw RAW(2048);
BEGIN

     l_key           := utl_raw.cast_to_raw(key1);
  --   l_encrypted_raw := UTL_RAW.CAST_TO_RAW(str);
     l_decrypted_raw := dbms_crypto.decrypt(src => l_encrypted_raw, typ => dbms_crypto.des_cbc_pkcs5, key => l_key);

    -- dbms_output.put_line('Decrypted : ' || utl_raw.cast_to_varchar2(l_decrypted_raw));
     return utl_raw.cast_to_varchar2(l_decrypted_raw);

END;
/