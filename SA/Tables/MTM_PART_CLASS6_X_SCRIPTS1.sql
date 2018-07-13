CREATE TABLE sa.mtm_part_class6_x_scripts1 (
  part_class2script NUMBER NOT NULL,
  script2part_class NUMBER NOT NULL
);
ALTER TABLE sa.mtm_part_class6_x_scripts1 ADD SUPPLEMENTAL LOG GROUP dmtsora369555213_0 (part_class2script, script2part_class) ALWAYS;
COMMENT ON TABLE sa.mtm_part_class6_x_scripts1 IS 'scripts available for phone models';
COMMENT ON COLUMN sa.mtm_part_class6_x_scripts1.part_class2script IS 'Reference to objid of table TABLE_PART_CLASS';
COMMENT ON COLUMN sa.mtm_part_class6_x_scripts1.script2part_class IS ' Reference to to objid in table_x_scripts';