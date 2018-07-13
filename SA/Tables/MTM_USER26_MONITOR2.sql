CREATE TABLE sa.mtm_user26_monitor2 (
  supvr_access2monitor NUMBER(*,0) NOT NULL,
  super_monitor2user NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_user26_monitor2 ADD SUPPLEMENTAL LOG GROUP dmtsora1386564404_0 (super_monitor2user, supvr_access2monitor) ALWAYS;