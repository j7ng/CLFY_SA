CREATE TABLE sa.table_x_zero_out_max (
  objid NUMBER,
  x_esn VARCHAR2(30 BYTE),
  x_req_date_time DATE,
  x_reac_date_time DATE,
  x_max_date_time DATE,
  x_sourcesystem VARCHAR2(30 BYTE),
  x_deposit NUMBER,
  x_transaction_type NUMBER,
  x_zero_out2user NUMBER,
  x_sms_deposit NUMBER,
  x_data_deposit NUMBER,
  x_mtt_flag NUMBER,
  x_product_type VARCHAR2(30 BYTE),
  x_free_deposit NUMBER(22),
  x_free_sms_deposit NUMBER(22),
  x_free_data_deposit NUMBER(22)
);
ALTER TABLE sa.table_x_zero_out_max ADD SUPPLEMENTAL LOG GROUP dmtsora826844590_0 (objid, x_deposit, x_esn, x_max_date_time, x_reac_date_time, x_req_date_time, x_sourcesystem, x_transaction_type, x_zero_out2user) ALWAYS;
COMMENT ON TABLE sa.table_x_zero_out_max IS 'Tracking Zeroing out for Max system';
COMMENT ON COLUMN sa.table_x_zero_out_max.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_zero_out_max.x_esn IS 'TBD';
COMMENT ON COLUMN sa.table_x_zero_out_max.x_req_date_time IS 'Date/Time on which Record was created';
COMMENT ON COLUMN sa.table_x_zero_out_max.x_reac_date_time IS 'Date/Time on which ESN reactivated';
COMMENT ON COLUMN sa.table_x_zero_out_max.x_max_date_time IS 'Date/Time on which record was read by MAX';
COMMENT ON COLUMN sa.table_x_zero_out_max.x_sourcesystem IS 'Source System that created record';
COMMENT ON COLUMN sa.table_x_zero_out_max.x_deposit IS 'Units taken during Reactivation';
COMMENT ON COLUMN sa.table_x_zero_out_max.x_transaction_type IS 'Transaction Type 1 = TTEST, 2 = Minutes Expiration';
COMMENT ON COLUMN sa.table_x_zero_out_max.x_zero_out2user IS 'Relation to User Table';
COMMENT ON COLUMN sa.table_x_zero_out_max.x_product_type IS 'PRODUCT ID FOR ANY RESPONSE DEVICE INQUIRY FROM CARRIER.';
COMMENT ON COLUMN sa.table_x_zero_out_max.x_free_deposit IS 'Free voice units';
COMMENT ON COLUMN sa.table_x_zero_out_max.x_free_sms_deposit IS 'Free sms units';
COMMENT ON COLUMN sa.table_x_zero_out_max.x_free_data_deposit IS 'Free data units';