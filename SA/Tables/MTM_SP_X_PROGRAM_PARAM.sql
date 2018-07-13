CREATE TABLE sa.mtm_sp_x_program_param (
  x_sp2program_param NUMBER,
  program_para2x_sp NUMBER,
  x_recurring NUMBER
);
ALTER TABLE sa.mtm_sp_x_program_param ADD SUPPLEMENTAL LOG GROUP dmtsora133300730_0 (program_para2x_sp, x_recurring, x_sp2program_param) ALWAYS;
COMMENT ON TABLE sa.mtm_sp_x_program_param IS 'billing programs info for ST Service plans';
COMMENT ON COLUMN sa.mtm_sp_x_program_param.x_sp2program_param IS 'Reference to objid of table x_program_parameters';
COMMENT ON COLUMN sa.mtm_sp_x_program_param.program_para2x_sp IS 'Reference to objid of table  X_SERVICE_PLAN';
COMMENT ON COLUMN sa.mtm_sp_x_program_param.x_recurring IS 'SERVICE PLAN is recurring or not: 0,1';