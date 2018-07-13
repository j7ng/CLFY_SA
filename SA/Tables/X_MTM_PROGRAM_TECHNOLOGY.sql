CREATE TABLE sa.x_mtm_program_technology (
  program_param_objid NUMBER,
  x_technology VARCHAR2(10 BYTE)
);
ALTER TABLE sa.x_mtm_program_technology ADD SUPPLEMENTAL LOG GROUP dmtsora1043861581_0 (program_param_objid, x_technology) ALWAYS;
COMMENT ON TABLE sa.x_mtm_program_technology IS 'Billing program available by technology';
COMMENT ON COLUMN sa.x_mtm_program_technology.program_param_objid IS 'Reference to objid of table  x_program_parameters';
COMMENT ON COLUMN sa.x_mtm_program_technology.x_technology IS 'Technology name: CDMA,GSM';