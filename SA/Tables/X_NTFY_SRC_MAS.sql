CREATE TABLE sa.x_ntfy_src_mas (
  objid NUMBER,
  x_source VARCHAR2(30 BYTE),
  x_description VARCHAR2(255 BYTE),
  x_update_stamp DATE,
  x_update_status VARCHAR2(1 BYTE),
  x_update_user VARCHAR2(255 BYTE)
);
ALTER TABLE sa.x_ntfy_src_mas ADD SUPPLEMENTAL LOG GROUP dmtsora1915924957_0 (objid, x_description, x_source, x_update_stamp, x_update_status, x_update_user) ALWAYS;
COMMENT ON TABLE sa.x_ntfy_src_mas IS 'Billing notification source master';
COMMENT ON COLUMN sa.x_ntfy_src_mas.objid IS 'Internal record number';
COMMENT ON COLUMN sa.x_ntfy_src_mas.x_source IS 'notification Channel source info';
COMMENT ON COLUMN sa.x_ntfy_src_mas.x_description IS 'Description for notification channel source master';
COMMENT ON COLUMN sa.x_ntfy_src_mas.x_update_stamp IS 'Update time';
COMMENT ON COLUMN sa.x_ntfy_src_mas.x_update_status IS 'Update Status';
COMMENT ON COLUMN sa.x_ntfy_src_mas.x_update_user IS 'Update by which user';