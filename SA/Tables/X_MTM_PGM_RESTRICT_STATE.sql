CREATE TABLE sa.x_mtm_pgm_restrict_state (
  program_param_objid NUMBER,
  x_state VARCHAR2(40 BYTE)
);
COMMENT ON TABLE sa.x_mtm_pgm_restrict_state IS 'HOLDS REGISTER THE STATES WHERE A PROGRAM IS NOT OFFERED';
COMMENT ON COLUMN sa.x_mtm_pgm_restrict_state.program_param_objid IS 'REFERENCES TO X_PROGRAM_PARAMETERS.OBJID.';
COMMENT ON COLUMN sa.x_mtm_pgm_restrict_state.x_state IS 'STATE WHERE A PROGRAM IS NOT OFFERED ';