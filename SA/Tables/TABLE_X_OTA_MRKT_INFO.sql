CREATE TABLE sa.table_x_ota_mrkt_info (
  objid NUMBER,
  x_mrkt_number VARCHAR2(20 BYTE),
  x_mrkt_type VARCHAR2(30 BYTE),
  x_mrkt_message VARCHAR2(255 BYTE),
  x_status VARCHAR2(30 BYTE),
  x_start_date DATE,
  x_end_date DATE,
  x_resent_date DATE,
  x_message_direction VARCHAR2(30 BYTE),
  x_action_type VARCHAR2(30 BYTE),
  x_ota_mrkt_info2x_ota_trans NUMBER
);
ALTER TABLE sa.table_x_ota_mrkt_info ADD SUPPLEMENTAL LOG GROUP dmtsora757391689_0 (objid, x_action_type, x_end_date, x_message_direction, x_mrkt_message, x_mrkt_number, x_mrkt_type, x_ota_mrkt_info2x_ota_trans, x_resent_date, x_start_date, x_status) ALWAYS;
COMMENT ON TABLE sa.table_x_ota_mrkt_info IS 'PSMS code messages for Marketing';
COMMENT ON COLUMN sa.table_x_ota_mrkt_info.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_ota_mrkt_info.x_mrkt_number IS 'OTA PSMS Marketing message number';
COMMENT ON COLUMN sa.table_x_ota_mrkt_info.x_mrkt_type IS 'OTA PSMS text message type for marketing';
COMMENT ON COLUMN sa.table_x_ota_mrkt_info.x_mrkt_message IS 'OTA PSMS marketing text message for Handset';
COMMENT ON COLUMN sa.table_x_ota_mrkt_info.x_status IS 'OTA PSMS text message status';
COMMENT ON COLUMN sa.table_x_ota_mrkt_info.x_start_date IS 'Text message sent using OTA Feature to ESN';
COMMENT ON COLUMN sa.table_x_ota_mrkt_info.x_end_date IS 'OTA Acknowledgement receieved for the PSMS transaction';
COMMENT ON COLUMN sa.table_x_ota_mrkt_info.x_resent_date IS 'Date when the PSMS text message was resent to same ESN';
COMMENT ON COLUMN sa.table_x_ota_mrkt_info.x_message_direction IS 'OTA Message Direction; MO - Mobile Orginator, MT - Mobile Terminator';
COMMENT ON COLUMN sa.table_x_ota_mrkt_info.x_action_type IS 'OTA Action type; Inquiry, redemption, marketing';