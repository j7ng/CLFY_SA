CREATE TABLE sa.x_bi_notification_stg (
  objid NUMBER(22),
  client_trans_id VARCHAR2(100 BYTE),
  client_id VARCHAR2(100 BYTE),
  esn VARCHAR2(100 BYTE),
  "MIN" VARCHAR2(100 BYTE),
  brand VARCHAR2(100 BYTE),
  source_system VARCHAR2(100 BYTE),
  balance_trans_id NUMBER(22),
  balance_trans_date DATE,
  notification_type VARCHAR2(100 BYTE),
  retry_count NUMBER(22),
  status VARCHAR2(100 BYTE),
  insert_timestamp DATE DEFAULT SYSDATE,
  update_timestamp DATE DEFAULT SYSDATE,
  language VARCHAR2(100 BYTE)
);
COMMENT ON TABLE sa.x_bi_notification_stg IS 'Stores BI notification details';
COMMENT ON COLUMN sa.x_bi_notification_stg.objid IS 'Stores the unique identifier for each record';
COMMENT ON COLUMN sa.x_bi_notification_stg.client_trans_id IS 'Client transaction id for Balance Inquiry';
COMMENT ON COLUMN sa.x_bi_notification_stg.client_id IS 'Client id';
COMMENT ON COLUMN sa.x_bi_notification_stg.esn IS 'ESN';
COMMENT ON COLUMN sa.x_bi_notification_stg."MIN" IS 'Mobile identification number';
COMMENT ON COLUMN sa.x_bi_notification_stg.brand IS 'Brand Name';
COMMENT ON COLUMN sa.x_bi_notification_stg.source_system IS 'Source system';
COMMENT ON COLUMN sa.x_bi_notification_stg.balance_trans_id IS 'Transaction ID for Balance Inquiry';
COMMENT ON COLUMN sa.x_bi_notification_stg.balance_trans_date IS 'Transaction date';
COMMENT ON COLUMN sa.x_bi_notification_stg.notification_type IS 'Balance notification type';
COMMENT ON COLUMN sa.x_bi_notification_stg.retry_count IS 'Retry count for BI';
COMMENT ON COLUMN sa.x_bi_notification_stg.status IS 'Status of BI';
COMMENT ON COLUMN sa.x_bi_notification_stg.insert_timestamp IS 'Time and date when the row was entered.';
COMMENT ON COLUMN sa.x_bi_notification_stg.update_timestamp IS 'Last date when the record was last modified';
COMMENT ON COLUMN sa.x_bi_notification_stg.language IS 'Language';