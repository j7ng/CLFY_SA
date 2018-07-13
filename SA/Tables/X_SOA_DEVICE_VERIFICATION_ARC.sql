CREATE TABLE sa.x_soa_device_verification_arc (
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
COMMENT ON COLUMN sa.x_soa_device_verification_arc.x_min IS 'Phone number';
COMMENT ON COLUMN sa.x_soa_device_verification_arc.x_technology IS 'Technology';