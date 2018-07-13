CREATE TABLE sa.mtm_inv_bin7_count_setup0 (
  setup2count_setup NUMBER(*,0) NOT NULL,
  setup2inv_bin NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_inv_bin7_count_setup0 ADD SUPPLEMENTAL LOG GROUP dmtsora551432041_0 (setup2count_setup, setup2inv_bin) ALWAYS;