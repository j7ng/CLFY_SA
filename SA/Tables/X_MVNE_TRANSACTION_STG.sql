CREATE TABLE sa.x_mvne_transaction_stg (
  objid NUMBER(22) NOT NULL,
  x_esn VARCHAR2(100 BYTE),
  x_current_sim VARCHAR2(100 BYTE),
  x_new_sim VARCHAR2(100 BYTE),
  x_current_min VARCHAR2(100 BYTE),
  x_new_min VARCHAR2(100 BYTE),
  x_imsi VARCHAR2(50 BYTE),
  x_trans_type VARCHAR2(100 BYTE),
  x_mvne_part_num VARCHAR2(100 BYTE),
  x_tf_part_num VARCHAR2(100 BYTE),
  x_red_code VARCHAR2(100 BYTE),
  x_deact_reason VARCHAR2(100 BYTE),
  x_zipcode VARCHAR2(100 BYTE),
  x_promo_code VARCHAR2(100 BYTE),
  x_source_system VARCHAR2(100 BYTE),
  x_status VARCHAR2(100 BYTE),
  x_call_trans_objid NUMBER(22),
  x_transaction_id VARCHAR2(30 BYTE),
  x_batch_id VARCHAR2(30 BYTE),
  x_state VARCHAR2(100 BYTE),
  x_email VARCHAR2(200 BYTE),
  x_first_name VARCHAR2(100 BYTE),
  x_last_name VARCHAR2(100 BYTE),
  x_city VARCHAR2(100 BYTE),
  x_address1 VARCHAR2(200 BYTE),
  x_current_plan VARCHAR2(100 BYTE),
  x_new_plan VARCHAR2(100 BYTE),
  x_error_message VARCHAR2(400 BYTE),
  x_insert_date DATE DEFAULT sysdate,
  x_update_date DATE,
  CONSTRAINT x_mvne_transaction_stg_pk PRIMARY KEY (objid)
);
COMMENT ON TABLE sa.x_mvne_transaction_stg IS 'mvne transaction stagint table';
COMMENT ON COLUMN sa.x_mvne_transaction_stg.objid IS 'unique sequence number';
COMMENT ON COLUMN sa.x_mvne_transaction_stg.x_esn IS 'esn';
COMMENT ON COLUMN sa.x_mvne_transaction_stg.x_current_sim IS 'current sim';
COMMENT ON COLUMN sa.x_mvne_transaction_stg.x_new_sim IS 'new sim';
COMMENT ON COLUMN sa.x_mvne_transaction_stg.x_current_min IS 'current min';
COMMENT ON COLUMN sa.x_mvne_transaction_stg.x_new_min IS 'new min';
COMMENT ON COLUMN sa.x_mvne_transaction_stg.x_imsi IS 'imsi';
COMMENT ON COLUMN sa.x_mvne_transaction_stg.x_trans_type IS 'trans type';
COMMENT ON COLUMN sa.x_mvne_transaction_stg.x_mvne_part_num IS 'mvne part number';
COMMENT ON COLUMN sa.x_mvne_transaction_stg.x_tf_part_num IS 'tf part number';
COMMENT ON COLUMN sa.x_mvne_transaction_stg.x_red_code IS 'redemption code';
COMMENT ON COLUMN sa.x_mvne_transaction_stg.x_deact_reason IS 'deact reason';
COMMENT ON COLUMN sa.x_mvne_transaction_stg.x_zipcode IS 'zipcode';
COMMENT ON COLUMN sa.x_mvne_transaction_stg.x_promo_code IS 'promo code';
COMMENT ON COLUMN sa.x_mvne_transaction_stg.x_source_system IS 'source system';
COMMENT ON COLUMN sa.x_mvne_transaction_stg.x_status IS 'status';
COMMENT ON COLUMN sa.x_mvne_transaction_stg.x_call_trans_objid IS 'call trans objid';
COMMENT ON COLUMN sa.x_mvne_transaction_stg.x_transaction_id IS 'transaction id';
COMMENT ON COLUMN sa.x_mvne_transaction_stg.x_batch_id IS 'batch id';
COMMENT ON COLUMN sa.x_mvne_transaction_stg.x_state IS 'state';
COMMENT ON COLUMN sa.x_mvne_transaction_stg.x_email IS 'eamil';
COMMENT ON COLUMN sa.x_mvne_transaction_stg.x_first_name IS 'first name';
COMMENT ON COLUMN sa.x_mvne_transaction_stg.x_last_name IS 'last name';
COMMENT ON COLUMN sa.x_mvne_transaction_stg.x_city IS 'city';
COMMENT ON COLUMN sa.x_mvne_transaction_stg.x_address1 IS 'address1';
COMMENT ON COLUMN sa.x_mvne_transaction_stg.x_current_plan IS 'current plan';
COMMENT ON COLUMN sa.x_mvne_transaction_stg.x_new_plan IS 'new plan';
COMMENT ON COLUMN sa.x_mvne_transaction_stg.x_error_message IS 'error message';
COMMENT ON COLUMN sa.x_mvne_transaction_stg.x_insert_date IS 'insert date';
COMMENT ON COLUMN sa.x_mvne_transaction_stg.x_update_date IS 'update date';