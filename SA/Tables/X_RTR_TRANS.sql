CREATE TABLE sa.x_rtr_trans (
  objid NUMBER,
  tf_part_num_parent VARCHAR2(100 BYTE) NOT NULL,
  tf_serial_num VARCHAR2(100 BYTE) NOT NULL,
  tf_red_code VARCHAR2(30 BYTE),
  rtr_vendor_name VARCHAR2(100 BYTE),
  rtr_merch_store_num VARCHAR2(100 BYTE),
  tf_pin_status_code VARCHAR2(100 BYTE),
  tf_trans_date DATE,
  tf_extract_flag VARCHAR2(1 BYTE),
  tf_extract_date DATE,
  tf_site_id VARCHAR2(40 BYTE),
  rtr_trans_type VARCHAR2(40 BYTE),
  rtr_remote_trans_id VARCHAR2(20 BYTE),
  tf_sourcesystem VARCHAR2(30 BYTE),
  rtr_merch_reg_num VARCHAR2(30 BYTE),
  tf_upc VARCHAR2(30 BYTE),
  tf_min VARCHAR2(30 BYTE),
  x_response_code VARCHAR2(100 BYTE),
  rtr_merch_store_name VARCHAR2(100 BYTE),
  rtr_esn VARCHAR2(100 BYTE)
);
COMMENT ON TABLE sa.x_rtr_trans IS 'DETAILS OF RTR TRANSACTIONS';
COMMENT ON COLUMN sa.x_rtr_trans.objid IS 'UNIQUE IDENTIFIER';
COMMENT ON COLUMN sa.x_rtr_trans.tf_part_num_parent IS 'PIN PART NUMBER';
COMMENT ON COLUMN sa.x_rtr_trans.tf_serial_num IS 'PIN SMP NUMBER';
COMMENT ON COLUMN sa.x_rtr_trans.tf_red_code IS 'PIN RED CODE';
COMMENT ON COLUMN sa.x_rtr_trans.rtr_vendor_name IS 'X_PARTNER_ID.PARTNER_ID';
COMMENT ON COLUMN sa.x_rtr_trans.rtr_merch_store_num IS 'X_PARTNER_ID.PARTNER_ID';
COMMENT ON COLUMN sa.x_rtr_trans.tf_pin_status_code IS 'PIN STATUS(TABLE_X_CODE_STATUS TYPE `CS?)  ';
COMMENT ON COLUMN sa.x_rtr_trans.tf_trans_date IS 'TIME OF RTR TRANSACTION';
COMMENT ON COLUMN sa.x_rtr_trans.tf_extract_flag IS 'OFS FLAG DENOTING MOVEMENT';
COMMENT ON COLUMN sa.x_rtr_trans.tf_extract_date IS 'OFS DATE DENOTING MOVEMENT';
COMMENT ON COLUMN sa.x_rtr_trans.tf_site_id IS 'DEALER ID';
COMMENT ON COLUMN sa.x_rtr_trans.rtr_trans_type IS 'ADD OR REMOVE PIN';
COMMENT ON COLUMN sa.x_rtr_trans.rtr_remote_trans_id IS 'ID SENT BY VENDER';
COMMENT ON COLUMN sa.x_rtr_trans.tf_sourcesystem IS 'WEB ONLY';
COMMENT ON COLUMN sa.x_rtr_trans.rtr_merch_reg_num IS 'FOR LATER USE';
COMMENT ON COLUMN sa.x_rtr_trans.tf_upc IS 'TABLE_PART_NUM.X_UPC';
COMMENT ON COLUMN sa.x_rtr_trans.tf_min IS 'PHONE NUMBER';