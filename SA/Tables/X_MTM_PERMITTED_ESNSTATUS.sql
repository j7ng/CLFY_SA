CREATE TABLE sa.x_mtm_permitted_esnstatus (
  program_param_objid NUMBER,
  esn_status_objid NUMBER
);
ALTER TABLE sa.x_mtm_permitted_esnstatus ADD SUPPLEMENTAL LOG GROUP dmtsora1412955834_0 (esn_status_objid, program_param_objid) ALWAYS;
COMMENT ON TABLE sa.x_mtm_permitted_esnstatus IS 'ESN status that allow to enroll in a billing program';
COMMENT ON COLUMN sa.x_mtm_permitted_esnstatus.program_param_objid IS 'Reference to objid of  x_program_parameters';
COMMENT ON COLUMN sa.x_mtm_permitted_esnstatus.esn_status_objid IS 'Reference to objid of table_x_code_table';