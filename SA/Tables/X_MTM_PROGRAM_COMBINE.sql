CREATE TABLE sa.x_mtm_program_combine (
  program_param_objid NUMBER(10) NOT NULL,
  program_combine_objid NUMBER(10) NOT NULL
);
ALTER TABLE sa.x_mtm_program_combine ADD SUPPLEMENTAL LOG GROUP dmtsora1851875832_0 (program_combine_objid, program_param_objid) ALWAYS;
COMMENT ON TABLE sa.x_mtm_program_combine IS 'Combined programs for billing programs';
COMMENT ON COLUMN sa.x_mtm_program_combine.program_param_objid IS 'Reference to objid of table  x_program_parameters';
COMMENT ON COLUMN sa.x_mtm_program_combine.program_combine_objid IS 'Reference to objid of table  x_program_parameters';