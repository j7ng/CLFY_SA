CREATE TABLE sa.x_mtm_program_handset (
  program_param_objid NUMBER,
  part_class_objid NUMBER
);
ALTER TABLE sa.x_mtm_program_handset ADD SUPPLEMENTAL LOG GROUP dmtsora1589999039_0 (part_class_objid, program_param_objid) ALWAYS;
COMMENT ON TABLE sa.x_mtm_program_handset IS 'Eligible part class to billing programs. It depends on X_PROGRAM_PARAMETERS.X_HANDSET_VALUE (possible values in this column are NONE, RESTRICTED, PERMITTED)';
COMMENT ON COLUMN sa.x_mtm_program_handset.program_param_objid IS 'Reference to objid of table  x_program_parameters';
COMMENT ON COLUMN sa.x_mtm_program_handset.part_class_objid IS 'Reference to objid of table table_PART_CLASS';