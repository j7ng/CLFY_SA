CREATE TABLE sa.mtm_user27_ripbin2 (
  user_access2ripbin NUMBER(*,0) NOT NULL,
  ripbin_access2user NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_user27_ripbin2 ADD SUPPLEMENTAL LOG GROUP dmtsora1055939133_0 (ripbin_access2user, user_access2ripbin) ALWAYS;