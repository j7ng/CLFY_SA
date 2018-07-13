CREATE TABLE sa.x_fraud_key_values (
  objid NUMBER,
  x_key_value VARCHAR2(100 BYTE),
  x_value_status VARCHAR2(20 BYTE),
  value2entity NUMBER,
  value2key NUMBER,
  CONSTRAINT fraud_keyval_objid_unique UNIQUE (objid) USING INDEX sa.idx_fraud_values_objid
);
COMMENT ON COLUMN sa.x_fraud_key_values.objid IS 'Sequence: SA.SEQU_FRAUD_KEY_VALUES';
COMMENT ON COLUMN sa.x_fraud_key_values.x_key_value IS 'Key value for the entity';
COMMENT ON COLUMN sa.x_fraud_key_values.x_value_status IS 'Status of Key Value';
COMMENT ON COLUMN sa.x_fraud_key_values.value2entity IS 'Joins X_FRAUD_KEY_VALUES to X_FRAUD_ENTITY';
COMMENT ON COLUMN sa.x_fraud_key_values.value2key IS 'Joins X_FRAUD_KEY_VALUES to X_FRAUD_KEYS';