CREATE TABLE sa.x_pcrf_transaction_detail_hist (
  objid NUMBER(22),
  pcrf_transaction_id NUMBER(22),
  offer_id VARCHAR2(50 BYTE),
  ttl DATE,
  future_ttl DATE,
  redemption_date DATE,
  offer_name VARCHAR2(50 BYTE),
  data_usage NUMBER(14,2),
  hi_speed_data_usage NUMBER(14,2),
  insert_timestamp DATE,
  update_timestamp DATE
);
COMMENT ON TABLE sa.x_pcrf_transaction_detail_hist IS 'Table that contains the pcrf_transaction detail history record.';
COMMENT ON COLUMN sa.x_pcrf_transaction_detail_hist.objid IS 'Unique identifier of the stage record.';
COMMENT ON COLUMN sa.x_pcrf_transaction_detail_hist.ttl IS 'TTL';
COMMENT ON COLUMN sa.x_pcrf_transaction_detail_hist.future_ttl IS 'Future TTL';
COMMENT ON COLUMN sa.x_pcrf_transaction_detail_hist.redemption_date IS 'Redemption Date';
COMMENT ON COLUMN sa.x_pcrf_transaction_detail_hist.insert_timestamp IS 'Record Updated Timestamp';