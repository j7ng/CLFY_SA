CREATE TABLE sa.mtm_x_carrier28_x_frequency1 (
  x_carrier2x_frequency NUMBER(*,0) NOT NULL,
  x_frequency2x_carrier NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_x_carrier28_x_frequency1 ADD SUPPLEMENTAL LOG GROUP dmtsora1645629800_0 (x_carrier2x_frequency, x_frequency2x_carrier) ALWAYS;
COMMENT ON TABLE sa.mtm_x_carrier28_x_frequency1 IS 'Many to Many relation between carriers and their available frequencies';
COMMENT ON COLUMN sa.mtm_x_carrier28_x_frequency1.x_carrier2x_frequency IS 'Reference to objid of table table_X_CARRIER';
COMMENT ON COLUMN sa.mtm_x_carrier28_x_frequency1.x_frequency2x_carrier IS 'Reference to objid table_x_frequency';