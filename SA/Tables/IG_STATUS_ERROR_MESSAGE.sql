CREATE TABLE sa.ig_status_error_message (
  objid NUMBER NOT NULL,
  x_error_code VARCHAR2(50 BYTE),
  x_error_group VARCHAR2(255 BYTE),
  x_error_criteria VARCHAR2(400 BYTE),
  x_default_error_msg VARCHAR2(400 BYTE),
  CONSTRAINT ig_status_error_message_pk PRIMARY KEY (objid) USING INDEX sa.ig_status_error_message_idx
);
COMMENT ON TABLE sa.ig_status_error_message IS 'This is table being used to map or group with IG_TRANSACTION Status Message';
COMMENT ON COLUMN sa.ig_status_error_message.objid IS 'OBJID of ig_status_error_message';
COMMENT ON COLUMN sa.ig_status_error_message.x_error_code IS 'Error Code for IG_TRANSACTION Status Message';
COMMENT ON COLUMN sa.ig_status_error_message.x_error_group IS 'Error Group for IG_TRANSACTION Status Message';
COMMENT ON COLUMN sa.ig_status_error_message.x_error_criteria IS 'Error Criteria for IG_TRANSACTION Status Message. Example : TracFone: Pending Carrier Response%';
COMMENT ON COLUMN sa.ig_status_error_message.x_default_error_msg IS 'Error Message to dispaly in UI for given error criteria';