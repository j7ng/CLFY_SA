CREATE TABLE sa.byop_sms_stg (
  esn VARCHAR2(30 BYTE),
  "MIN" VARCHAR2(30 BYTE),
  carrier_id NUMBER,
  transaction_type VARCHAR2(50 BYTE),
  insert_date DATE DEFAULT SYSDATE,
  sent_date DATE,
  x_msg_script_id VARCHAR2(30 BYTE),
  x_msg_script_variables VARCHAR2(1000 BYTE),
  status VARCHAR2(1 BYTE) DEFAULT 'Q' NOT NULL
);
COMMENT ON TABLE sa.byop_sms_stg IS 'TABLE TO STORE BYOP ESNS TO SEND SMS WELCOME MESSAGE';
COMMENT ON COLUMN sa.byop_sms_stg.esn IS 'BYOP PHONE SERIAL NUMBER';
COMMENT ON COLUMN sa.byop_sms_stg."MIN" IS 'BYOP MIN';
COMMENT ON COLUMN sa.byop_sms_stg.carrier_id IS 'BYOP MIN CARRIER ID';
COMMENT ON COLUMN sa.byop_sms_stg.transaction_type IS 'TRANSACTION TYPE: A FOR ACTIVATION, R FOR REACTIVATION';
COMMENT ON COLUMN sa.byop_sms_stg.insert_date IS 'DATE RECORD WAS INSERTED INTO TABLE';
COMMENT ON COLUMN sa.byop_sms_stg.sent_date IS 'DATE SMS WELCOME MESSAGE WAS SENT';
COMMENT ON COLUMN sa.byop_sms_stg.status IS 'Status of record /before/after BYOP Welcome Msg Job. Q - Queued, S - Sucess, F - Failed';