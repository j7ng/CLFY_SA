CREATE TABLE sa.unlock_spc_encrypt (
  esn VARCHAR2(100 BYTE) NOT NULL,
  po VARCHAR2(100 BYTE),
  spc VARCHAR2(100 BYTE),
  encryptedcode1 VARCHAR2(100 BYTE),
  encryptedcode2 VARCHAR2(100 BYTE),
  encryptedcode3 VARCHAR2(100 BYTE),
  encryptedsessionkey VARCHAR2(250 BYTE),
  cryptocert VARCHAR2(100 BYTE),
  keytransportalgorithm VARCHAR2(100 BYTE),
  decryptalgorithm VARCHAR2(100 BYTE),
  unlock_status VARCHAR2(30 BYTE),
  CONSTRAINT pk_unlock_esn PRIMARY KEY (esn)
);
COMMENT ON TABLE sa.unlock_spc_encrypt IS 'Unlock Encryption codes for the ESN ';
COMMENT ON COLUMN sa.unlock_spc_encrypt.esn IS 'Electronic Serial Number Unlock Encryption';
COMMENT ON COLUMN sa.unlock_spc_encrypt.po IS 'PO';
COMMENT ON COLUMN sa.unlock_spc_encrypt.spc IS 'SPC CODE';
COMMENT ON COLUMN sa.unlock_spc_encrypt.encryptedcode1 IS 'EncryptedCode1 for the ESN';
COMMENT ON COLUMN sa.unlock_spc_encrypt.encryptedcode2 IS 'EncryptedCode2 for the ESN';
COMMENT ON COLUMN sa.unlock_spc_encrypt.encryptedcode3 IS 'EncryptedCode3 for the ESN';
COMMENT ON COLUMN sa.unlock_spc_encrypt.encryptedsessionkey IS 'EncryptedSessionKey for the ESN';
COMMENT ON COLUMN sa.unlock_spc_encrypt.cryptocert IS 'CryptoCert';
COMMENT ON COLUMN sa.unlock_spc_encrypt.keytransportalgorithm IS 'KeyTransportAlgorithm';
COMMENT ON COLUMN sa.unlock_spc_encrypt.decryptalgorithm IS 'DecryptAlgorithm';
COMMENT ON COLUMN sa.unlock_spc_encrypt.unlock_status IS 'Check whether the ESN is in a Unlocked or Locked';