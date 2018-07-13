CREATE TABLE sa.x_sms_hotline (
  objid NUMBER NOT NULL,
  action_item_id VARCHAR2(30 BYTE),
  transaction_id NUMBER,
  "MIN" VARCHAR2(30 BYTE),
  text_messgae VARCHAR2(1000 BYTE),
  short_code VARCHAR2(30 BYTE),
  status VARCHAR2(30 BYTE),
  status_message VARCHAR2(256 BYTE),
  "TEMPLATE" VARCHAR2(30 BYTE),
  creation_date DATE DEFAULT SYSDATE,
  update_date DATE DEFAULT SYSDATE,
  CONSTRAINT pk_sms_hotline PRIMARY KEY (objid)
);
COMMENT ON TABLE sa.x_sms_hotline IS 'Table that contains the sms information for hotline';
COMMENT ON COLUMN sa.x_sms_hotline.objid IS 'Unique identifier of the stage record.';
COMMENT ON COLUMN sa.x_sms_hotline.action_item_id IS 'Action item id from ig trnasaction';
COMMENT ON COLUMN sa.x_sms_hotline.transaction_id IS 'Transaction id from ig transaction';
COMMENT ON COLUMN sa.x_sms_hotline."MIN" IS 'Mobile Number';
COMMENT ON COLUMN sa.x_sms_hotline.text_messgae IS 'SMS messge for hotline customers';
COMMENT ON COLUMN sa.x_sms_hotline.short_code IS 'Shotcode to identify the sms';
COMMENT ON COLUMN sa.x_sms_hotline.status IS 'Tranasaction status';
COMMENT ON COLUMN sa.x_sms_hotline.status_message IS 'Tranasaction status from carrier';
COMMENT ON COLUMN sa.x_sms_hotline."TEMPLATE" IS 'Template';
COMMENT ON COLUMN sa.x_sms_hotline.creation_date IS 'Creation date';
COMMENT ON COLUMN sa.x_sms_hotline.update_date IS 'Updated date';