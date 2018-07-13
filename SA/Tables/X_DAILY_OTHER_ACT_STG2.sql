CREATE TABLE sa.x_daily_other_act_stg2 (
  part_serial_no VARCHAR2(30 BYTE),
  x_part_inst_status VARCHAR2(20 BYTE),
  site_id VARCHAR2(20 BYTE),
  x_fin_cust_id VARCHAR2(40 BYTE),
  "NAME" VARCHAR2(80 BYTE),
  tf_ret_location_code VARCHAR2(100 BYTE),
  toss_extract_flag VARCHAR2(100 BYTE) NOT NULL,
  toss_extract_date DATE,
  inv_bin_objid NUMBER
);
ALTER TABLE sa.x_daily_other_act_stg2 ADD SUPPLEMENTAL LOG GROUP dmtsora677447305_0 (inv_bin_objid, "NAME", part_serial_no, site_id, tf_ret_location_code, toss_extract_date, toss_extract_flag, x_fin_cust_id, x_part_inst_status) ALWAYS;