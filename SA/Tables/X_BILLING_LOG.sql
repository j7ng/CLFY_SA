CREATE TABLE sa.x_billing_log (
  objid NUMBER,
  x_log_category VARCHAR2(255 BYTE),
  x_log_title VARCHAR2(255 BYTE),
  x_log_date DATE DEFAULT sysdate,
  x_details VARCHAR2(1000 BYTE),
  x_additional_details VARCHAR2(255 BYTE),
  x_program_name VARCHAR2(255 BYTE),
  x_nickname VARCHAR2(255 BYTE),
  x_esn VARCHAR2(30 BYTE),
  x_originator VARCHAR2(255 BYTE),
  x_contact_first_name VARCHAR2(30 BYTE),
  x_contact_last_name VARCHAR2(30 BYTE),
  x_agent_name VARCHAR2(30 BYTE),
  x_sourcesystem VARCHAR2(30 BYTE),
  billing_log2web_user NUMBER
);
ALTER TABLE sa.x_billing_log ADD SUPPLEMENTAL LOG GROUP dmtsora695089532_0 (billing_log2web_user, objid, x_additional_details, x_agent_name, x_contact_first_name, x_contact_last_name, x_details, x_esn, x_log_category, x_log_date, x_log_title, x_nickname, x_originator, x_program_name, x_sourcesystem) ALWAYS;
ALTER TABLE sa.x_billing_log ADD SUPPLEMENTAL LOG GROUP dmtsora1910043528_0 (billing_log2web_user, objid, x_additional_details, x_agent_name, x_contact_first_name, x_contact_last_name, x_details, x_esn, x_log_category, x_log_date, x_log_title, x_nickname, x_originator, x_program_name, x_sourcesystem) ALWAYS;
COMMENT ON TABLE sa.x_billing_log IS 'Log Table for Billing Processes.';
COMMENT ON COLUMN sa.x_billing_log.objid IS 'Internal Record ID';
COMMENT ON COLUMN sa.x_billing_log.x_log_category IS 'Log Category/Grouping';
COMMENT ON COLUMN sa.x_billing_log.x_log_title IS 'Log Title';
COMMENT ON COLUMN sa.x_billing_log.x_log_date IS 'Log date';
COMMENT ON COLUMN sa.x_billing_log.x_details IS 'Log Details, Extended Description';
COMMENT ON COLUMN sa.x_billing_log.x_additional_details IS 'Additional Details';
COMMENT ON COLUMN sa.x_billing_log.x_program_name IS 'Billing Program Name';
COMMENT ON COLUMN sa.x_billing_log.x_nickname IS 'ESN Nickname';
COMMENT ON COLUMN sa.x_billing_log.x_esn IS 'Phone Serial Number';
COMMENT ON COLUMN sa.x_billing_log.x_originator IS 'System User ID';
COMMENT ON COLUMN sa.x_billing_log.x_contact_first_name IS 'Contact First Name';
COMMENT ON COLUMN sa.x_billing_log.x_contact_last_name IS 'Contact Last Name';
COMMENT ON COLUMN sa.x_billing_log.x_agent_name IS 'Login Name';
COMMENT ON COLUMN sa.x_billing_log.x_sourcesystem IS 'Source Application';
COMMENT ON COLUMN sa.x_billing_log.billing_log2web_user IS 'Reference to objid in table_web_user';