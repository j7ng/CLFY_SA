CREATE TABLE sa.x_ota_batch (
  batchid NUMBER,
  batch_type VARCHAR2(20 BYTE),
  execution_time DATE,
  status CHAR,
  marketingmsg VARCHAR2(150 BYTE),
  psmsmsg VARCHAR2(190 BYTE),
  finished_on DATE
);
ALTER TABLE sa.x_ota_batch ADD SUPPLEMENTAL LOG GROUP dmtsora1013874572_0 (batchid, batch_type, execution_time, finished_on, marketingmsg, psmsmsg, status) ALWAYS;
COMMENT ON TABLE sa.x_ota_batch IS 'Batch Processing of OTA Messages';
COMMENT ON COLUMN sa.x_ota_batch.batchid IS 'Batch ID';
COMMENT ON COLUMN sa.x_ota_batch.batch_type IS 'Batch Type';
COMMENT ON COLUMN sa.x_ota_batch.execution_time IS 'Execution Time';
COMMENT ON COLUMN sa.x_ota_batch.status IS 'Status';
COMMENT ON COLUMN sa.x_ota_batch.marketingmsg IS 'Marketing Message';
COMMENT ON COLUMN sa.x_ota_batch.psmsmsg IS 'PSMS Message';
COMMENT ON COLUMN sa.x_ota_batch.finished_on IS 'Finished On, Timestamp';