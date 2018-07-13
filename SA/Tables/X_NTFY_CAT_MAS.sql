CREATE TABLE sa.x_ntfy_cat_mas (
  objid NUMBER,
  x_cat_name VARCHAR2(255 BYTE),
  x_cat_type VARCHAR2(30 BYTE),
  x_description VARCHAR2(255 BYTE),
  x_update_stamp DATE,
  x_update_status VARCHAR2(1 BYTE),
  x_update_user VARCHAR2(255 BYTE)
);
ALTER TABLE sa.x_ntfy_cat_mas ADD SUPPLEMENTAL LOG GROUP dmtsora47775062_0 (objid, x_cat_name, x_cat_type, x_description, x_update_stamp, x_update_status, x_update_user) ALWAYS;
COMMENT ON TABLE sa.x_ntfy_cat_mas IS 'Billing notification category master';
COMMENT ON COLUMN sa.x_ntfy_cat_mas.objid IS 'Internal record number objid';
COMMENT ON COLUMN sa.x_ntfy_cat_mas.x_cat_name IS 'Name for category master';
COMMENT ON COLUMN sa.x_ntfy_cat_mas.x_cat_type IS 'Type info for category master';
COMMENT ON COLUMN sa.x_ntfy_cat_mas.x_description IS 'Description for category master';
COMMENT ON COLUMN sa.x_ntfy_cat_mas.x_update_stamp IS 'Update time';
COMMENT ON COLUMN sa.x_ntfy_cat_mas.x_update_status IS 'Update Status';
COMMENT ON COLUMN sa.x_ntfy_cat_mas.x_update_user IS 'Update by which user';