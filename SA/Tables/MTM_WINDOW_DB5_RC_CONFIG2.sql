CREATE TABLE sa.mtm_window_db5_rc_config2 (
  window_db2rc_init NUMBER(*,0) NOT NULL,
  rc_init2window_db NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_window_db5_rc_config2 ADD SUPPLEMENTAL LOG GROUP dmtsora1232982338_0 (rc_init2window_db, window_db2rc_init) ALWAYS;