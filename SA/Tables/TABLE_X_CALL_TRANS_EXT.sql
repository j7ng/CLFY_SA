CREATE TABLE sa.table_x_call_trans_ext (
  objid NUMBER,
  call_trans_ext2call_trans NUMBER,
  x_total_days NUMBER,
  x_total_sms_units NUMBER,
  x_total_data_units NUMBER,
  insert_date DATE,
  update_date DATE,
  account_group_id NUMBER(22),
  master_flag VARCHAR2(1 BYTE),
  service_plan_id NUMBER(22),
  transaction_cos VARCHAR2(30 BYTE),
  ild_bucket_sent_flag VARCHAR2(1 BYTE),
  intl_bucket_sent_flag VARCHAR2(1 BYTE),
  smp VARCHAR2(30 BYTE),
  bucket_id_list sa.ig_transaction_bucket_tab,
  discount_code_list sa.discount_code_tab,
  CONSTRAINT call_trans_ext_uk UNIQUE (call_trans_ext2call_trans)
)
NESTED TABLE bucket_id_list STORE AS bucket_id_list_nt
NESTED TABLE discount_code_list STORE AS discount_list_nt;
COMMENT ON TABLE sa.table_x_call_trans_ext IS 'EXTENSION TABLE FOR TABLE_X_CALL_TRANS';
COMMENT ON COLUMN sa.table_x_call_trans_ext.objid IS 'INTERNAL RECORD NUMBER';
COMMENT ON COLUMN sa.table_x_call_trans_ext.call_trans_ext2call_trans IS 'RELATIONSHIP WITH TABLE_X_CALL_TRANS';
COMMENT ON COLUMN sa.table_x_call_trans_ext.x_total_days IS 'TOTAL DAYS';
COMMENT ON COLUMN sa.table_x_call_trans_ext.x_total_sms_units IS 'TOTAL SMS UNITS';
COMMENT ON COLUMN sa.table_x_call_trans_ext.x_total_data_units IS 'TOTAL DATA UNITS';
COMMENT ON COLUMN sa.table_x_call_trans_ext.insert_date IS 'DATE WHEN RECORD INSERTED';
COMMENT ON COLUMN sa.table_x_call_trans_ext.update_date IS 'DATE WHEN RECORD UPDATED';
COMMENT ON COLUMN sa.table_x_call_trans_ext.transaction_cos IS 'COS value of the add on in call transaction';
COMMENT ON COLUMN sa.table_x_call_trans_ext.ild_bucket_sent_flag IS 'WILL BE SET TO Y IF OUTBOUND ILD BUCKET WAS SENT AS PART OF TRANSACTION';
COMMENT ON COLUMN sa.table_x_call_trans_ext.intl_bucket_sent_flag IS 'WILL BE SET TO Y IF OUTBOUND INTERNATIONAL BUCKET WAS SENT AS PART OF TRANSACTION';
COMMENT ON COLUMN sa.table_x_call_trans_ext.smp IS 'PIN serial number from TABLE_PART_INST';
COMMENT ON COLUMN sa.table_x_call_trans_ext.bucket_id_list IS 'Nested table column to store list of bucket ids for each call transaction';