CREATE TABLE sa.x_posa_road (
  objid NUMBER,
  tf_part_num_parent VARCHAR2(100 BYTE) NOT NULL,
  tf_serial_num VARCHAR2(100 BYTE) NOT NULL,
  toss_att_customer VARCHAR2(100 BYTE),
  toss_att_location VARCHAR2(100 BYTE),
  toss_posa_code VARCHAR2(100 BYTE),
  toss_posa_date DATE,
  tf_extract_flag VARCHAR2(1 BYTE),
  tf_extract_date DATE,
  toss_site_id VARCHAR2(40 BYTE),
  toss_posa_action VARCHAR2(40 BYTE),
  remote_trans_id VARCHAR2(20 BYTE),
  sourcesystem VARCHAR2(30 BYTE),
  toss_att_trans_date DATE
);
ALTER TABLE sa.x_posa_road ADD SUPPLEMENTAL LOG GROUP dmtsora1301469043_0 (objid, remote_trans_id, sourcesystem, tf_extract_date, tf_extract_flag, tf_part_num_parent, tf_serial_num, toss_att_customer, toss_att_location, toss_att_trans_date, toss_posa_action, toss_posa_code, toss_posa_date, toss_site_id) ALWAYS;