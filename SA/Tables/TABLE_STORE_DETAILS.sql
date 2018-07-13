CREATE TABLE sa.table_store_details (
  objid NUMBER NOT NULL,
  vendor_name VARCHAR2(100 BYTE) NOT NULL,
  store_id VARCHAR2(30 BYTE) NOT NULL,
  store_name VARCHAR2(100 BYTE),
  store_address VARCHAR2(100 BYTE),
  store_city VARCHAR2(100 BYTE),
  store_state_cd VARCHAR2(10 BYTE),
  store_zip_cd VARCHAR2(10 BYTE),
  store_phone_no VARCHAR2(20 BYTE),
  created_date DATE DEFAULT SYSDATE,
  CONSTRAINT pk_store_det PRIMARY KEY (objid),
  CONSTRAINT uk_store_det UNIQUE (vendor_name,store_id)
);
COMMENT ON TABLE sa.table_store_details IS 'Store details for vendor';
COMMENT ON COLUMN sa.table_store_details.vendor_name IS 'Vendor Name';
COMMENT ON COLUMN sa.table_store_details.store_id IS 'Store ID';
COMMENT ON COLUMN sa.table_store_details.store_name IS 'Store Name';
COMMENT ON COLUMN sa.table_store_details.store_address IS 'Store Address';
COMMENT ON COLUMN sa.table_store_details.store_city IS 'Store City';
COMMENT ON COLUMN sa.table_store_details.store_state_cd IS 'State code';
COMMENT ON COLUMN sa.table_store_details.store_zip_cd IS 'Zip Code';
COMMENT ON COLUMN sa.table_store_details.store_phone_no IS 'Store Phone Number';