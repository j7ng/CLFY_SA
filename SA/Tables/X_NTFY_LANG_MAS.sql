CREATE TABLE sa.x_ntfy_lang_mas (
  objid NUMBER,
  x_lang VARCHAR2(30 BYTE),
  x_update_stamp DATE,
  x_update_status VARCHAR2(1 BYTE),
  x_update_user VARCHAR2(255 BYTE)
);
ALTER TABLE sa.x_ntfy_lang_mas ADD SUPPLEMENTAL LOG GROUP dmtsora1293208325_0 (objid, x_lang, x_update_stamp, x_update_status, x_update_user) ALWAYS;
COMMENT ON TABLE sa.x_ntfy_lang_mas IS 'Language master for notification';
COMMENT ON COLUMN sa.x_ntfy_lang_mas.objid IS 'Internal record number objid';
COMMENT ON COLUMN sa.x_ntfy_lang_mas.x_lang IS 'language for notification. english or spanish';
COMMENT ON COLUMN sa.x_ntfy_lang_mas.x_update_stamp IS 'Update time';
COMMENT ON COLUMN sa.x_ntfy_lang_mas.x_update_status IS 'Update Status';
COMMENT ON COLUMN sa.x_ntfy_lang_mas.x_update_user IS 'Update by which user';