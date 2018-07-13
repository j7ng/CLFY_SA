CREATE TABLE sa.mtm_x_carrier34_x_scripts0 (
  carrier2script NUMBER NOT NULL,
  script2carrier NUMBER NOT NULL
);
ALTER TABLE sa.mtm_x_carrier34_x_scripts0 ADD SUPPLEMENTAL LOG GROUP dmtsora1498547145_0 (carrier2script, script2carrier) ALWAYS;
COMMENT ON COLUMN sa.mtm_x_carrier34_x_scripts0.carrier2script IS 'This is the carrier objid';
COMMENT ON COLUMN sa.mtm_x_carrier34_x_scripts0.script2carrier IS 'This is the script objid';