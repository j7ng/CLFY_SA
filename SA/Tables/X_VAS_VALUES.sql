CREATE TABLE sa.x_vas_values (
  objid NUMBER,
  vas_param_value VARCHAR2(50 BYTE),
  vas_params_objid NUMBER,
  vas_programs_objid NUMBER
);
COMMENT ON TABLE sa.x_vas_values IS 'PARAMETER VALUES';
COMMENT ON COLUMN sa.x_vas_values.objid IS 'UNIQUE KEY OF X_VAS_VALUES TABLE';
COMMENT ON COLUMN sa.x_vas_values.vas_param_value IS 'PROGRAM PARAMETER VALUE';
COMMENT ON COLUMN sa.x_vas_values.vas_params_objid IS 'FK TO X_VAS_PARAMS';
COMMENT ON COLUMN sa.x_vas_values.vas_programs_objid IS 'FK TO X_VAS_PROGRAMS';