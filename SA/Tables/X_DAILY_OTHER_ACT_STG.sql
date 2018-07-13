CREATE TABLE sa.x_daily_other_act_stg (
  part_serial_no VARCHAR2(30 BYTE),
  x_part_inst_status VARCHAR2(20 BYTE),
  site_id VARCHAR2(20 BYTE),
  x_fin_cust_id VARCHAR2(40 BYTE),
  "NAME" VARCHAR2(80 BYTE)
);
ALTER TABLE sa.x_daily_other_act_stg ADD SUPPLEMENTAL LOG GROUP dmtsora1967050637_0 ("NAME", part_serial_no, site_id, x_fin_cust_id, x_part_inst_status) ALWAYS;