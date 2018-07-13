CREATE TABLE sa.redcode_pi_rc (
  part_serial_no VARCHAR2(30 BYTE),
  x_part_inst_status VARCHAR2(20 BYTE),
  rc_redcode VARCHAR2(20 BYTE),
  pi_redcode VARCHAR2(30 BYTE),
  part_num VARCHAR2(30 BYTE),
  x_redeem_units NUMBER,
  smp_length NUMBER
);
ALTER TABLE sa.redcode_pi_rc ADD SUPPLEMENTAL LOG GROUP dmtsora1783270287_0 (part_num, part_serial_no, pi_redcode, rc_redcode, smp_length, x_part_inst_status, x_redeem_units) ALWAYS;