CREATE TABLE sa.x_spr_inquiry_log (
  objid NUMBER(22) NOT NULL,
  esn VARCHAR2(30 BYTE),
  "MIN" VARCHAR2(30 BYTE),
  msid VARCHAR2(30 BYTE),
  subscriber_id VARCHAR2(50 BYTE),
  "GROUP_ID" VARCHAR2(50 BYTE),
  wf_mac_id VARCHAR2(50 BYTE),
  response_code NUMBER(3),
  response_message VARCHAR2(1000 BYTE),
  sourcesystem VARCHAR2(30 BYTE),
  insert_timestamp DATE DEFAULT SYSDATE NOT NULL,
  update_timestamp DATE DEFAULT SYSDATE NOT NULL,
  CONSTRAINT x_spr_inquiry_log_pk PRIMARY KEY (objid)
);
COMMENT ON TABLE sa.x_spr_inquiry_log IS 'Logging table to capture all ESN inquiries';
COMMENT ON COLUMN sa.x_spr_inquiry_log.objid IS 'Unique identifier of the record.';
COMMENT ON COLUMN sa.x_spr_inquiry_log.esn IS 'Serial Number of the logged row.';
COMMENT ON COLUMN sa.x_spr_inquiry_log."MIN" IS 'Mobile Number of the logged row.';
COMMENT ON COLUMN sa.x_spr_inquiry_log.msid IS 'Identified of Subscriber';
COMMENT ON COLUMN sa.x_spr_inquiry_log.subscriber_id IS 'Unique Identifier of the Subscriber';
COMMENT ON COLUMN sa.x_spr_inquiry_log."GROUP_ID" IS 'Group ID of the Group which customer belongs to';
COMMENT ON COLUMN sa.x_spr_inquiry_log.wf_mac_id IS 'Identifier of WF_MAC';
COMMENT ON COLUMN sa.x_spr_inquiry_log.response_code IS 'Response Code';
COMMENT ON COLUMN sa.x_spr_inquiry_log.response_message IS 'Response Message';
COMMENT ON COLUMN sa.x_spr_inquiry_log.sourcesystem IS 'Source System';
COMMENT ON COLUMN sa.x_spr_inquiry_log.insert_timestamp IS 'Record Inserted Timestamp';
COMMENT ON COLUMN sa.x_spr_inquiry_log.update_timestamp IS 'Record Updated Timestamp';