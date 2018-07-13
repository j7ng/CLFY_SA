CREATE TABLE sa.act_sp_inact_pi (
  part_serial_no VARCHAR2(100 BYTE)
);
ALTER TABLE sa.act_sp_inact_pi ADD SUPPLEMENTAL LOG GROUP dmtsora1301877902_0 (part_serial_no) ALWAYS;