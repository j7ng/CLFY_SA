CREATE TABLE sa.mtm_x_carrier27_x_scr0 (
  carrier2x_scr NUMBER(*,0) NOT NULL,
  x_scr2x_carrier NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_x_carrier27_x_scr0 ADD SUPPLEMENTAL LOG GROUP dmtsora1310645504_0 (carrier2x_scr, x_scr2x_carrier) ALWAYS;
COMMENT ON TABLE sa.mtm_x_carrier27_x_scr0 IS 'Many to Many table between carrier scripts and carriers';
COMMENT ON COLUMN sa.mtm_x_carrier27_x_scr0.carrier2x_scr IS 'Reference to objid of table  table_x_carrier';
COMMENT ON COLUMN sa.mtm_x_carrier27_x_scr0.x_scr2x_carrier IS 'Reference to objid table_x_scr, carrier scripts';