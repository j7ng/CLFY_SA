CREATE TABLE sa.table_x_case_resolutions (
  objid NUMBER,
  dev NUMBER,
  x_condition VARCHAR2(30 BYTE),
  x_resolution VARCHAR2(50 BYTE),
  x_agent_resolution VARCHAR2(2000 BYTE),
  x_status VARCHAR2(50 BYTE),
  x_cust_resol_eng VARCHAR2(2000 BYTE),
  x_cust_resol_spa VARCHAR2(2000 BYTE),
  x_std_resol_time NUMBER,
  x_active_integration NUMBER,
  x_integration_action VARCHAR2(50 BYTE),
  resol2conf_hdr NUMBER,
  ivr_exit VARCHAR2(100 BYTE),
  ivr_resolution_num VARCHAR2(100 BYTE),
  ivr_resolution_desc VARCHAR2(500 BYTE)
);
ALTER TABLE sa.table_x_case_resolutions ADD SUPPLEMENTAL LOG GROUP dmtsora760730838_0 (dev, objid, resol2conf_hdr, x_active_integration, x_agent_resolution, x_condition, x_cust_resol_eng, x_cust_resol_spa, x_integration_action, x_resolution, x_status, x_std_resol_time) ALWAYS;
COMMENT ON TABLE sa.table_x_case_resolutions IS 'Scripts associated to case resolutions';
COMMENT ON COLUMN sa.table_x_case_resolutions.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_case_resolutions.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_x_case_resolutions.x_condition IS 'OPEN,CLOSED';
COMMENT ON COLUMN sa.table_x_case_resolutions.x_resolution IS 'Short Description';
COMMENT ON COLUMN sa.table_x_case_resolutions.x_agent_resolution IS 'Script ID - Solution description for the agent';
COMMENT ON COLUMN sa.table_x_case_resolutions.x_status IS 'Status Description';
COMMENT ON COLUMN sa.table_x_case_resolutions.x_cust_resol_eng IS 'Text Resolution for Customers in English';
COMMENT ON COLUMN sa.table_x_case_resolutions.x_cust_resol_spa IS 'Customer resolution scripts in spanish';
COMMENT ON COLUMN sa.table_x_case_resolutions.x_std_resol_time IS 'Standard Hours to Fix the Issue';
COMMENT ON COLUMN sa.table_x_case_resolutions.x_active_integration IS '0=No 1=Yes,  Active Warehouse Integration';
COMMENT ON COLUMN sa.table_x_case_resolutions.x_integration_action IS 'Action to Take when case reaches the status (Part Request)';
COMMENT ON COLUMN sa.table_x_case_resolutions.resol2conf_hdr IS 'TBD';
COMMENT ON COLUMN sa.table_x_case_resolutions.ivr_exit IS 'EXIT CODE FOR IVR E.G. TRANSFER, CALL END';
COMMENT ON COLUMN sa.table_x_case_resolutions.ivr_resolution_num IS 'NUMBER IS FOR IVR PROMPT ID';
COMMENT ON COLUMN sa.table_x_case_resolutions.ivr_resolution_desc IS 'DESC ABOUT THE RESOLUTION  NUM ABOVE.';