CREATE TABLE sa.x_ig_pcrf_log (
  transaction_id NUMBER(10) NOT NULL,
  processed_timestamp DATE DEFAULT SYSDATE NOT NULL,
  CONSTRAINT pk_ig_pcrf_log PRIMARY KEY (transaction_id)
);
COMMENT ON TABLE sa.x_ig_pcrf_log IS 'Table to maintain ig transaction ids processed by pcrf';
COMMENT ON COLUMN sa.x_ig_pcrf_log.transaction_id IS 'IG Transaction id unique identifier';
COMMENT ON COLUMN sa.x_ig_pcrf_log.processed_timestamp IS 'Time and date of when the row was processed';