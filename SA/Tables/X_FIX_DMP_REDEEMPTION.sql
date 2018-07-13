CREATE TABLE sa.x_fix_dmp_redeemption (
  part_serial_no VARCHAR2(30 BYTE),
  x_part_inst_status VARCHAR2(20 BYTE),
  x_start_date DATE,
  x_end_date DATE,
  groupesn2x_promotion NUMBER
);
ALTER TABLE sa.x_fix_dmp_redeemption ADD SUPPLEMENTAL LOG GROUP dmtsora350696604_0 (groupesn2x_promotion, part_serial_no, x_end_date, x_part_inst_status, x_start_date) ALWAYS;