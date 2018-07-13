CREATE TABLE sa.act_sp_inact_pi2 (
  part_serial_no VARCHAR2(30 BYTE),
  x_part_inst_status VARCHAR2(20 BYTE),
  x_expire_dt DATE,
  x_min VARCHAR2(30 BYTE)
);
ALTER TABLE sa.act_sp_inact_pi2 ADD SUPPLEMENTAL LOG GROUP dmtsora2098682555_0 (part_serial_no, x_expire_dt, x_min, x_part_inst_status) ALWAYS;