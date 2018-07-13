CREATE TABLE sa.x_mtm_program_carrparent (
  program_param_objid NUMBER NOT NULL,
  carr_parent_objid NUMBER NOT NULL
);
ALTER TABLE sa.x_mtm_program_carrparent ADD SUPPLEMENTAL LOG GROUP dmtsora703418320_0 (carr_parent_objid, program_param_objid) ALWAYS;
COMMENT ON TABLE sa.x_mtm_program_carrparent IS 'Billing programs filter by carrier parents';
COMMENT ON COLUMN sa.x_mtm_program_carrparent.program_param_objid IS 'Reference to objid of table  x_program_parameters';
COMMENT ON COLUMN sa.x_mtm_program_carrparent.carr_parent_objid IS 'Reference to objid of table table_x_parent';