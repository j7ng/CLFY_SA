CREATE TABLE sa.mtm_part_num19_part_class5 (
  acc_part2phone_class NUMBER NOT NULL,
  phone_class2acc_part NUMBER NOT NULL
);
ALTER TABLE sa.mtm_part_num19_part_class5 ADD SUPPLEMENTAL LOG GROUP dmtsora170723108_0 (acc_part2phone_class, phone_class2acc_part) ALWAYS;
COMMENT ON TABLE sa.mtm_part_num19_part_class5 IS 'Links accessory part numbers to phone models allowing to display available accessories for a given model.';
COMMENT ON COLUMN sa.mtm_part_num19_part_class5.acc_part2phone_class IS 'Reference to objid of table table_part_num, accessories';
COMMENT ON COLUMN sa.mtm_part_num19_part_class5.phone_class2acc_part IS 'Reference to objid of table_part_class';