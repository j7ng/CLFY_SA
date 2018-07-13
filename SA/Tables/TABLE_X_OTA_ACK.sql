CREATE TABLE sa.table_x_ota_ack (
  objid NUMBER,
  x_ota_error_code VARCHAR2(30 BYTE),
  x_ota_error_message VARCHAR2(200 BYTE),
  x_ota_number_of_codes NUMBER,
  x_ota_codes_accepted NUMBER,
  x_units NUMBER,
  x_phone_sequence NUMBER,
  x_psms_ack_msg VARCHAR2(255 BYTE),
  x_ota_ack2x_ota_trans_dtl NUMBER,
  x_service_end_dt DATE,
  x_sms_units NUMBER,
  x_data_units NUMBER,
  x_pre_units NUMBER
);
ALTER TABLE sa.table_x_ota_ack ADD SUPPLEMENTAL LOG GROUP dmtsora448157735_0 (objid, x_ota_ack2x_ota_trans_dtl, x_ota_codes_accepted, x_ota_error_code, x_ota_error_message, x_ota_number_of_codes, x_phone_sequence, x_psms_ack_msg, x_service_end_dt, x_units) ALWAYS;
COMMENT ON TABLE sa.table_x_ota_ack IS 'Return code from Carrier thru Inpho Match';
COMMENT ON COLUMN sa.table_x_ota_ack.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_ota_ack.x_ota_error_code IS 'OTA Error code';
COMMENT ON COLUMN sa.table_x_ota_ack.x_ota_error_message IS 'OTA Error Message';
COMMENT ON COLUMN sa.table_x_ota_ack.x_ota_number_of_codes IS 'OTA transaction codes sent to Handset';
COMMENT ON COLUMN sa.table_x_ota_ack.x_ota_codes_accepted IS 'OTA transaction codes accepted by teh Handset';
COMMENT ON COLUMN sa.table_x_ota_ack.x_units IS 'Units currently available on the handset';
COMMENT ON COLUMN sa.table_x_ota_ack.x_phone_sequence IS 'Sequence of the Handset';
COMMENT ON COLUMN sa.table_x_ota_ack.x_psms_ack_msg IS 'OTA PSMS Acknowledgement Message from Handset';
COMMENT ON COLUMN sa.table_x_ota_ack.x_ota_ack2x_ota_trans_dtl IS 'OTA ack to the transaction detail';
COMMENT ON COLUMN sa.table_x_ota_ack.x_service_end_dt IS 'OTA Acknowledgement receieved service end date';
COMMENT ON COLUMN sa.table_x_ota_ack.x_pre_units IS 'Previous Unit';