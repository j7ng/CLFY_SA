CREATE TABLE sa.x_imei_mismatch (
  objid NUMBER,
  "MIN" VARCHAR2(30 BYTE),
  iccid VARCHAR2(30 BYTE),
  old_esn VARCHAR2(30 BYTE),
  old_esn_status VARCHAR2(30 BYTE),
  new_esn VARCHAR2(30 BYTE),
  new_esn_status VARCHAR2(30 BYTE),
  old_esn_brand VARCHAR2(30 BYTE),
  new_esn_brand VARCHAR2(30 BYTE),
  old_esn_device_type VARCHAR2(30 BYTE),
  new_esn_device_type VARCHAR2(30 BYTE),
  old_esn_manufacturer VARCHAR2(30 BYTE),
  new_esn_manufacturer VARCHAR2(30 BYTE),
  old_esn_technology VARCHAR2(30 BYTE),
  new_esn_technology VARCHAR2(30 BYTE),
  old_esn_rate_plan VARCHAR2(30 BYTE),
  old_esn_service_plan VARCHAR2(30 BYTE),
  old_esn_cos VARCHAR2(30 BYTE),
  old_esn_carrier VARCHAR2(30 BYTE),
  new_esn_carrier VARCHAR2(30 BYTE),
  zipcode VARCHAR2(30 BYTE),
  status_result VARCHAR2(100 BYTE),
  status_desc VARCHAR2(500 BYTE),
  carrier_response XMLTYPE,
  created_date DATE DEFAULT SYSDATE,
  updated_date DATE DEFAULT SYSDATE
);
COMMENT ON COLUMN sa.x_imei_mismatch.objid IS 'Unique identifier of the record.';
COMMENT ON COLUMN sa.x_imei_mismatch."MIN" IS 'Customer Phone Number';
COMMENT ON COLUMN sa.x_imei_mismatch.iccid IS 'SIM Number';
COMMENT ON COLUMN sa.x_imei_mismatch.old_esn IS 'Clarify ESN';
COMMENT ON COLUMN sa.x_imei_mismatch.old_esn_status IS 'Old IMEI STATUS';
COMMENT ON COLUMN sa.x_imei_mismatch.new_esn IS 'New IMEI';
COMMENT ON COLUMN sa.x_imei_mismatch.new_esn_status IS 'New IMEI STATUS';
COMMENT ON COLUMN sa.x_imei_mismatch.old_esn_brand IS 'Old ESN brand';
COMMENT ON COLUMN sa.x_imei_mismatch.new_esn_brand IS 'new ESN brand';
COMMENT ON COLUMN sa.x_imei_mismatch.old_esn_device_type IS 'Old ESN Device type';
COMMENT ON COLUMN sa.x_imei_mismatch.new_esn_device_type IS 'New ESN Device type';
COMMENT ON COLUMN sa.x_imei_mismatch.old_esn_manufacturer IS 'Old ESN Manufacturer';
COMMENT ON COLUMN sa.x_imei_mismatch.new_esn_manufacturer IS 'New ESN Manufacturer';
COMMENT ON COLUMN sa.x_imei_mismatch.old_esn_technology IS 'Old ESN Technology';
COMMENT ON COLUMN sa.x_imei_mismatch.new_esn_technology IS 'New ESN Technology';
COMMENT ON COLUMN sa.x_imei_mismatch.old_esn_rate_plan IS 'Old ESN Rate Plan';
COMMENT ON COLUMN sa.x_imei_mismatch.old_esn_service_plan IS 'Old ESN service Plan';
COMMENT ON COLUMN sa.x_imei_mismatch.old_esn_cos IS 'Old ESN Offer ID';
COMMENT ON COLUMN sa.x_imei_mismatch.old_esn_carrier IS 'Old ESN Carrier name';
COMMENT ON COLUMN sa.x_imei_mismatch.new_esn_carrier IS 'New ESN Carrier name';
COMMENT ON COLUMN sa.x_imei_mismatch.zipcode IS 'Zip code';
COMMENT ON COLUMN sa.x_imei_mismatch.status_result IS 'Result of the transaction';
COMMENT ON COLUMN sa.x_imei_mismatch.status_desc IS 'Status Description';
COMMENT ON COLUMN sa.x_imei_mismatch.carrier_response IS 'Response XML recevied from Carrier';
COMMENT ON COLUMN sa.x_imei_mismatch.created_date IS 'Date when the record was created';
COMMENT ON COLUMN sa.x_imei_mismatch.updated_date IS 'Date when the record was updated';