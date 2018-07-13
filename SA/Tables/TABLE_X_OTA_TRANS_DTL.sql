CREATE TABLE sa.table_x_ota_trans_dtl (
  objid NUMBER,
  x_psms_text VARCHAR2(255 BYTE),
  x_sent_date DATE,
  x_received_date DATE,
  x_resent_date DATE,
  x_ota_message_direction VARCHAR2(30 BYTE),
  x_action_type VARCHAR2(30 BYTE),
  x_ota_trans_dtl2x_ota_trans NUMBER,
  x_resend_count NUMBER
);
ALTER TABLE sa.table_x_ota_trans_dtl ADD SUPPLEMENTAL LOG GROUP dmtsora25351864_0 (objid, x_action_type, x_ota_message_direction, x_ota_trans_dtl2x_ota_trans, x_psms_text, x_received_date, x_resend_count, x_resent_date, x_sent_date) ALWAYS;
COMMENT ON TABLE sa.table_x_ota_trans_dtl IS 'All the PSMS code messages transactions generated for the ESN';
COMMENT ON COLUMN sa.table_x_ota_trans_dtl.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_ota_trans_dtl.x_psms_text IS 'OTA PSMS text for Handset';
COMMENT ON COLUMN sa.table_x_ota_trans_dtl.x_sent_date IS 'Text message sent using OTA Feature to ESN';
COMMENT ON COLUMN sa.table_x_ota_trans_dtl.x_received_date IS 'OTA Acknowledgement receieved for the PSMS transaction';
COMMENT ON COLUMN sa.table_x_ota_trans_dtl.x_resent_date IS 'Date when the PSMS text message was resent to same ESN';
COMMENT ON COLUMN sa.table_x_ota_trans_dtl.x_ota_message_direction IS 'OTA Message Direction; MO - Mobile Orginator, MT - Mobile Terminator';
COMMENT ON COLUMN sa.table_x_ota_trans_dtl.x_action_type IS 'OTA Action type; Inquiry, redemption, marketing';
COMMENT ON COLUMN sa.table_x_ota_trans_dtl.x_ota_trans_dtl2x_ota_trans IS 'OTA transaction Relation to the parent transaction';