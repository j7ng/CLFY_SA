CREATE TABLE sa.x_ntfy_trans_log (
  objid NUMBER,
  x_esn VARCHAR2(30 BYTE),
  x_channel_value NUMBER(10),
  x_sent_status VARCHAR2(30 BYTE),
  x_responce_status VARCHAR2(30 BYTE),
  x_parent_objid NUMBER(10),
  x_sent_date DATE,
  x_fail_code NUMBER(2),
  x_fail_note NUMBER(2),
  x_update_stamp DATE,
  x_update_status VARCHAR2(1 BYTE),
  x_update_user VARCHAR2(255 BYTE),
  tran_log2link_tmplt NUMBER(10),
  tran_log2contact NUMBER,
  tran_log2progrm NUMBER
);
ALTER TABLE sa.x_ntfy_trans_log ADD SUPPLEMENTAL LOG GROUP dmtsora1279480760_0 (objid, tran_log2contact, tran_log2link_tmplt, tran_log2progrm, x_channel_value, x_esn, x_fail_code, x_fail_note, x_parent_objid, x_responce_status, x_sent_date, x_sent_status, x_update_stamp, x_update_status, x_update_user) ALWAYS;
COMMENT ON TABLE sa.x_ntfy_trans_log IS 'Billing notification transaction log';
COMMENT ON COLUMN sa.x_ntfy_trans_log.objid IS 'Internal record number objid';
COMMENT ON COLUMN sa.x_ntfy_trans_log.x_esn IS 'Phone serial number';
COMMENT ON COLUMN sa.x_ntfy_trans_log.x_channel_value IS 'Reference to objid X_NTFY_CHNL_MAS ';
COMMENT ON COLUMN sa.x_ntfy_trans_log.x_sent_status IS 'Status of sent Notification. success or not';
COMMENT ON COLUMN sa.x_ntfy_trans_log.x_responce_status IS 'Status of responce. No data';
COMMENT ON COLUMN sa.x_ntfy_trans_log.x_parent_objid IS 'No data';
COMMENT ON COLUMN sa.x_ntfy_trans_log.x_sent_date IS 'The date notification was sent';
COMMENT ON COLUMN sa.x_ntfy_trans_log.x_fail_code IS 'The code for failed notification. 0 means success';
COMMENT ON COLUMN sa.x_ntfy_trans_log.x_fail_note IS 'Notes for failed notification. No data';
COMMENT ON COLUMN sa.x_ntfy_trans_log.x_update_stamp IS 'Update time';
COMMENT ON COLUMN sa.x_ntfy_trans_log.x_update_status IS 'Update Status';
COMMENT ON COLUMN sa.x_ntfy_trans_log.x_update_user IS 'Update by which user';
COMMENT ON COLUMN sa.x_ntfy_trans_log.tran_log2link_tmplt IS 'Reference to objid of X_NTFY_LINK_TMPLT';
COMMENT ON COLUMN sa.x_ntfy_trans_log.tran_log2contact IS 'No data';
COMMENT ON COLUMN sa.x_ntfy_trans_log.tran_log2progrm IS 'No data';