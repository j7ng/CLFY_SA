CREATE TABLE sa.x_soa_device_verification (
  x_client_transaction_id NUMBER,
  x_client_id VARCHAR2(30 BYTE),
  x_esn VARCHAR2(30 BYTE),
  x_zipcode VARCHAR2(20 BYTE),
  x_carrier_name VARCHAR2(30 BYTE),
  x_sourcesystem VARCHAR2(30 BYTE),
  x_internal_status_flag VARCHAR2(1 BYTE),
  x_try_counter NUMBER,
  x_org_id VARCHAR2(30 BYTE),
  x_language VARCHAR2(30 BYTE),
  x_soa_dev_ver2ig_transaction VARCHAR2(30 BYTE),
  x_action_timestamp DATE DEFAULT sysdate,
  x_min VARCHAR2(30 BYTE),
  x_technology VARCHAR2(50 BYTE)
);
COMMENT ON TABLE sa.x_soa_device_verification IS 'AN API TO CHECK IF A DEVICE IS ELIGIBLE AND COVERED USED BY 3RD PARTY';
COMMENT ON COLUMN sa.x_soa_device_verification.x_client_transaction_id IS 'BY USER';
COMMENT ON COLUMN sa.x_soa_device_verification.x_client_id IS 'UNIQUE ID USED TO IDENTIFY THE FRONT END CHANNEL';
COMMENT ON COLUMN sa.x_soa_device_verification.x_esn IS 'ELECTRONIC SERIAL NUMBER';
COMMENT ON COLUMN sa.x_soa_device_verification.x_zipcode IS 'COVERAGE AREA';
COMMENT ON COLUMN sa.x_soa_device_verification.x_carrier_name IS 'SERVICE PROVIDER';
COMMENT ON COLUMN sa.x_soa_device_verification.x_sourcesystem IS 'ACCESS POINT CHANNEL TAS WEB UDP 3CI';
COMMENT ON COLUMN sa.x_soa_device_verification.x_internal_status_flag IS 'CHECK IF IG_TRANSACTION WAS UPDATED BY INTERGATE FOR CDMA DEVICES';
COMMENT ON COLUMN sa.x_soa_device_verification.x_try_counter IS 'NUMBER OF TIMES THE SERVICE CHECKS IG_TRANSACTION FOR STATUS';
COMMENT ON COLUMN sa.x_soa_device_verification.x_org_id IS 'BRAND NAME';
COMMENT ON COLUMN sa.x_soa_device_verification.x_language IS 'LANGUAGE';
COMMENT ON COLUMN sa.x_soa_device_verification.x_min IS 'Phone number';
COMMENT ON COLUMN sa.x_soa_device_verification.x_technology IS 'Technology';