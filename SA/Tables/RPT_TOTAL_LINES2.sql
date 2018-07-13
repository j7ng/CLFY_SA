CREATE TABLE sa.rpt_total_lines2 (
  x_npa VARCHAR2(3 BYTE),
  x_nxx VARCHAR2(3 BYTE),
  x_carrier_id NUMBER,
  x_part_inst_status VARCHAR2(5 BYTE),
  cnt NUMBER
);
ALTER TABLE sa.rpt_total_lines2 ADD SUPPLEMENTAL LOG GROUP dmtsora2095233175_0 (cnt, x_carrier_id, x_npa, x_nxx, x_part_inst_status) ALWAYS;