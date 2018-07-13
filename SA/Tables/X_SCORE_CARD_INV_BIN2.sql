CREATE TABLE sa.x_score_card_inv_bin2 (
  part_serial_no VARCHAR2(30 BYTE),
  part_inst2inv_bin NUMBER,
  n_part_inst2part_mod NUMBER,
  x_part_inst2contact NUMBER,
  x_part_inst2site_part NUMBER
);
ALTER TABLE sa.x_score_card_inv_bin2 ADD SUPPLEMENTAL LOG GROUP dmtsora100444843_0 (n_part_inst2part_mod, part_inst2inv_bin, part_serial_no, x_part_inst2contact, x_part_inst2site_part) ALWAYS;