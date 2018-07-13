CREATE TABLE sa.x_ntfy_tmplt_mas (
  objid NUMBER,
  x_tmplt_name VARCHAR2(255 BYTE),
  x_description VARCHAR2(255 BYTE),
  x_update_stamp DATE,
  x_update_status VARCHAR2(1 BYTE),
  x_update_user VARCHAR2(255 BYTE),
  x_tmplt_id VARCHAR2(255 BYTE),
  tmplt_mas2chnl_mas NUMBER
);
ALTER TABLE sa.x_ntfy_tmplt_mas ADD SUPPLEMENTAL LOG GROUP dmtsora62166608_0 (objid, tmplt_mas2chnl_mas, x_description, x_tmplt_id, x_tmplt_name, x_update_stamp, x_update_status, x_update_user) ALWAYS;
COMMENT ON TABLE sa.x_ntfy_tmplt_mas IS 'Billing notification template master';
COMMENT ON COLUMN sa.x_ntfy_tmplt_mas.objid IS 'Internal record number objid';
COMMENT ON COLUMN sa.x_ntfy_tmplt_mas.x_tmplt_name IS 'Name for Template';
COMMENT ON COLUMN sa.x_ntfy_tmplt_mas.x_description IS 'Description for Templte';
COMMENT ON COLUMN sa.x_ntfy_tmplt_mas.x_update_stamp IS 'Update time';
COMMENT ON COLUMN sa.x_ntfy_tmplt_mas.x_update_status IS 'Update Status';
COMMENT ON COLUMN sa.x_ntfy_tmplt_mas.x_update_user IS 'Update by which user';
COMMENT ON COLUMN sa.x_ntfy_tmplt_mas.x_tmplt_id IS 'Id for Template';
COMMENT ON COLUMN sa.x_ntfy_tmplt_mas.tmplt_mas2chnl_mas IS 'Reference to notificaion channel master';