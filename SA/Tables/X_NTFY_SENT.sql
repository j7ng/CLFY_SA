CREATE TABLE sa.x_ntfy_sent (
  objid NUMBER,
  x_channel_name VARCHAR2(30 BYTE),
  x_channel_msgid VARCHAR2(255 BYTE),
  x_sent_date DATE,
  x_update_stamp DATE,
  x_update_status VARCHAR2(1 BYTE),
  x_update_user VARCHAR2(255 BYTE),
  ntfy_sent2trans_log NUMBER,
  x_message VARCHAR2(4000 BYTE)
);
ALTER TABLE sa.x_ntfy_sent ADD SUPPLEMENTAL LOG GROUP dmtsora266945860_0 (ntfy_sent2trans_log, objid, x_channel_msgid, x_channel_name, x_message, x_sent_date, x_update_stamp, x_update_status, x_update_user) ALWAYS;
COMMENT ON TABLE sa.x_ntfy_sent IS 'Billing notification sent';
COMMENT ON COLUMN sa.x_ntfy_sent.objid IS 'Internal record number objid';
COMMENT ON COLUMN sa.x_ntfy_sent.x_channel_name IS 'Channel via which the Notificatin was sent: email or not';
COMMENT ON COLUMN sa.x_ntfy_sent.x_channel_msgid IS 'Message id';
COMMENT ON COLUMN sa.x_ntfy_sent.x_sent_date IS 'The date notifiation was sent';
COMMENT ON COLUMN sa.x_ntfy_sent.x_update_stamp IS 'The date notifiation was updated';
COMMENT ON COLUMN sa.x_ntfy_sent.x_update_status IS 'Update Status';
COMMENT ON COLUMN sa.x_ntfy_sent.x_update_user IS 'Update by which user';
COMMENT ON COLUMN sa.x_ntfy_sent.ntfy_sent2trans_log IS 'Reference to objid of X_NTFY_TRANS_LOG';
COMMENT ON COLUMN sa.x_ntfy_sent.x_message IS 'Notification message body';