CREATE TABLE sa.x_score_card_mkt2 (
  part_serial_no VARCHAR2(30 BYTE),
  part_inst2carrier_mkt NUMBER,
  npa VARCHAR2(10 BYTE),
  nxx VARCHAR2(10 BYTE),
  ext VARCHAR2(10 BYTE),
  exp_date DATE
);
ALTER TABLE sa.x_score_card_mkt2 ADD SUPPLEMENTAL LOG GROUP dmtsora216785180_0 (exp_date, ext, npa, nxx, part_inst2carrier_mkt, part_serial_no) ALWAYS;