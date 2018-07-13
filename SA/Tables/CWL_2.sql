CREATE TABLE sa.cwl_2 (
  part_to_esn2part_inst NUMBER,
  part_inst2x_pers NUMBER,
  "MIN" VARCHAR2(30 BYTE)
);
ALTER TABLE sa.cwl_2 ADD SUPPLEMENTAL LOG GROUP dmtsora574569297_0 ("MIN", part_inst2x_pers, part_to_esn2part_inst) ALWAYS;