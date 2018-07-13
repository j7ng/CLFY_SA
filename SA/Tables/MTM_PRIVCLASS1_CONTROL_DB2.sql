CREATE TABLE sa.mtm_privclass1_control_db2 (
  privclass2control_db NUMBER(*,0) NOT NULL,
  control_db2privclass NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_privclass1_control_db2 ADD SUPPLEMENTAL LOG GROUP dmtsora1538402204_0 (control_db2privclass, privclass2control_db) ALWAYS;