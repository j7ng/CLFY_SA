CREATE TABLE sa.x_fraud_keys (
  objid NUMBER,
  x_key_name VARCHAR2(100 BYTE),
  x_key_description VARCHAR2(200 BYTE),
  x_key_status VARCHAR2(20 BYTE),
  CONSTRAINT fraud_key_objid_unique UNIQUE (objid) USING INDEX sa.idx_fraud_keys_objid
);
COMMENT ON COLUMN sa.x_fraud_keys.objid IS 'Sequence for SA.SEQU_FRAUD_KEYS';
COMMENT ON COLUMN sa.x_fraud_keys.x_key_name IS 'Key for the Entity';
COMMENT ON COLUMN sa.x_fraud_keys.x_key_description IS 'Description of key';
COMMENT ON COLUMN sa.x_fraud_keys.x_key_status IS 'Status of key';