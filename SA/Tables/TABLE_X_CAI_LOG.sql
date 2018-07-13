CREATE TABLE sa.table_x_cai_log (
  objid NUMBER,
  "ACTION" CHAR(17 BYTE),
  old_em_val NUMBER,
  new_em_val NUMBER,
  old_ph_val NUMBER,
  new_ph_val NUMBER,
  old_sms_val NUMBER,
  new_sms_val NUMBER,
  old_mail_val NUMBER,
  new_mail_val NUMBER,
  old_mads_val NUMBER,
  new_mads_val NUMBER,
  old_prerec_consent NUMBER,
  new_prerec_consent NUMBER,
  add_info2contact NUMBER,
  add_info2user NUMBER,
  change_date DATE,
  cai_objid NUMBER,
  source_system VARCHAR2(250 BYTE),
  add_info2web_user NUMBER,
  x_esn VARCHAR2(30 BYTE),
  x_min VARCHAR2(30 BYTE)
);
COMMENT ON COLUMN sa.table_x_cai_log.source_system IS 'Originating Source system';
COMMENT ON COLUMN sa.table_x_cai_log.add_info2web_user IS 'FK to the Web user ';
COMMENT ON COLUMN sa.table_x_cai_log.x_esn IS 'PHONE SERIAL NUMBER.';
COMMENT ON COLUMN sa.table_x_cai_log.x_min IS 'Line Number/Phone Number';