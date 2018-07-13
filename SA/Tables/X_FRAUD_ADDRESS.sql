CREATE TABLE sa.x_fraud_address (
  objid NUMBER,
  zipcode VARCHAR2(20 BYTE),
  "STATE" VARCHAR2(30 BYTE),
  city VARCHAR2(30 BYTE),
  address_1 VARCHAR2(100 BYTE),
  address_2 VARCHAR2(100 BYTE),
  created_by VARCHAR2(80 BYTE),
  creation_date TIMESTAMP,
  last_modified_by VARCHAR2(80 BYTE),
  last_modified_date TIMESTAMP,
  CONSTRAINT objid_unique UNIQUE (objid)
);
COMMENT ON TABLE sa.x_fraud_address IS 'Table having Fraud addresses';
COMMENT ON COLUMN sa.x_fraud_address.objid IS 'Internal record number';
COMMENT ON COLUMN sa.x_fraud_address.zipcode IS 'Zip code of the address';
COMMENT ON COLUMN sa.x_fraud_address."STATE" IS 'State name';
COMMENT ON COLUMN sa.x_fraud_address.city IS 'City name,';
COMMENT ON COLUMN sa.x_fraud_address.address_1 IS 'complete address 1';
COMMENT ON COLUMN sa.x_fraud_address.address_2 IS 'complete address 2';