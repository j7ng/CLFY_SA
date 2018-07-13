CREATE TABLE sa.x_rqst_mapping (
  objid NUMBER,
  x_func_name VARCHAR2(100 BYTE),
  x_flow_name VARCHAR2(100 BYTE),
  x_error_code VARCHAR2(50 BYTE),
  x_script_name VARCHAR2(30 BYTE),
  x_script_text VARCHAR2(200 BYTE),
  deploy_flag VARCHAR2(1 BYTE) DEFAULT 'Y',
  CONSTRAINT x_rqst_mapping_uniq UNIQUE (x_func_name,x_flow_name,x_error_code,x_script_name)
);
COMMENT ON TABLE sa.x_rqst_mapping IS 'Error Request Mapping Table, it determines whar error message to show.';
COMMENT ON COLUMN sa.x_rqst_mapping.objid IS 'Internal Record ID';
COMMENT ON COLUMN sa.x_rqst_mapping.x_func_name IS 'Function Name';
COMMENT ON COLUMN sa.x_rqst_mapping.x_flow_name IS 'Flow Name';
COMMENT ON COLUMN sa.x_rqst_mapping.x_error_code IS 'Error Code';
COMMENT ON COLUMN sa.x_rqst_mapping.x_script_name IS 'Script Name, equivalent to x_script_type||"_"||x_script_id from table_x_scripts';
COMMENT ON COLUMN sa.x_rqst_mapping.x_script_text IS 'Script Description';
COMMENT ON COLUMN sa.x_rqst_mapping.deploy_flag IS 'Deployment Flag: Y,N';