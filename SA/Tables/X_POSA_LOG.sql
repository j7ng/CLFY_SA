CREATE TABLE sa.x_posa_log (
  objid NUMBER,
  x_serial_num VARCHAR2(100 BYTE) NOT NULL,
  x_domain VARCHAR2(50 BYTE) NOT NULL,
  x_part_number VARCHAR2(100 BYTE),
  x_toss_att_customer VARCHAR2(100 BYTE),
  x_toss_att_location VARCHAR2(100 BYTE),
  x_toss_posa_code VARCHAR2(100 BYTE),
  x_toss_posa_date DATE,
  x_toss_site_id VARCHAR2(40 BYTE),
  x_toss_posa_action VARCHAR2(40 BYTE),
  x_remote_trans_id VARCHAR2(20 BYTE),
  x_sourcesystem VARCHAR2(30 BYTE),
  x_toss_att_trans_date DATE,
  x_access_code VARCHAR2(30 BYTE),
  x_auth_code VARCHAR2(30 BYTE),
  x_reg_no VARCHAR2(30 BYTE),
  x_upc VARCHAR2(30 BYTE),
  x_posa_log_reason VARCHAR2(2000 BYTE),
  x_posa_update_flag VARCHAR2(1 BYTE),
  x_posa_update_date DATE,
  x_posa_log_date DATE
);
ALTER TABLE sa.x_posa_log ADD SUPPLEMENTAL LOG GROUP dmtsora1421306574_0 (objid, x_access_code, x_auth_code, x_domain, x_part_number, x_posa_log_date, x_posa_log_reason, x_posa_update_date, x_posa_update_flag, x_reg_no, x_remote_trans_id, x_serial_num, x_sourcesystem, x_toss_att_customer, x_toss_att_location, x_toss_att_trans_date, x_toss_posa_action, x_toss_posa_code, x_toss_posa_date, x_toss_site_id, x_upc) ALWAYS;