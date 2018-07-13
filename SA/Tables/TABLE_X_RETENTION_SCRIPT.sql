CREATE TABLE sa.table_x_retention_script (
  objid NUMBER,
  retention_script2bus_org NUMBER,
  x_flow_name VARCHAR2(30 BYTE),
  ret_action VARCHAR2(30 BYTE),
  x_script_id VARCHAR2(20 BYTE)
);
COMMENT ON TABLE sa.table_x_retention_script IS 'Stores Retention Actions and its Scipt IDs';
COMMENT ON COLUMN sa.table_x_retention_script.objid IS 'Sequence Number: Obj ID';
COMMENT ON COLUMN sa.table_x_retention_script.retention_script2bus_org IS 'Obj ID refers Table_Bus_org';
COMMENT ON COLUMN sa.table_x_retention_script.x_flow_name IS 'Flow Name';
COMMENT ON COLUMN sa.table_x_retention_script.ret_action IS 'Retention Action';
COMMENT ON COLUMN sa.table_x_retention_script.x_script_id IS 'Script ID';