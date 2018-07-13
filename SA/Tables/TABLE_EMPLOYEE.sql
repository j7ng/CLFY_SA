CREATE TABLE sa.table_employee (
  objid NUMBER,
  first_name VARCHAR2(50 BYTE),
  s_first_name VARCHAR2(50 BYTE),
  last_name VARCHAR2(50 BYTE),
  s_last_name VARCHAR2(50 BYTE),
  mail_stop VARCHAR2(30 BYTE),
  phone VARCHAR2(20 BYTE),
  alt_phone VARCHAR2(20 BYTE),
  fax VARCHAR2(20 BYTE),
  beeper VARCHAR2(20 BYTE),
  e_mail VARCHAR2(80 BYTE),
  labor_rate NUMBER,
  field_eng NUMBER,
  acting_supvr NUMBER,
  available NUMBER,
  avail_note VARCHAR2(255 BYTE),
  employee_no VARCHAR2(8 BYTE),
  normal_biz_high VARCHAR2(32 BYTE),
  normal_biz_mid VARCHAR2(32 BYTE),
  normal_biz_low VARCHAR2(32 BYTE),
  after_biz_high VARCHAR2(32 BYTE),
  after_biz_mid VARCHAR2(32 BYTE),
  after_biz_low VARCHAR2(32 BYTE),
  work_group VARCHAR2(80 BYTE),
  wg_strt_date DATE,
  site_strt_date DATE,
  voice_mail_box VARCHAR2(20 BYTE),
  local_login VARCHAR2(30 BYTE),
  local_password VARCHAR2(30 BYTE),
  allow_proxy NUMBER,
  printer VARCHAR2(30 BYTE),
  on_call_hw NUMBER,
  on_call_sw NUMBER,
  case_threshold NUMBER,
  dev NUMBER,
  employee2user NUMBER(*,0),
  emp_supvr2employee NUMBER(*,0),
  supp_person_off2site NUMBER(*,0),
  cc_list2bug NUMBER(*,0),
  empl_hrs2biz_cal_hdr NUMBER(*,0),
  employee2contact NUMBER(*,0),
  x_dashboard NUMBER,
  x_error_code_maint NUMBER,
  x_order_types NUMBER,
  x_q_maint NUMBER,
  x_select_trans_prof NUMBER,
  x_update_set NUMBER,
  x_allow_script NUMBER,
  x_allow_roadside NUMBER,
  salutation VARCHAR2(20 BYTE),
  title VARCHAR2(60 BYTE)
);
ALTER TABLE sa.table_employee ADD SUPPLEMENTAL LOG GROUP dmtsora2096802511_0 (acting_supvr, after_biz_high, after_biz_low, after_biz_mid, allow_proxy, alt_phone, available, avail_note, beeper, employee_no, e_mail, fax, field_eng, first_name, labor_rate, last_name, local_login, local_password, mail_stop, normal_biz_high, normal_biz_low, normal_biz_mid, objid, on_call_hw, on_call_sw, phone, printer, site_strt_date, s_first_name, s_last_name, voice_mail_box, wg_strt_date, work_group) ALWAYS;
ALTER TABLE sa.table_employee ADD SUPPLEMENTAL LOG GROUP dmtsora2096802511_1 (case_threshold, cc_list2bug, dev, employee2contact, employee2user, empl_hrs2biz_cal_hdr, emp_supvr2employee, salutation, supp_person_off2site, title, x_allow_roadside, x_allow_script, x_dashboard, x_error_code_maint, x_order_types, x_q_maint, x_select_trans_prof, x_update_set) ALWAYS;
COMMENT ON TABLE sa.table_employee IS 'Employee object; generally a ClearSupport user';
COMMENT ON COLUMN sa.table_employee.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_employee.first_name IS 'Employee first name';
COMMENT ON COLUMN sa.table_employee.last_name IS 'Employee last name';
COMMENT ON COLUMN sa.table_employee.mail_stop IS 'Employee s internal company mail address/stop';
COMMENT ON COLUMN sa.table_employee.phone IS 'Employee s primary phone number which includes area code, number, and extension';
COMMENT ON COLUMN sa.table_employee.alt_phone IS 'Employee s alternate phone number which includes area code, number, and extension';
COMMENT ON COLUMN sa.table_employee.fax IS 'Employee s fax number which includes area code, number, and extension';
COMMENT ON COLUMN sa.table_employee.beeper IS 'Employee s beeper number which includes area code and number';
COMMENT ON COLUMN sa.table_employee.e_mail IS 'Employee s e-mail address';
COMMENT ON COLUMN sa.table_employee.labor_rate IS 'Employee s hourly labor rate';
COMMENT ON COLUMN sa.table_employee.field_eng IS 'Indicates if the employee is a field engineer. Reserved; not used';
COMMENT ON COLUMN sa.table_employee.acting_supvr IS 'Indicates if the employee is an acting supervisor';
COMMENT ON COLUMN sa.table_employee.available IS 'Reserved; indicates employee s availability; was used in the availability command; no longer supported';
COMMENT ON COLUMN sa.table_employee.avail_note IS 'Reserved; indicates reason for employee unavailability; was used in the availability command; no longer supported';
COMMENT ON COLUMN sa.table_employee.employee_no IS 'Employee s ID number';
COMMENT ON COLUMN sa.table_employee.normal_biz_high IS 'High urgency notify method during business hours';
COMMENT ON COLUMN sa.table_employee.normal_biz_mid IS 'Medium urgency notify method during business hours';
COMMENT ON COLUMN sa.table_employee.normal_biz_low IS 'Low urgency notify method during business hours';
COMMENT ON COLUMN sa.table_employee.after_biz_high IS 'High urgency notify method after business hours';
COMMENT ON COLUMN sa.table_employee.after_biz_mid IS 'Medium urgency notify method after business hours';
COMMENT ON COLUMN sa.table_employee.after_biz_low IS 'Low urgency notify method after business hours';
COMMENT ON COLUMN sa.table_employee.work_group IS 'Work group to which employee belongs. From a user-defined pop up with default name WORKGROUP';
COMMENT ON COLUMN sa.table_employee.wg_strt_date IS 'Date employee started with current work group';
COMMENT ON COLUMN sa.table_employee.site_strt_date IS 'Date employee began at current site<office>';
COMMENT ON COLUMN sa.table_employee.voice_mail_box IS 'Employee voice mail box number. Reserved; not used';
COMMENT ON COLUMN sa.table_employee.local_login IS 'Employee host login name; used for the case dial site form for remote dialups';
COMMENT ON COLUMN sa.table_employee.local_password IS 'Employee host password';
COMMENT ON COLUMN sa.table_employee.allow_proxy IS 'Indicates if the employee can allow another employee to switch to';
COMMENT ON COLUMN sa.table_employee.printer IS 'Employee s printer name. This is from a user-defined popup with default name DEFAULT_PRINTER';
COMMENT ON COLUMN sa.table_employee.on_call_hw IS 'Reserved; custom. When checked, indicates employee is available to be paged for hardware calls';
COMMENT ON COLUMN sa.table_employee.on_call_sw IS 'Reserved; custom. When checked, indicates employee is available to be paged for software calls';
COMMENT ON COLUMN sa.table_employee.case_threshold IS 'Reserved; custom. Highest number of open cases for employee for workload monitoring';
COMMENT ON COLUMN sa.table_employee.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_employee.employee2user IS 'Relation to employee s database user record';
COMMENT ON COLUMN sa.table_employee.emp_supvr2employee IS 'Employee s supervisor';
COMMENT ON COLUMN sa.table_employee.supp_person_off2site IS 'Employee s office site';
COMMENT ON COLUMN sa.table_employee.cc_list2bug IS 'Change requests that employee is cc"d on. Reserved; obsolete';
COMMENT ON COLUMN sa.table_employee.empl_hrs2biz_cal_hdr IS 'Employee s business hours';
COMMENT ON COLUMN sa.table_employee.employee2contact IS 'For employees that are contacts, the related contact. Reserved; not used';
COMMENT ON COLUMN sa.table_employee.x_dashboard IS 'not used';
COMMENT ON COLUMN sa.table_employee.x_error_code_maint IS 'not used';
COMMENT ON COLUMN sa.table_employee.x_order_types IS 'Access to Order Types: 0,1';
COMMENT ON COLUMN sa.table_employee.x_q_maint IS 'not used';
COMMENT ON COLUMN sa.table_employee.x_select_trans_prof IS 'not used';
COMMENT ON COLUMN sa.table_employee.x_update_set IS 'not used';
COMMENT ON COLUMN sa.table_employee.x_allow_script IS 'not used';
COMMENT ON COLUMN sa.table_employee.x_allow_roadside IS 'not used';
COMMENT ON COLUMN sa.table_employee.salutation IS 'A form of address; e.g., Mr., Miss, Mrs';
COMMENT ON COLUMN sa.table_employee.title IS 'Employee s professional title';