CREATE TABLE sa.x_program_notify (
  objid NUMBER,
  x_esn VARCHAR2(30 BYTE),
  x_program_name VARCHAR2(255 BYTE),
  x_program_status VARCHAR2(255 BYTE),
  x_notify_process VARCHAR2(50 BYTE),
  x_notify_status VARCHAR2(30 BYTE) DEFAULT 'PENDING',
  x_source_system VARCHAR2(20 BYTE),
  x_process_date DATE,
  x_phone VARCHAR2(20 BYTE),
  x_language VARCHAR2(20 BYTE),
  x_remarks VARCHAR2(4000 BYTE),
  pgm_notify2pgm_objid NUMBER,
  pgm_notify2contact_objid NUMBER,
  pgm_notify2web_user NUMBER,
  pgm_notify2pgm_enroll NUMBER,
  pgm_notify2purch_hdr NUMBER,
  x_message_name VARCHAR2(255 BYTE)
);
ALTER TABLE sa.x_program_notify ADD SUPPLEMENTAL LOG GROUP dmtsora239922436_0 (objid, pgm_notify2contact_objid, pgm_notify2pgm_enroll, pgm_notify2pgm_objid, pgm_notify2purch_hdr, pgm_notify2web_user, x_esn, x_language, x_message_name, x_notify_process, x_notify_status, x_phone, x_process_date, x_program_name, x_program_status, x_remarks, x_source_system) ALWAYS;
COMMENT ON TABLE sa.x_program_notify IS 'This table drives the notification services for billing platform, several jobs and processes insert notification requests in this table, they are later on processed and become email or sms messages.';
COMMENT ON COLUMN sa.x_program_notify.objid IS 'Internal Record ID';
COMMENT ON COLUMN sa.x_program_notify.x_esn IS 'Phone Serial Number, Reference part_Serial_no in table_part_inst';
COMMENT ON COLUMN sa.x_program_notify.x_program_name IS 'Billing Program Name';
COMMENT ON COLUMN sa.x_program_notify.x_program_status IS 'Billing Program Status';
COMMENT ON COLUMN sa.x_program_notify.x_notify_process IS 'Name of the process that is requesting the notification process, ussually batch processes.';
COMMENT ON COLUMN sa.x_program_notify.x_notify_status IS 'Status of the notification request';
COMMENT ON COLUMN sa.x_program_notify.x_source_system IS 'System that in generating the request';
COMMENT ON COLUMN sa.x_program_notify.x_process_date IS 'Date the message was delivered.';
COMMENT ON COLUMN sa.x_program_notify.x_phone IS 'Subscriber Phone Number, used for SMS messaging';
COMMENT ON COLUMN sa.x_program_notify.x_language IS 'Language of the notification';
COMMENT ON COLUMN sa.x_program_notify.x_remarks IS 'Comments';
COMMENT ON COLUMN sa.x_program_notify.pgm_notify2pgm_objid IS 'reference x_program_parameters';
COMMENT ON COLUMN sa.x_program_notify.pgm_notify2contact_objid IS 'reference to table_contact';
COMMENT ON COLUMN sa.x_program_notify.pgm_notify2web_user IS 'Reference to table_web_user, my account record';
COMMENT ON COLUMN sa.x_program_notify.pgm_notify2pgm_enroll IS 'Reference to enrollment record in x_program_enrolled';
COMMENT ON COLUMN sa.x_program_notify.pgm_notify2purch_hdr IS 'reference to x_program_purch_hdr';
COMMENT ON COLUMN sa.x_program_notify.x_message_name IS 'Name of the message requested.';