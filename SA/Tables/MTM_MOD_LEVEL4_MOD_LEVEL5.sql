CREATE TABLE sa.mtm_mod_level4_mod_level5 (
  part_num_incl2part_num NUMBER(*,0) NOT NULL,
  incl_part_num2part_num NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_mod_level4_mod_level5 ADD SUPPLEMENTAL LOG GROUP dmtsora29111952_0 (incl_part_num2part_num, part_num_incl2part_num) ALWAYS;