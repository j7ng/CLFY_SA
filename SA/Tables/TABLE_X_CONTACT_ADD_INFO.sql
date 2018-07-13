CREATE TABLE sa.table_x_contact_add_info (
  objid NUMBER,
  x_do_not_email NUMBER,
  x_do_not_phone NUMBER,
  x_do_not_sms NUMBER,
  x_do_not_mail NUMBER,
  add_info2contact NUMBER,
  add_info2user NUMBER,
  x_last_update_date DATE,
  add_info2bus_org NUMBER,
  x_dateofbirth DATE,
  x_pin VARCHAR2(6 BYTE),
  x_remind_flag NUMBER,
  x_info_request VARCHAR2(500 BYTE),
  x_prerecorded_consent NUMBER,
  x_do_not_mobile_ads NUMBER,
  x_lang_pref VARCHAR2(30 BYTE),
  x_lang_pref_time DATE,
  x_do_not_loyalty_email NUMBER DEFAULT 0,
  x_do_not_loyalty_sms NUMBER DEFAULT 0,
  source_system VARCHAR2(250 BYTE),
  add_info2web_user NUMBER,
  x_esn VARCHAR2(30 BYTE),
  x_min VARCHAR2(30 BYTE)
);
ALTER TABLE sa.table_x_contact_add_info ADD SUPPLEMENTAL LOG GROUP dmtsora1806421236_0 (add_info2bus_org, add_info2contact, add_info2user, objid, x_dateofbirth, x_do_not_email, x_do_not_mail, x_do_not_phone, x_do_not_sms, x_info_request, x_last_update_date, x_pin, x_remind_flag) ALWAYS;
COMMENT ON TABLE sa.table_x_contact_add_info IS 'This table defines the communication preference of the contacts and it determines if it has relations with a business org';
COMMENT ON COLUMN sa.table_x_contact_add_info.objid IS 'Internal Record ID';
COMMENT ON COLUMN sa.table_x_contact_add_info.x_do_not_email IS 'Do not email flag';
COMMENT ON COLUMN sa.table_x_contact_add_info.x_do_not_phone IS 'Do not phone flag';
COMMENT ON COLUMN sa.table_x_contact_add_info.x_do_not_sms IS 'Do not sms flag';
COMMENT ON COLUMN sa.table_x_contact_add_info.x_do_not_mail IS 'do not mail flag';
COMMENT ON COLUMN sa.table_x_contact_add_info.add_info2contact IS 'Reference to objid in table_contact';
COMMENT ON COLUMN sa.table_x_contact_add_info.add_info2user IS 'Reference to objid table_user';
COMMENT ON COLUMN sa.table_x_contact_add_info.x_last_update_date IS 'Last update Timestamp';
COMMENT ON COLUMN sa.table_x_contact_add_info.add_info2bus_org IS 'Reference to objid in table_bus_org';
COMMENT ON COLUMN sa.table_x_contact_add_info.x_dateofbirth IS 'Date of Birth';
COMMENT ON COLUMN sa.table_x_contact_add_info.x_pin IS 'PIN';
COMMENT ON COLUMN sa.table_x_contact_add_info.x_remind_flag IS 'Remind Flag';
COMMENT ON COLUMN sa.table_x_contact_add_info.x_info_request IS 'Info Request';
COMMENT ON COLUMN sa.table_x_contact_add_info.x_prerecorded_consent IS 'Flag for Prerecorder Concent';
COMMENT ON COLUMN sa.table_x_contact_add_info.x_do_not_mobile_ads IS 'If or not get mobile ads';
COMMENT ON COLUMN sa.table_x_contact_add_info.x_do_not_loyalty_email IS 'Do not send loyalty email flag';
COMMENT ON COLUMN sa.table_x_contact_add_info.x_do_not_loyalty_sms IS 'Do not send loyalty sms flag';
COMMENT ON COLUMN sa.table_x_contact_add_info.source_system IS 'Originating Source system';
COMMENT ON COLUMN sa.table_x_contact_add_info.add_info2web_user IS 'FK to the Web user ';
COMMENT ON COLUMN sa.table_x_contact_add_info.x_esn IS 'PHONE SERIAL NUMBER.';
COMMENT ON COLUMN sa.table_x_contact_add_info.x_min IS 'Line Number/Phone Number';