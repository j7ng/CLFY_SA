CREATE TABLE sa.table_x_ild_transaction (
  objid NUMBER,
  dev NUMBER,
  x_min VARCHAR2(30 BYTE),
  x_esn VARCHAR2(30 BYTE),
  x_transact_date DATE,
  x_ild_trans_type VARCHAR2(30 BYTE),
  x_ild_status VARCHAR2(10 BYTE),
  x_last_update DATE,
  x_ild_account VARCHAR2(30 BYTE),
  ild_trans2site_part NUMBER,
  ild_trans2user NUMBER,
  x_conv_rate NUMBER(19,4),
  x_target_system VARCHAR2(30 BYTE),
  x_product_id VARCHAR2(30 BYTE),
  x_api_status VARCHAR2(30 BYTE),
  x_api_message VARCHAR2(256 BYTE),
  x_ild_trans2ig_trans_id NUMBER,
  x_ild_trans2call_trans NUMBER,
  web_user_objid NUMBER(22)
);
ALTER TABLE sa.table_x_ild_transaction ADD SUPPLEMENTAL LOG GROUP dmtsora99190130_0 (dev, ild_trans2site_part, ild_trans2user, objid, x_api_message, x_api_status, x_conv_rate, x_esn, x_ild_account, x_ild_status, x_ild_trans_type, x_last_update, x_min, x_product_id, x_target_system, x_transact_date) ALWAYS;
ALTER TABLE sa.table_x_ild_transaction ADD SUPPLEMENTAL LOG GROUP dmtsora1709226734_0 (dev, ild_trans2site_part, ild_trans2user, objid, x_conv_rate, x_esn, x_ild_account, x_ild_status, x_ild_trans_type, x_last_update, x_min, x_product_id, x_target_system, x_transact_date) ALWAYS;
COMMENT ON COLUMN sa.table_x_ild_transaction.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_ild_transaction.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_x_ild_transaction.x_min IS 'TBD';
COMMENT ON COLUMN sa.table_x_ild_transaction.x_esn IS 'TBD';
COMMENT ON COLUMN sa.table_x_ild_transaction.x_transact_date IS 'TBD';
COMMENT ON COLUMN sa.table_x_ild_transaction.x_ild_trans_type IS 'TBD';
COMMENT ON COLUMN sa.table_x_ild_transaction.x_ild_status IS 'Pending,Processed,Completed,Fail,Canceled';
COMMENT ON COLUMN sa.table_x_ild_transaction.x_last_update IS 'Last update date-time to the record';
COMMENT ON COLUMN sa.table_x_ild_transaction.x_ild_account IS 'TBD';
COMMENT ON COLUMN sa.table_x_ild_transaction.ild_trans2site_part IS 'TBD';
COMMENT ON COLUMN sa.table_x_ild_transaction.ild_trans2user IS 'TBD';
COMMENT ON COLUMN sa.table_x_ild_transaction.x_conv_rate IS 'Conversion rate to be use for Motricity update';
COMMENT ON COLUMN sa.table_x_ild_transaction.x_target_system IS 'TBD';
COMMENT ON COLUMN sa.table_x_ild_transaction.x_product_id IS 'TBD';
COMMENT ON COLUMN sa.table_x_ild_transaction.x_api_status IS 'TBD';
COMMENT ON COLUMN sa.table_x_ild_transaction.x_api_message IS 'TBD';
COMMENT ON COLUMN sa.table_x_ild_transaction.x_ild_trans2ig_trans_id IS 'REFERENCE TO TRANSACTION_ID OF IG_TRANSACTION';
COMMENT ON COLUMN sa.table_x_ild_transaction.x_ild_trans2call_trans IS 'REFERENCE TO OBJID OF TABLE_CALL_TANS';