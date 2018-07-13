CREATE TABLE sa.x_ntfy_batch (
  objid NUMBER,
  x_channel_name VARCHAR2(30 BYTE),
  x_message VARCHAR2(4000 BYTE),
  x_update_stamp DATE,
  x_update_status VARCHAR2(1 BYTE),
  x_update_user VARCHAR2(255 BYTE),
  batch2trans_log NUMBER
);
ALTER TABLE sa.x_ntfy_batch ADD SUPPLEMENTAL LOG GROUP dmtsora1855563846_0 (batch2trans_log, objid, x_channel_name, x_message, x_update_stamp, x_update_status, x_update_user) ALWAYS;
COMMENT ON TABLE sa.x_ntfy_batch IS 'Billing notification batch';
COMMENT ON COLUMN sa.x_ntfy_batch.objid IS 'Internal Record ID';
COMMENT ON COLUMN sa.x_ntfy_batch.x_channel_name IS 'CHANNEL info';
COMMENT ON COLUMN sa.x_ntfy_batch.x_message IS 'Message body';
COMMENT ON COLUMN sa.x_ntfy_batch.x_update_stamp IS 'update time';
COMMENT ON COLUMN sa.x_ntfy_batch.x_update_status IS 'update status';
COMMENT ON COLUMN sa.x_ntfy_batch.x_update_user IS 'update by user';
COMMENT ON COLUMN sa.x_ntfy_batch.batch2trans_log IS 'Reference to objid of table X_NTFY_TRANS_LOG';