CREATE TABLE sa.mtm_part_num14_x_frequency0 (
  part_num2x_frequency NUMBER(*,0) NOT NULL,
  x_frequency2part_num NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_part_num14_x_frequency0 ADD SUPPLEMENTAL LOG GROUP dmtsora894814919_0 (part_num2x_frequency, x_frequency2part_num) ALWAYS;
COMMENT ON TABLE sa.mtm_part_num14_x_frequency0 IS 'Frequency info for phones';
COMMENT ON COLUMN sa.mtm_part_num14_x_frequency0.part_num2x_frequency IS 'Reference to objid of table table_part_num';
COMMENT ON COLUMN sa.mtm_part_num14_x_frequency0.x_frequency2part_num IS 'relation to part number';