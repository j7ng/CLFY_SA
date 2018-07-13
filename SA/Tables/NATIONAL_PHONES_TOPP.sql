CREATE TABLE sa.national_phones_topp (
  x_part_serial_no VARCHAR2(30 BYTE),
  x_pi_hist2inv_bin NUMBER,
  x_part_inst_status VARCHAR2(20 BYTE),
  status_hist2x_code_table NUMBER,
  result VARCHAR2(30 BYTE)
);
ALTER TABLE sa.national_phones_topp ADD SUPPLEMENTAL LOG GROUP dmtsora1234726604_0 (result, status_hist2x_code_table, x_part_inst_status, x_part_serial_no, x_pi_hist2inv_bin) ALWAYS;