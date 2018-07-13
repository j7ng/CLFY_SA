CREATE TABLE sa.x_ntfy_bounce_email_trans (
  x_esn VARCHAR2(40 BYTE),
  x_ntfy2web_user NUMBER,
  x_alert_disp_flag NUMBER(1) DEFAULT 0,
  x_insert_date DATE DEFAULT SYSDATE,
  x_update_date DATE DEFAULT SYSDATE,
  x_reason VARCHAR2(255 BYTE),
  x_ntfy2chnl_mas NUMBER
);
COMMENT ON TABLE sa.x_ntfy_bounce_email_trans IS 'Billing notification bounce email transaction';
COMMENT ON COLUMN sa.x_ntfy_bounce_email_trans.x_esn IS 'Phone Serial Number';
COMMENT ON COLUMN sa.x_ntfy_bounce_email_trans.x_ntfy2web_user IS 'Reference to objid in table_web_user';
COMMENT ON COLUMN sa.x_ntfy_bounce_email_trans.x_alert_disp_flag IS 'Alert Display Flag: 0,1';
COMMENT ON COLUMN sa.x_ntfy_bounce_email_trans.x_insert_date IS 'Insert Timestamp';
COMMENT ON COLUMN sa.x_ntfy_bounce_email_trans.x_update_date IS 'Update timestamp';
COMMENT ON COLUMN sa.x_ntfy_bounce_email_trans.x_reason IS 'Reason for email bounce';
COMMENT ON COLUMN sa.x_ntfy_bounce_email_trans.x_ntfy2chnl_mas IS 'Reference to objid in X_NTFY_CHNL_MAS';