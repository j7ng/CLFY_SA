CREATE TABLE sa.mtm_x_frequency2_x_pref_tech1 (
  x_frequency2x_pref_tech NUMBER NOT NULL,
  x_pref_tech2x_frequency NUMBER NOT NULL
);
ALTER TABLE sa.mtm_x_frequency2_x_pref_tech1 ADD SUPPLEMENTAL LOG GROUP dmtsora1862123354_0 (x_frequency2x_pref_tech, x_pref_tech2x_frequency) ALWAYS;
COMMENT ON TABLE sa.mtm_x_frequency2_x_pref_tech1 IS 'Frequency info for preference technology of carrier';
COMMENT ON COLUMN sa.mtm_x_frequency2_x_pref_tech1.x_frequency2x_pref_tech IS 'Reference to objid of table table_X_FREQUENCY';
COMMENT ON COLUMN sa.mtm_x_frequency2_x_pref_tech1.x_pref_tech2x_frequency IS 'Reference to objid from table_x_pref_tech';