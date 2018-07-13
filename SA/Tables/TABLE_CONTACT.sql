CREATE TABLE sa.table_contact (
  objid NUMBER,
  first_name VARCHAR2(30 BYTE),
  s_first_name VARCHAR2(30 BYTE),
  last_name VARCHAR2(30 BYTE),
  s_last_name VARCHAR2(30 BYTE),
  phone VARCHAR2(20 BYTE),
  fax_number VARCHAR2(20 BYTE),
  e_mail VARCHAR2(80 BYTE),
  mail_stop VARCHAR2(30 BYTE),
  expertise_lev NUMBER,
  title VARCHAR2(30 BYTE),
  hours VARCHAR2(30 BYTE),
  salutation VARCHAR2(20 BYTE),
  mdbk VARCHAR2(80 BYTE),
  state_code NUMBER,
  state_value VARCHAR2(20 BYTE),
  address_1 VARCHAR2(200 BYTE),
  address_2 VARCHAR2(200 BYTE),
  city VARCHAR2(30 BYTE),
  "STATE" VARCHAR2(40 BYTE),
  zipcode VARCHAR2(20 BYTE),
  country VARCHAR2(40 BYTE),
  status NUMBER,
  arch_ind NUMBER,
  alert_ind NUMBER,
  dev NUMBER,
  caller2user NUMBER(*,0),
  contact2x_carrier NUMBER,
  x_cust_id VARCHAR2(80 BYTE),
  x_dateofbirth DATE,
  x_gender VARCHAR2(20 BYTE),
  x_middle_initial VARCHAR2(3 BYTE),
  x_mobilenumber VARCHAR2(20 BYTE),
  x_no_address_flag NUMBER,
  x_no_name_flag NUMBER,
  x_pagernumber VARCHAR2(20 BYTE),
  x_ss_number VARCHAR2(20 BYTE),
  x_no_phone_flag NUMBER,
  update_stamp DATE,
  x_new_esn VARCHAR2(20 BYTE),
  x_email_status NUMBER,
  x_html_ok NUMBER,
  x_email_prompt_count NUMBER,
  x_phone_prompt_count NUMBER,
  x_roadside_status NUMBER,
  x_autopay_update_flag NUMBER,
  mobile_phone VARCHAR2(20 BYTE),
  x_pin VARCHAR2(6 BYTE),
  x_serv_dt_remind_flag NUMBER,
  x_sign_reqd NUMBER,
  x_spl_offer_flg NUMBER,
  x_spl_prog_flg NUMBER
);
ALTER TABLE sa.table_contact ADD SUPPLEMENTAL LOG GROUP dmtsora6773160_0 (address_1, address_2, alert_ind, arch_ind, caller2user, city, contact2x_carrier, country, dev, expertise_lev, e_mail, fax_number, first_name, hours, last_name, mail_stop, mdbk, objid, phone, salutation, "STATE", state_code, state_value, status, s_first_name, s_last_name, title, x_cust_id, x_dateofbirth, x_gender, x_middle_initial, x_mobilenumber, zipcode) ALWAYS;
ALTER TABLE sa.table_contact ADD SUPPLEMENTAL LOG GROUP dmtsora6773160_1 (mobile_phone, update_stamp, x_autopay_update_flag, x_email_prompt_count, x_email_status, x_html_ok, x_new_esn, x_no_address_flag, x_no_name_flag, x_no_phone_flag, x_pagernumber, x_phone_prompt_count, x_pin, x_roadside_status, x_serv_dt_remind_flag, x_sign_reqd, x_spl_offer_flg, x_spl_prog_flg, x_ss_number) ALWAYS;
COMMENT ON TABLE sa.table_contact IS 'To hold contact info of a customer';
COMMENT ON COLUMN sa.table_contact.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_contact.first_name IS 'Contact s first name';
COMMENT ON COLUMN sa.table_contact.last_name IS 'Contact s last name';
COMMENT ON COLUMN sa.table_contact.phone IS 'Contact s phone number which includes area code, number, and extension';
COMMENT ON COLUMN sa.table_contact.fax_number IS 'Contact s fax number which includes area code, number, and extension';
COMMENT ON COLUMN sa.table_contact.e_mail IS 'Contact s primary e-mail address';
COMMENT ON COLUMN sa.table_contact.mail_stop IS 'Contact s internal company mail stop/location/building';
COMMENT ON COLUMN sa.table_contact.expertise_lev IS 'Contact s expertise level. Static list; i.e., Beginner, Novice, Average, Expert';
COMMENT ON COLUMN sa.table_contact.title IS 'Contact s professional title';
COMMENT ON COLUMN sa.table_contact.hours IS 'Contact s business working hours';
COMMENT ON COLUMN sa.table_contact.salutation IS 'A form of address; e.g., Mr., Miss, Mrs';
COMMENT ON COLUMN sa.table_contact.mdbk IS 'Reserved; custom';
COMMENT ON COLUMN sa.table_contact.state_code IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_contact.state_value IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_contact.address_1 IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_contact.address_2 IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_contact.city IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_contact."STATE" IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_contact.zipcode IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_contact.country IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_contact.status IS 'Status of contact; i.e., active/inactive/obsolete';
COMMENT ON COLUMN sa.table_contact.arch_ind IS 'When set to 1, indicates the object is ready for purge/archive';
COMMENT ON COLUMN sa.table_contact.alert_ind IS 'When set to 1, indicates there is an alert related to the contact';
COMMENT ON COLUMN sa.table_contact.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_contact.caller2user IS 'If contact is also a user, this is their user (logon) information; contact user information is indicated on Submitter form';
COMMENT ON COLUMN sa.table_contact.contact2x_carrier IS ' Carrier Relation to its Contacts';
COMMENT ON COLUMN sa.table_contact.x_cust_id IS 'Unique customer number (populated from site_id for customers)';
COMMENT ON COLUMN sa.table_contact.x_dateofbirth IS 'Date of Birth';
COMMENT ON COLUMN sa.table_contact.x_gender IS 'Gender of Customer (Male/Female)';
COMMENT ON COLUMN sa.table_contact.x_middle_initial IS 'Middle Inital';
COMMENT ON COLUMN sa.table_contact.x_mobilenumber IS 'Cellular Phone Number';
COMMENT ON COLUMN sa.table_contact.x_no_address_flag IS 'Flag that shows that address is not provided: 0=does not apply, 1=does apply';
COMMENT ON COLUMN sa.table_contact.x_no_name_flag IS 'Flag that shows that name is not provided: 0=does not apply, 1=does apply';
COMMENT ON COLUMN sa.table_contact.x_pagernumber IS 'Pager Number';
COMMENT ON COLUMN sa.table_contact.x_ss_number IS 'Social Security Number';
COMMENT ON COLUMN sa.table_contact.x_no_phone_flag IS 'Flag that shows that phone number is not provided: 0=does not apply, 1=does apply';
COMMENT ON COLUMN sa.table_contact.update_stamp IS 'Date/time of last update to the contact';
COMMENT ON COLUMN sa.table_contact.x_new_esn IS 'New esn from exchange';
COMMENT ON COLUMN sa.table_contact.x_email_status IS 'Idicates the status of a promotion email process to customer 0 = Unconfirmed, 1 = Confirmed, 2 = redeemed';
COMMENT ON COLUMN sa.table_contact.x_html_ok IS 'Idicates HTML okay to send to customer in email 1 = yes, 0 = no';
COMMENT ON COLUMN sa.table_contact.x_email_prompt_count IS 'TBD';
COMMENT ON COLUMN sa.table_contact.x_phone_prompt_count IS 'TBD';
COMMENT ON COLUMN sa.table_contact.x_roadside_status IS 'TBD';
COMMENT ON COLUMN sa.table_contact.x_autopay_update_flag IS 'Flag that shows that address was updated during enrollment for Autopay: 0=not updated, 1=updated during enrollment';
COMMENT ON COLUMN sa.table_contact.mobile_phone IS 'Contact s mobile phone number which includes area code, number, and extension';
COMMENT ON COLUMN sa.table_contact.x_pin IS 'User PIN';
COMMENT ON COLUMN sa.table_contact.x_serv_dt_remind_flag IS 'Indicates if the contact wants to receive emails for date reminders';
COMMENT ON COLUMN sa.table_contact.x_sign_reqd IS 'Indicates if the contact has signed in';
COMMENT ON COLUMN sa.table_contact.x_spl_offer_flg IS 'Indicates if the contact wants to receive emails for special offers';
COMMENT ON COLUMN sa.table_contact.x_spl_prog_flg IS 'IIndicates if the contact wants to receive emails for special programs';