CREATE TABLE sa.mtm_part_num4_opportunity18 (
  part_num2opportunity NUMBER(*,0) NOT NULL,
  opp2part_num NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_part_num4_opportunity18 ADD SUPPLEMENTAL LOG GROUP dmtsora1517531551_0 (opp2part_num, part_num2opportunity) ALWAYS;