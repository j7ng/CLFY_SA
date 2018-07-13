CREATE TABLE sa.x_ntfy_cat_config (
  objid NUMBER,
  x_notification_pref VARCHAR2(1 BYTE),
  x_description VARCHAR2(255 BYTE),
  x_update_stamp DATE,
  x_update_status VARCHAR2(1 BYTE),
  x_update_user VARCHAR2(255 BYTE),
  cat_config2chnl_mas NUMBER,
  cat_config2cat_mas NUMBER,
  x_batch VARCHAR2(30 BYTE)
);
ALTER TABLE sa.x_ntfy_cat_config ADD SUPPLEMENTAL LOG GROUP dmtsora2065191364_0 (cat_config2cat_mas, cat_config2chnl_mas, objid, x_batch, x_description, x_notification_pref, x_update_stamp, x_update_status, x_update_user) ALWAYS;
COMMENT ON TABLE sa.x_ntfy_cat_config IS 'Billing notification category config';
COMMENT ON COLUMN sa.x_ntfy_cat_config.objid IS 'Internal record number objid';
COMMENT ON COLUMN sa.x_ntfy_cat_config.x_notification_pref IS 'Notification preference code';
COMMENT ON COLUMN sa.x_ntfy_cat_config.x_description IS 'Description for category configuration';
COMMENT ON COLUMN sa.x_ntfy_cat_config.x_update_stamp IS 'Update time';
COMMENT ON COLUMN sa.x_ntfy_cat_config.x_update_status IS 'Update Status';
COMMENT ON COLUMN sa.x_ntfy_cat_config.x_update_user IS 'Update by which user';
COMMENT ON COLUMN sa.x_ntfy_cat_config.cat_config2chnl_mas IS 'Reference to notification channel master';
COMMENT ON COLUMN sa.x_ntfy_cat_config.cat_config2cat_mas IS 'Reference to notification category master';
COMMENT ON COLUMN sa.x_ntfy_cat_config.x_batch IS 'Batch type: Realtime or not';