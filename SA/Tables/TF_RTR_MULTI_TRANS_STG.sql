CREATE TABLE sa.tf_rtr_multi_trans_stg (
  rtr_trans_detail_objid NUMBER,
  tf_part_num_parent VARCHAR2(100 BYTE),
  tf_serial_num VARCHAR2(100 BYTE),
  tf_red_code VARCHAR2(30 BYTE),
  rtr_vendor_name VARCHAR2(100 BYTE),
  rtr_merch_store_num VARCHAR2(100 BYTE),
  tf_pin_status_code VARCHAR2(100 BYTE),
  tf_trans_date DATE,
  tf_extract_flag VARCHAR2(1 BYTE),
  tf_extract_date DATE,
  tf_site_id VARCHAR2(40 BYTE),
  rtr_trans_type VARCHAR2(40 BYTE),
  rtr_remote_trans_id VARCHAR2(100 BYTE),
  tf_sourcesystem VARCHAR2(30 BYTE),
  rtr_merch_reg_num VARCHAR2(30 BYTE),
  tf_upc VARCHAR2(30 BYTE),
  tf_min VARCHAR2(30 BYTE),
  x_response_code VARCHAR2(100 BYTE),
  rtr_merch_store_name VARCHAR2(100 BYTE),
  rtr_esn VARCHAR2(100 BYTE),
  x_fin_cust_id VARCHAR2(40 BYTE),
  s_name VARCHAR2(80 BYTE),
  card_part_inst_status VARCHAR2(20 BYTE),
  amount NUMBER,
  status VARCHAR2(500 BYTE),
  discount_amount NUMBER,
  insert_timestamp DATE DEFAULT SYSDATE,
  update_timestamp DATE DEFAULT SYSDATE
);