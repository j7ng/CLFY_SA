CREATE TABLE sa.unlock_esn_status (
  esn VARCHAR2(30 BYTE) NOT NULL,
  unlock_status VARCHAR2(30 BYTE),
  CONSTRAINT unlock_esn_status_pk PRIMARY KEY (esn)
);
COMMENT ON COLUMN sa.unlock_esn_status.esn IS 'Electronic Serial Number Unlock Encryption.';
COMMENT ON COLUMN sa.unlock_esn_status.unlock_status IS 'Status of the phone.';