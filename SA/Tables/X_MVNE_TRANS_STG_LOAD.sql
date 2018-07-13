CREATE TABLE sa.x_mvne_trans_stg_load (
  x_esn VARCHAR2(100 BYTE),
  x_current_sim VARCHAR2(100 BYTE),
  x_new_sim VARCHAR2(100 BYTE),
  x_imsi VARCHAR2(50 BYTE),
  x_current_min VARCHAR2(100 BYTE),
  x_new_min VARCHAR2(100 BYTE),
  x_trans_type VARCHAR2(100 BYTE),
  x_mvne_part_num VARCHAR2(100 BYTE),
  x_deact_reason VARCHAR2(100 BYTE),
  x_zipcode VARCHAR2(100 BYTE),
  x_current_plan VARCHAR2(100 BYTE),
  x_new_plan VARCHAR2(100 BYTE),
  x_transaction_id VARCHAR2(30 BYTE),
  x_batch_id VARCHAR2(30 BYTE),
  x_state VARCHAR2(100 BYTE),
  x_email VARCHAR2(200 BYTE),
  x_first_name VARCHAR2(100 BYTE),
  x_last_name VARCHAR2(100 BYTE),
  x_city VARCHAR2(100 BYTE),
  x_address1 VARCHAR2(200 BYTE),
  x_insert_date DATE DEFAULT sysdate,
  x_update_date DATE
);
COMMENT ON TABLE sa.x_mvne_trans_stg_load IS 'MVNE transaction load temp table';
COMMENT ON COLUMN sa.x_mvne_trans_stg_load.x_esn IS 'esn';
COMMENT ON COLUMN sa.x_mvne_trans_stg_load.x_current_sim IS 'current sim';
COMMENT ON COLUMN sa.x_mvne_trans_stg_load.x_new_sim IS 'new sim';
COMMENT ON COLUMN sa.x_mvne_trans_stg_load.x_imsi IS 'imsi';
COMMENT ON COLUMN sa.x_mvne_trans_stg_load.x_current_min IS 'current min';
COMMENT ON COLUMN sa.x_mvne_trans_stg_load.x_new_min IS 'new min';
COMMENT ON COLUMN sa.x_mvne_trans_stg_load.x_trans_type IS 'trans type';
COMMENT ON COLUMN sa.x_mvne_trans_stg_load.x_mvne_part_num IS 'mvne part number';
COMMENT ON COLUMN sa.x_mvne_trans_stg_load.x_deact_reason IS 'deact reason';
COMMENT ON COLUMN sa.x_mvne_trans_stg_load.x_zipcode IS 'zipcode';
COMMENT ON COLUMN sa.x_mvne_trans_stg_load.x_current_plan IS 'cuurent plan';
COMMENT ON COLUMN sa.x_mvne_trans_stg_load.x_new_plan IS 'new plan';
COMMENT ON COLUMN sa.x_mvne_trans_stg_load.x_transaction_id IS 'trasaction id';
COMMENT ON COLUMN sa.x_mvne_trans_stg_load.x_batch_id IS 'batch id';
COMMENT ON COLUMN sa.x_mvne_trans_stg_load.x_state IS 'state';
COMMENT ON COLUMN sa.x_mvne_trans_stg_load.x_email IS 'email';
COMMENT ON COLUMN sa.x_mvne_trans_stg_load.x_first_name IS 'first name';
COMMENT ON COLUMN sa.x_mvne_trans_stg_load.x_last_name IS 'last name';
COMMENT ON COLUMN sa.x_mvne_trans_stg_load.x_city IS 'city';
COMMENT ON COLUMN sa.x_mvne_trans_stg_load.x_address1 IS 'address1';
COMMENT ON COLUMN sa.x_mvne_trans_stg_load.x_insert_date IS 'insert date';
COMMENT ON COLUMN sa.x_mvne_trans_stg_load.x_update_date IS 'update date';