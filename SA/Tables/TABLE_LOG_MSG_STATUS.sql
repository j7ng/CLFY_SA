CREATE TABLE sa.table_log_msg_status (
  objid NUMBER NOT NULL,
  web_account_id VARCHAR2(255 BYTE),
  channel_id VARCHAR2(255 BYTE),
  device_id VARCHAR2(255 BYTE),
  esn VARCHAR2(50 BYTE),
  "MIN" VARCHAR2(50 BYTE),
  preference_id VARCHAR2(255 BYTE),
  campaign_id VARCHAR2(255 BYTE),
  cust_trans_id VARCHAR2(255 BYTE),
  push_date DATE,
  vendor_id VARCHAR2(100 BYTE),
  response_date DATE,
  opt_out_req VARCHAR2(10 BYTE),
  brand VARCHAR2(100 BYTE),
  record_load_date DATE,
  receipt_request VARCHAR2(100 BYTE),
  created_date DATE,
  modified_date DATE,
  CONSTRAINT pk_log_msg_status PRIMARY KEY (objid)
);
COMMENT ON TABLE sa.table_log_msg_status IS 'To store the status of messages delivered by UA';
COMMENT ON COLUMN sa.table_log_msg_status.objid IS 'Unique Identifier';
COMMENT ON COLUMN sa.table_log_msg_status.web_account_id IS 'Web User Account Id';
COMMENT ON COLUMN sa.table_log_msg_status.channel_id IS 'Channel Id';
COMMENT ON COLUMN sa.table_log_msg_status.device_id IS 'Device Id';
COMMENT ON COLUMN sa.table_log_msg_status.esn IS 'ESN';
COMMENT ON COLUMN sa.table_log_msg_status."MIN" IS 'MIN';
COMMENT ON COLUMN sa.table_log_msg_status.preference_id IS 'ESN or min or My Account user';
COMMENT ON COLUMN sa.table_log_msg_status.campaign_id IS 'Campaign Id. Example, TRR_12345A_OL1C1S1_01_AP';
COMMENT ON COLUMN sa.table_log_msg_status.cust_trans_id IS 'Message Identifier';
COMMENT ON COLUMN sa.table_log_msg_status.push_date IS 'Date the message was sent to Urban Airship';
COMMENT ON COLUMN sa.table_log_msg_status.vendor_id IS 'Vendor Id';
COMMENT ON COLUMN sa.table_log_msg_status.response_date IS 'Date that the message was opened';
COMMENT ON COLUMN sa.table_log_msg_status.opt_out_req IS 'Y/N';
COMMENT ON COLUMN sa.table_log_msg_status.brand IS 'Brand';
COMMENT ON COLUMN sa.table_log_msg_status.record_load_date IS 'Date record loaded in feedback log table';
COMMENT ON COLUMN sa.table_log_msg_status.receipt_request IS 'Y/N';
COMMENT ON COLUMN sa.table_log_msg_status.created_date IS 'Audit Columns';
COMMENT ON COLUMN sa.table_log_msg_status.modified_date IS 'Audit Columns';