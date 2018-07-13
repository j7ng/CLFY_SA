CREATE TABLE sa.x_fraud_entity (
  objid NUMBER,
  x_entity_name VARCHAR2(100 BYTE),
  x_entity_description VARCHAR2(200 BYTE),
  x_entity_status VARCHAR2(20 BYTE),
  CONSTRAINT fraud_entity_objid_unique UNIQUE (objid) USING INDEX sa.idx_fraud_entity_objid,
  CONSTRAINT fraud_entity_status_unique UNIQUE (x_entity_description,x_entity_status)
);
COMMENT ON COLUMN sa.x_fraud_entity.objid IS 'Sequence For SA.SEQU_FRAUD_ENTITY';
COMMENT ON COLUMN sa.x_fraud_entity.x_entity_name IS 'Org ID for B2B, Account ID for B2C';
COMMENT ON COLUMN sa.x_fraud_entity.x_entity_description IS 'Description of Entity';
COMMENT ON COLUMN sa.x_fraud_entity.x_entity_status IS 'Status of Entity';