CREATE TABLE sa.x_score_card_part_mod (
  part_serial_no VARCHAR2(30 BYTE),
  n_part_inst2part_mod NUMBER
);
ALTER TABLE sa.x_score_card_part_mod ADD SUPPLEMENTAL LOG GROUP dmtsora781331365_0 (n_part_inst2part_mod, part_serial_no) ALWAYS;