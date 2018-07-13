CREATE TABLE sa.mtm_part_class7_x_ff_center1 (
  part_class2ff_center NUMBER NOT NULL,
  ff_center2part_class NUMBER NOT NULL
);
ALTER TABLE sa.mtm_part_class7_x_ff_center1 ADD SUPPLEMENTAL LOG GROUP dmtsora272098288_0 (ff_center2part_class, part_class2ff_center) ALWAYS;