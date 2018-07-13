CREATE TABLE sa.mtm_monitor9_bug20 (
  monitor2bug NUMBER(*,0) NOT NULL,
  bug_view2monitor NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_monitor9_bug20 ADD SUPPLEMENTAL LOG GROUP dmtsora2141163551_0 (bug_view2monitor, monitor2bug) ALWAYS;