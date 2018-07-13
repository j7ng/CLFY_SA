CREATE TABLE sa.x_bi_transaction_log (
  objid NUMBER(22) NOT NULL,
  esn VARCHAR2(30 BYTE),
  voice_mtg_source VARCHAR2(50 BYTE),
  voice_trans_id VARCHAR2(50 BYTE),
  text_mtg_source VARCHAR2(50 BYTE),
  text_trans_id VARCHAR2(50 BYTE),
  data_mtg_source VARCHAR2(50 BYTE),
  data_trans_id VARCHAR2(50 BYTE),
  ild_mtg_source VARCHAR2(50 BYTE),
  ild_trans_id VARCHAR2(50 BYTE),
  trans_creation_date DATE,
  x_timeout_minutes_threshold NUMBER(22),
  x_daily_attempts_threshold NUMBER(22),
  insert_timestamp DATE DEFAULT SYSDATE NOT NULL,
  update_timestamp DATE DEFAULT SYSDATE NOT NULL,
  inquiry_type VARCHAR2(100 BYTE),
  CONSTRAINT tf_x_bi_transaction_log_pk PRIMARY KEY (objid)
);
COMMENT ON TABLE sa.x_bi_transaction_log IS 'Source for the BI with the flow id details';
COMMENT ON COLUMN sa.x_bi_transaction_log.objid IS 'Stores the unique identifier for each record';
COMMENT ON COLUMN sa.x_bi_transaction_log.esn IS 'ESN';
COMMENT ON COLUMN sa.x_bi_transaction_log.voice_mtg_source IS 'Voice metering source';
COMMENT ON COLUMN sa.x_bi_transaction_log.voice_trans_id IS 'voice metering source transaction id';
COMMENT ON COLUMN sa.x_bi_transaction_log.text_mtg_source IS ' text Metering source ';
COMMENT ON COLUMN sa.x_bi_transaction_log.text_trans_id IS 'text metering source transaction id';
COMMENT ON COLUMN sa.x_bi_transaction_log.data_mtg_source IS 'data metering source';
COMMENT ON COLUMN sa.x_bi_transaction_log.data_trans_id IS 'data trans_id';
COMMENT ON COLUMN sa.x_bi_transaction_log.ild_mtg_source IS 'international data metering source';
COMMENT ON COLUMN sa.x_bi_transaction_log.ild_trans_id IS 'international data metering source';
COMMENT ON COLUMN sa.x_bi_transaction_log.trans_creation_date IS 'Transactin creation date';
COMMENT ON COLUMN sa.x_bi_transaction_log.x_timeout_minutes_threshold IS 'Timeout minutes threshold';
COMMENT ON COLUMN sa.x_bi_transaction_log.x_daily_attempts_threshold IS 'Daily attempts threshold';
COMMENT ON COLUMN sa.x_bi_transaction_log.insert_timestamp IS 'Time and date when the row was entered.';
COMMENT ON COLUMN sa.x_bi_transaction_log.update_timestamp IS 'Last date when the record was last modified';
COMMENT ON COLUMN sa.x_bi_transaction_log.inquiry_type IS 'Type of Balance Inquiry like BALANCE, USAGE';