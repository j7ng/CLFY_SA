CREATE TABLE sa.x_pcrf_transaction_detail (
  objid NUMBER(22) NOT NULL,
  pcrf_transaction_id NUMBER(22) NOT NULL,
  offer_id VARCHAR2(50 BYTE),
  ttl DATE,
  future_ttl DATE,
  redemption_date DATE,
  offer_name VARCHAR2(50 BYTE),
  data_usage NUMBER(14,2),
  hi_speed_data_usage NUMBER(14,2),
  insert_timestamp DATE DEFAULT SYSDATE NOT NULL,
  update_timestamp DATE DEFAULT SYSDATE NOT NULL,
  CONSTRAINT x_pcrf_transaction_detail_pk PRIMARY KEY (objid)
);
COMMENT ON COLUMN sa.x_pcrf_transaction_detail.objid IS 'Unique identifier of the stage record.';
COMMENT ON COLUMN sa.x_pcrf_transaction_detail.pcrf_transaction_id IS 'Unique identified of the transaction';
COMMENT ON COLUMN sa.x_pcrf_transaction_detail.offer_id IS 'Service Plan Feature COS value.';
COMMENT ON COLUMN sa.x_pcrf_transaction_detail.ttl IS 'Expiration Date';
COMMENT ON COLUMN sa.x_pcrf_transaction_detail.future_ttl IS 'Future End Date';
COMMENT ON COLUMN sa.x_pcrf_transaction_detail.redemption_date IS 'Redemption Date';
COMMENT ON COLUMN sa.x_pcrf_transaction_detail.offer_name IS 'Name of the offer provided';
COMMENT ON COLUMN sa.x_pcrf_transaction_detail.data_usage IS 'Measure data usgae of subscriber';
COMMENT ON COLUMN sa.x_pcrf_transaction_detail.hi_speed_data_usage IS 'Hi Speed Data Utilization';
COMMENT ON COLUMN sa.x_pcrf_transaction_detail.insert_timestamp IS 'Record Insertion Timestamp';
COMMENT ON COLUMN sa.x_pcrf_transaction_detail.update_timestamp IS 'Record Updated Timestamp';