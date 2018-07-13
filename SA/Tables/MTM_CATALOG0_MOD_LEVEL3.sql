CREATE TABLE sa.mtm_catalog0_mod_level3 (
  catalog2part_info NUMBER(*,0) NOT NULL,
  part_info2catalog NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_catalog0_mod_level3 ADD SUPPLEMENTAL LOG GROUP dmtsora1344469128_0 (catalog2part_info, part_info2catalog) ALWAYS;