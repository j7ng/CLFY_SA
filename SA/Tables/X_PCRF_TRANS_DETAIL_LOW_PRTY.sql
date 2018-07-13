CREATE TABLE sa.x_pcrf_trans_detail_low_prty (
  objid NUMBER(22) NOT NULL,
  pcrf_trans_low_prty_id NUMBER(22) NOT NULL,
  offer_id VARCHAR2(50 BYTE),
  ttl VARCHAR2(50 BYTE),
  future_ttl VARCHAR2(50 BYTE),
  redemption_date DATE,
  offer_name VARCHAR2(50 BYTE),
  data_usage NUMBER(10,2),
  hi_speed_data_usage NUMBER(10,2),
  insert_timestamp DATE DEFAULT SYSDATE NOT NULL,
  update_timestamp DATE DEFAULT SYSDATE NOT NULL,
  CONSTRAINT pcrf_trans_detail_low_prty_pk PRIMARY KEY (objid),
  CONSTRAINT pcrf_trans_detail_low_prty_fk1 FOREIGN KEY (pcrf_trans_low_prty_id) REFERENCES sa.x_pcrf_trans_low_prty (objid)
);
COMMENT ON COLUMN sa.x_pcrf_trans_detail_low_prty.objid IS 'Unique identifier of the stage record.';
COMMENT ON COLUMN sa.x_pcrf_trans_detail_low_prty.pcrf_trans_low_prty_id IS 'Unique identified of the transaction';
COMMENT ON COLUMN sa.x_pcrf_trans_detail_low_prty.offer_id IS 'Service Plan Feature COS value.';
COMMENT ON COLUMN sa.x_pcrf_trans_detail_low_prty.ttl IS 'Expiration Date';
COMMENT ON COLUMN sa.x_pcrf_trans_detail_low_prty.future_ttl IS 'Future End Date';
COMMENT ON COLUMN sa.x_pcrf_trans_detail_low_prty.redemption_date IS 'Redemption Date';
COMMENT ON COLUMN sa.x_pcrf_trans_detail_low_prty.offer_name IS 'Name of the offer provided';
COMMENT ON COLUMN sa.x_pcrf_trans_detail_low_prty.data_usage IS 'Measure data usgae of subscriber';
COMMENT ON COLUMN sa.x_pcrf_trans_detail_low_prty.hi_speed_data_usage IS 'Hi Speed Data Utilization';
COMMENT ON COLUMN sa.x_pcrf_trans_detail_low_prty.insert_timestamp IS 'Record Insertion Timestamp';
COMMENT ON COLUMN sa.x_pcrf_trans_detail_low_prty.update_timestamp IS 'Record Updated Timestamp';