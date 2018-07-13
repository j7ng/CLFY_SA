CREATE OR REPLACE Function sa.get_encrypt_str(str varchar2, key1 varchar2) return RAW is
    --PEN VARCHAR2(100);
    l_ccn_raw RAW(128);
    l_key     RAW(128);
    l_encrypted_raw RAW(2048);
  BEGIN

     l_ccn_raw  := utl_raw.cast_to_raw(str);
     l_key      := utl_raw.cast_to_raw(key1);

     l_encrypted_raw := dbms_crypto.encrypt(l_ccn_raw,dbms_crypto.des_cbc_pkcs5, l_key);

   --  dbms_output.put_line('Encrypted : ' || RAWTOHEX(utl_raw.cast_to_raw(l_encrypted_raw)));
       return l_encrypted_raw;
    -- return RAWTOHEX(utl_raw.cast_to_raw(l_encrypted_raw));

    --PEN:=DBMS_CRYPTO.HASH(UTL_RAW.CAST_TO_RAW(PWD), DBMS_CRYPTO.HASH_SH1);
    --RETURN UTL_RAW.CAST_TO_VARCHAR2(UTL_ENCODE.BASE64_ENCODE(PEN));
END;
/