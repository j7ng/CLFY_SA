CREATE TABLE sa.mtm_window_db4_rc_config1 (
  window_db2rc_config NUMBER(*,0) NOT NULL,
  rc_config2window_db NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_window_db4_rc_config1 ADD SUPPLEMENTAL LOG GROUP dmtsora1924963553_0 (rc_config2window_db, window_db2rc_config) ALWAYS;