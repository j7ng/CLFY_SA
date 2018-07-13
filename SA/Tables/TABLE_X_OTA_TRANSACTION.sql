CREATE TABLE sa.table_x_ota_transaction (
  objid NUMBER,
  x_transaction_date DATE,
  x_status VARCHAR2(30 BYTE),
  x_esn VARCHAR2(30 BYTE),
  x_min VARCHAR2(30 BYTE),
  x_action_type VARCHAR2(30 BYTE),
  x_mode VARCHAR2(30 BYTE),
  x_counter NUMBER,
  x_reason VARCHAR2(150 BYTE),
  x_carrier_code VARCHAR2(30 BYTE),
  x_ota_trans2x_ota_mrkt_info NUMBER,
  x_ota_trans2x_call_trans NUMBER,
  x_mobile365_id VARCHAR2(25 BYTE),
  x_ota_trans2x_denomination NUMBER,
  x_phone_seq NUMBER
);
ALTER TABLE sa.table_x_ota_transaction ADD SUPPLEMENTAL LOG GROUP dmtsora1202474780_0 (objid, x_action_type, x_carrier_code, x_counter, x_esn, x_min, x_mobile365_id, x_mode, x_ota_trans2x_call_trans, x_ota_trans2x_denomination, x_ota_trans2x_ota_mrkt_info, x_phone_seq, x_reason, x_status, x_transaction_date) ALWAYS;
ALTER TABLE sa.table_x_ota_transaction ADD SUPPLEMENTAL LOG GROUP dmtsora1832392251_0 (objid, x_action_type, x_carrier_code, x_counter, x_esn, x_min, x_mobile365_id, x_mode, x_ota_trans2x_call_trans, x_ota_trans2x_denomination, x_ota_trans2x_ota_mrkt_info, x_phone_seq, x_reason, x_status, x_transaction_date) ALWAYS;
ALTER TABLE sa.table_x_ota_transaction ADD SUPPLEMENTAL LOG GROUP dmtsora1564773484_0 (objid, x_action_type, x_carrier_code, x_counter, x_esn, x_min, x_mobile365_id, x_mode, x_ota_trans2x_call_trans, x_ota_trans2x_denomination, x_ota_trans2x_ota_mrkt_info, x_phone_seq, x_reason, x_status, x_transaction_date) ALWAYS;
COMMENT ON TABLE sa.table_x_ota_transaction IS 'All the PSMS text messages initiation for the ESN';
COMMENT ON COLUMN sa.table_x_ota_transaction.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_ota_transaction.x_transaction_date IS 'Text message transaction initiated for the ESN';
COMMENT ON COLUMN sa.table_x_ota_transaction.x_status IS 'OTA PSMS text status';
COMMENT ON COLUMN sa.table_x_ota_transaction.x_esn IS 'ESN for OTA feature';
COMMENT ON COLUMN sa.table_x_ota_transaction.x_min IS 'MIN for the ESN with OTA feature';
COMMENT ON COLUMN sa.table_x_ota_transaction.x_action_type IS 'OTA action type';
COMMENT ON COLUMN sa.table_x_ota_transaction.x_mode IS 'OTA transaction type';
COMMENT ON COLUMN sa.table_x_ota_transaction.x_counter IS 'OTA transaction counter for the ESN';
COMMENT ON COLUMN sa.table_x_ota_transaction.x_reason IS 'OTA Message Failure reason';
COMMENT ON COLUMN sa.table_x_ota_transaction.x_carrier_code IS 'OTA Error code from teh carrier';
COMMENT ON COLUMN sa.table_x_ota_transaction.x_ota_trans2x_ota_mrkt_info IS 'OTA transaction Related to the Type of message';
COMMENT ON COLUMN sa.table_x_ota_transaction.x_ota_trans2x_call_trans IS 'OTA transaction Related to the call trans record';
COMMENT ON COLUMN sa.table_x_ota_transaction.x_mobile365_id IS 'TBD';
COMMENT ON COLUMN sa.table_x_ota_transaction.x_phone_seq IS 'PHONE SEQUENCE RETURNED FROM THE INQUIRY';