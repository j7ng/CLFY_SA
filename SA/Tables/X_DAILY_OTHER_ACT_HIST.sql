CREATE TABLE sa.x_daily_other_act_hist (
  part_serial_no VARCHAR2(30 BYTE),
  x_part_inst_status VARCHAR2(20 BYTE),
  site_id VARCHAR2(20 BYTE),
  x_fin_cust_id VARCHAR2(40 BYTE),
  "NAME" VARCHAR2(80 BYTE),
  new_tf_ret_location_code VARCHAR2(100 BYTE),
  toss_extract_flag VARCHAR2(100 BYTE),
  toss_extract_date DATE,
  new_inv_bin_objid NUMBER,
  process_date DATE
);
ALTER TABLE sa.x_daily_other_act_hist ADD SUPPLEMENTAL LOG GROUP dmtsora134961442_0 ("NAME", new_inv_bin_objid, new_tf_ret_location_code, part_serial_no, process_date, site_id, toss_extract_date, toss_extract_flag, x_fin_cust_id, x_part_inst_status) ALWAYS;