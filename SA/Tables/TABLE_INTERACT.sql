CREATE TABLE sa.table_interact (
  objid NUMBER,
  interact_id VARCHAR2(40 BYTE),
  create_date DATE,
  inserted_by VARCHAR2(40 BYTE),
  external_id VARCHAR2(40 BYTE),
  direction VARCHAR2(20 BYTE),
  "TYPE" VARCHAR2(50 BYTE),
  s_type VARCHAR2(50 BYTE),
  origin VARCHAR2(40 BYTE),
  product VARCHAR2(80 BYTE),
  s_product VARCHAR2(80 BYTE),
  reason_1 VARCHAR2(200 BYTE),
  s_reason_1 VARCHAR2(200 BYTE),
  reason_2 VARCHAR2(200 BYTE),
  s_reason_2 VARCHAR2(200 BYTE),
  reason_3 VARCHAR2(200 BYTE),
  s_reason_3 VARCHAR2(200 BYTE),
  result VARCHAR2(200 BYTE),
  done_in_one NUMBER,
  fee_based NUMBER,
  wait_time NUMBER,
  system_time NUMBER,
  entered_time NUMBER,
  pay_option VARCHAR2(20 BYTE),
  title VARCHAR2(255 BYTE),
  s_title VARCHAR2(255 BYTE),
  start_date DATE,
  end_date DATE,
  last_name VARCHAR2(30 BYTE),
  s_last_name VARCHAR2(30 BYTE),
  first_name VARCHAR2(30 BYTE),
  s_first_name VARCHAR2(30 BYTE),
  phone VARCHAR2(20 BYTE),
  fax_number VARCHAR2(20 BYTE),
  email VARCHAR2(80 BYTE),
  s_email VARCHAR2(80 BYTE),
  zipcode VARCHAR2(20 BYTE),
  arch_ind NUMBER,
  agent VARCHAR2(30 BYTE),
  s_agent VARCHAR2(30 BYTE),
  dev NUMBER,
  interact2user NUMBER(*,0),
  interact2contact NUMBER(*,0),
  interact2lead_source NUMBER(*,0),
  interact2mod_level NUMBER(*,0),
  x_service_type VARCHAR2(50 BYTE),
  interact2case NUMBER,
  interact2opportunity NUMBER,
  member2interact NUMBER,
  interact2blg_argmnt NUMBER,
  interact2fin_accnt NUMBER,
  interact2pay_channel NUMBER,
  interact2site_part NUMBER,
  mobile_phone VARCHAR2(20 BYTE),
  serial_no VARCHAR2(30 BYTE)
);
ALTER TABLE sa.table_interact ADD SUPPLEMENTAL LOG GROUP dmtsora968496313_0 (create_date, direction, done_in_one, end_date, entered_time, external_id, fee_based, first_name, inserted_by, interact_id, last_name, objid, origin, pay_option, phone, product, reason_1, reason_2, reason_3, result, start_date, system_time, s_first_name, s_last_name, s_product, s_reason_1, s_reason_2, s_reason_3, s_title, s_type, title, "TYPE", wait_time) ALWAYS;
ALTER TABLE sa.table_interact ADD SUPPLEMENTAL LOG GROUP dmtsora968496313_1 (agent, arch_ind, dev, email, fax_number, interact2blg_argmnt, interact2case, interact2contact, interact2fin_accnt, interact2lead_source, interact2mod_level, interact2opportunity, interact2pay_channel, interact2site_part, interact2user, member2interact, mobile_phone, serial_no, s_agent, s_email, x_service_type, zipcode) ALWAYS;
COMMENT ON TABLE sa.table_interact IS 'Records interactions with prospects or contacts. Used by forms Interactions (11500) and Select Interacts (11511)';
COMMENT ON COLUMN sa.table_interact.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_interact.interact_id IS 'Unique, system-managed, interaction identifier';
COMMENT ON COLUMN sa.table_interact.create_date IS 'The create date and time of the interact object';
COMMENT ON COLUMN sa.table_interact.inserted_by IS 'Process which created the interact object';
COMMENT ON COLUMN sa.table_interact.external_id IS 'Tracking ID from an external system';
COMMENT ON COLUMN sa.table_interact.direction IS 'The direction of the interaction; e.g., inbound, outbound, etc. From user-defined popup list with default name Interaction Direction';
COMMENT ON COLUMN sa.table_interact."TYPE" IS 'The type of interaction; e.g., call, email, letter, fax, etc. From user-defined popup list with default name Interaction Type';
COMMENT ON COLUMN sa.table_interact.origin IS 'Actual source of interaction. This is from a user-defined popup with default name Interaction Origin';
COMMENT ON COLUMN sa.table_interact.product IS 'Informal product identification. This is from a user-defined popup with default name Interaction Product';
COMMENT ON COLUMN sa.table_interact.reason_1 IS 'Categorization of the reason for the interaction. From user-defined popup list with default name Interaction Reason_1';
COMMENT ON COLUMN sa.table_interact.reason_2 IS 'Categorization of the reason for the interaction. From user-defined popup list with default name Interaction Reason_2';
COMMENT ON COLUMN sa.table_interact.reason_3 IS 'Categorization of the reason for the interaction. From user-defined popup list with default name Interaction Reason_3';
COMMENT ON COLUMN sa.table_interact.result IS 'Standard result code. From user-defined popup list with default name Interaction Result Code';
COMMENT ON COLUMN sa.table_interact.done_in_one IS 'Completed during the interaction; i.e., 0=no, 1=yes, default=0';
COMMENT ON COLUMN sa.table_interact.fee_based IS 'Indicates whether the interaction has a fee; i.e., 0=no 1=yes, default=0';
COMMENT ON COLUMN sa.table_interact.wait_time IS 'Length of time in seconds the customer spent waiting for service';
COMMENT ON COLUMN sa.table_interact.system_time IS 'Computed length of the interaction. End_date minus start_date in seconds';
COMMENT ON COLUMN sa.table_interact.entered_time IS 'Manually entered length of the interaction in seconds. Allows agent to override computed time.  Defaults to system_time';
COMMENT ON COLUMN sa.table_interact.pay_option IS 'Type of payment for the interaction; e.g., contract, incident, pay-per-call, etc.  From user defined pop up list with default name Interaction Pay Option';
COMMENT ON COLUMN sa.table_interact.title IS 'Summary of what took place';
COMMENT ON COLUMN sa.table_interact.start_date IS 'The start date and time of the interaction';
COMMENT ON COLUMN sa.table_interact.end_date IS 'The finish date and time of the interaction';
COMMENT ON COLUMN sa.table_interact.last_name IS 'Respondent last name';
COMMENT ON COLUMN sa.table_interact.first_name IS 'Respondent first name';
COMMENT ON COLUMN sa.table_interact.phone IS 'Respondent primary phone number which includes area code, number, and extension. Defaulted from contact phone';
COMMENT ON COLUMN sa.table_interact.fax_number IS 'Respondent fax number which includes area code, number, and extension. Defaulted from contact.fax_number';
COMMENT ON COLUMN sa.table_interact.email IS 'Respondent e-mail address. Defaults from contact.e_mail';
COMMENT ON COLUMN sa.table_interact.zipcode IS 'Respondent zipcode defaulted from contact/site/address zipcode';
COMMENT ON COLUMN sa.table_interact.arch_ind IS 'When set to 1, indicates the object is ready for purge/archive';
COMMENT ON COLUMN sa.table_interact.agent IS 'Clarify user login name or external agent name';
COMMENT ON COLUMN sa.table_interact.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_interact.interact2user IS 'User who administered the interaction';
COMMENT ON COLUMN sa.table_interact.interact2contact IS 'Related contact if respondent was a contact';
COMMENT ON COLUMN sa.table_interact.interact2lead_source IS 'Related lead source';
COMMENT ON COLUMN sa.table_interact.interact2mod_level IS 'Product revision that was covered in the interaction';
COMMENT ON COLUMN sa.table_interact.x_service_type IS 'Type of Service';
COMMENT ON COLUMN sa.table_interact.interact2case IS 'Case that was covered in the interaction';
COMMENT ON COLUMN sa.table_interact.interact2opportunity IS 'Opportunity that was covered in the interaction';
COMMENT ON COLUMN sa.table_interact.member2interact IS 'The first interaction that took place during a  call';
COMMENT ON COLUMN sa.table_interact.interact2blg_argmnt IS 'Billing arrangement used by an interaction';
COMMENT ON COLUMN sa.table_interact.interact2fin_accnt IS 'Financial account used by an interaction';
COMMENT ON COLUMN sa.table_interact.interact2pay_channel IS 'Pay channel used by an interaction';
COMMENT ON COLUMN sa.table_interact.interact2site_part IS 'Related installed_part';
COMMENT ON COLUMN sa.table_interact.mobile_phone IS 'Contact s mobile phone number which includes area code, number, and extension';
COMMENT ON COLUMN sa.table_interact.serial_no IS 'Installed part s serial number';