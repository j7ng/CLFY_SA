CREATE TABLE sa.x_vas_params (
  objid NUMBER,
  vas_param_name VARCHAR2(30 BYTE),
  vas_param_info VARCHAR2(80 BYTE),
  vas_param_rules VARCHAR2(80 BYTE)
);
COMMENT ON TABLE sa.x_vas_params IS 'PARAMETERS OF THE SERVICES';
COMMENT ON COLUMN sa.x_vas_params.objid IS 'UNIQUE KEY OF X_VAS_PARAMS TABLE';
COMMENT ON COLUMN sa.x_vas_params.vas_param_name IS 'PARAMETER';
COMMENT ON COLUMN sa.x_vas_params.vas_param_info IS 'DESCRIPTION OF THE PARAMETER';
COMMENT ON COLUMN sa.x_vas_params.vas_param_rules IS 'HOW YOU USE THE PARAMETER';