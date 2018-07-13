CREATE TABLE sa.x_score_card_mkt (
  part_serial_no VARCHAR2(30 BYTE),
  part_inst2carrier_mkt NUMBER
);
ALTER TABLE sa.x_score_card_mkt ADD SUPPLEMENTAL LOG GROUP dmtsora440888104_0 (part_inst2carrier_mkt, part_serial_no) ALWAYS;