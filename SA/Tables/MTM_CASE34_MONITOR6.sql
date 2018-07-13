CREATE TABLE sa.mtm_case34_monitor6 (
  case_view2monitor NUMBER(*,0) NOT NULL,
  monitor2case NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_case34_monitor6 ADD SUPPLEMENTAL LOG GROUP dmtsora1255947526_0 (case_view2monitor, monitor2case) ALWAYS;