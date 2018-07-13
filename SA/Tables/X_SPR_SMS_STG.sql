CREATE TABLE sa.x_spr_sms_stg (
  objid NUMBER(22) NOT NULL,
  esn VARCHAR2(30 BYTE) NOT NULL,
  usage_percent NUMBER(3),
  script_id VARCHAR2(30 BYTE),
  insert_timestamp DATE DEFAULT SYSDATE NOT NULL,
  update_timestamp DATE DEFAULT SYSDATE NOT NULL,
  sent_date DATE,
  CONSTRAINT spr_sms_stg_pk PRIMARY KEY (objid)
);
COMMENT ON TABLE sa.x_spr_sms_stg IS 'Stores the retention sms staging records.';
COMMENT ON COLUMN sa.x_spr_sms_stg.objid IS 'Unique identifier of the record.';
COMMENT ON COLUMN sa.x_spr_sms_stg.esn IS 'ESN of the subscriber.';
COMMENT ON COLUMN sa.x_spr_sms_stg.usage_percent IS 'Data usage percent to be notified.';
COMMENT ON COLUMN sa.x_spr_sms_stg.script_id IS 'Script Identifier';
COMMENT ON COLUMN sa.x_spr_sms_stg.insert_timestamp IS 'Time and date when the row was entered.';
COMMENT ON COLUMN sa.x_spr_sms_stg.update_timestamp IS 'Last date when the record was modified';
COMMENT ON COLUMN sa.x_spr_sms_stg.sent_date IS 'Sent date';