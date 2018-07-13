CREATE TABLE sa.mtm_group4_monitor3 (
  group_access2monitor NUMBER(*,0) NOT NULL,
  monitor2group NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_group4_monitor3 ADD SUPPLEMENTAL LOG GROUP dmtsora2076199058_0 (group_access2monitor, monitor2group) ALWAYS;