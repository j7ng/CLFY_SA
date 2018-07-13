CREATE TABLE sa.x_keystore (
  objid NUMBER NOT NULL,
  x_vendor_id VARCHAR2(30 BYTE),
  x_source_system VARCHAR2(30 BYTE),
  x_brand_name VARCHAR2(30 BYTE),
  x_appid VARCHAR2(30 BYTE),
  x_public_key BLOB,
  x_private_key BLOB,
  x_encrypt_method VARCHAR2(30 BYTE),
  x_encrypt_std VARCHAR2(30 BYTE),
  x_eff_date DATE,
  x_exp_date DATE,
  x_key_pswd VARCHAR2(800 BYTE)
);
COMMENT ON TABLE sa.x_keystore IS 'Table to store the key ids and their encryption method.';
COMMENT ON COLUMN sa.x_keystore.objid IS 'Internal record number';
COMMENT ON COLUMN sa.x_keystore.x_vendor_id IS 'Vendor ID';
COMMENT ON COLUMN sa.x_keystore.x_source_system IS 'Originating Source system';
COMMENT ON COLUMN sa.x_keystore.x_brand_name IS 'Name of the brand';
COMMENT ON COLUMN sa.x_keystore.x_appid IS 'App ID';
COMMENT ON COLUMN sa.x_keystore.x_public_key IS 'Public Key';
COMMENT ON COLUMN sa.x_keystore.x_private_key IS 'Private key';
COMMENT ON COLUMN sa.x_keystore.x_encrypt_method IS 'Encryption method';
COMMENT ON COLUMN sa.x_keystore.x_encrypt_std IS 'Encryption Standard';
COMMENT ON COLUMN sa.x_keystore.x_eff_date IS 'Effective/Start date';
COMMENT ON COLUMN sa.x_keystore.x_exp_date IS 'Expiry/End date';
COMMENT ON COLUMN sa.x_keystore.x_key_pswd IS 'password for keys';