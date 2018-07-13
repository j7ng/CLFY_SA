CREATE TABLE sa.act_sp_inact_pi_orig (
  part_serial_no VARCHAR2(100 BYTE),
  x_part_inst_status VARCHAR2(20 BYTE)
);
ALTER TABLE sa.act_sp_inact_pi_orig ADD SUPPLEMENTAL LOG GROUP dmtsora1390399504_0 (part_serial_no, x_part_inst_status) ALWAYS;