CREATE TABLE sa.mtm_user20_monitor0 (
  user_access2monitor NUMBER(*,0) NOT NULL,
  monitor2user NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_user20_monitor0 ADD SUPPLEMENTAL LOG GROUP dmtsora679530290_0 (monitor2user, user_access2monitor) ALWAYS;