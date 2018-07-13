CREATE TABLE sa.dbautl_mtm_part_num_freq_hist (
  part_num2x_frequency NUMBER(*,0) NOT NULL,
  x_frequency2part_num NUMBER(*,0) NOT NULL,
  delete_dt TIMESTAMP,
  delete_by VARCHAR2(50 BYTE)
);