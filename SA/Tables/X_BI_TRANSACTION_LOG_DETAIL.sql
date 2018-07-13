CREATE TABLE sa.x_bi_transaction_log_detail (
  objid NUMBER,
  trans2trans_log_dtl NUMBER,
  mtg_type VARCHAR2(50 BYTE),
  mtg_src VARCHAR2(50 BYTE),
  trans_id VARCHAR2(50 BYTE),
  x_timeout_minutes_threshold NUMBER(22),
  x_daily_attempts_threshold NUMBER(22),
  CONSTRAINT fk1_bi_transaction_log_detail FOREIGN KEY (trans2trans_log_dtl) REFERENCES sa.x_bi_transaction_log (objid)
);
COMMENT ON COLUMN sa.x_bi_transaction_log_detail.trans2trans_log_dtl IS 'Link to x_bi_transaction_log table';
COMMENT ON COLUMN sa.x_bi_transaction_log_detail.mtg_type IS 'Metering Type';
COMMENT ON COLUMN sa.x_bi_transaction_log_detail.mtg_src IS 'Metering Source';
COMMENT ON COLUMN sa.x_bi_transaction_log_detail.trans_id IS 'Call Trans Id';
COMMENT ON COLUMN sa.x_bi_transaction_log_detail.x_timeout_minutes_threshold IS 'Timeout Mins threshold from x_usage_host';
COMMENT ON COLUMN sa.x_bi_transaction_log_detail.x_daily_attempts_threshold IS 'Daily attempts threshold from x_usage_host';