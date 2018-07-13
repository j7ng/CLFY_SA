CREATE TABLE sa.x_ntfy_chnl_mas (
  objid NUMBER,
  x_chnl_name VARCHAR2(30 BYTE),
  x_description VARCHAR2(255 BYTE),
  x_update_stamp DATE,
  x_update_status VARCHAR2(1 BYTE),
  x_update_user VARCHAR2(255 BYTE)
);
ALTER TABLE sa.x_ntfy_chnl_mas ADD SUPPLEMENTAL LOG GROUP dmtsora1944085449_0 (objid, x_chnl_name, x_description, x_update_stamp, x_update_status, x_update_user) ALWAYS;
COMMENT ON TABLE sa.x_ntfy_chnl_mas IS 'Billing notification channel master';
COMMENT ON COLUMN sa.x_ntfy_chnl_mas.objid IS 'Internal record number objid';
COMMENT ON COLUMN sa.x_ntfy_chnl_mas.x_chnl_name IS 'Name for channel';
COMMENT ON COLUMN sa.x_ntfy_chnl_mas.x_description IS 'Description for channel';
COMMENT ON COLUMN sa.x_ntfy_chnl_mas.x_update_stamp IS 'Update time';
COMMENT ON COLUMN sa.x_ntfy_chnl_mas.x_update_status IS 'Update Status';
COMMENT ON COLUMN sa.x_ntfy_chnl_mas.x_update_user IS 'Update by which user';