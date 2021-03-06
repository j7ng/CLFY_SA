CREATE TABLE sa.x_sd_case_interface (
  id_number VARCHAR2(255 BYTE),
  case_status CHAR,
  process_status CHAR,
  incident_number VARCHAR2(30 BYTE),
  incident_status CHAR,
  creation_date DATE,
  last_udpate_date DATE,
  login_name_crm VARCHAR2(30 BYTE),
  x_case_type VARCHAR2(30 BYTE),
  title VARCHAR2(80 BYTE),
  x_esn VARCHAR2(30 BYTE),
  x_min VARCHAR2(30 BYTE),
  x_iccid VARCHAR2(30 BYTE),
  x_model VARCHAR2(20 BYTE),
  x_carrier_name VARCHAR2(30 BYTE),
  error_code VARCHAR2(200 BYTE),
  flow VARCHAR2(200 BYTE),
  error_desc VARCHAR2(200 BYTE),
  login_name_sd VARCHAR2(50 BYTE),
  attribute1 VARCHAR2(30 BYTE),
  attribute2 VARCHAR2(30 BYTE),
  attribute3 VARCHAR2(30 BYTE),
  attribute4 VARCHAR2(30 BYTE),
  attribute5 VARCHAR2(30 BYTE),
  attribute6 VARCHAR2(30 BYTE),
  attribute7 VARCHAR2(30 BYTE),
  attribute8 VARCHAR2(30 BYTE),
  attribute9 VARCHAR2(30 BYTE),
  attribute10 VARCHAR2(30 BYTE),
  incident_handle VARCHAR2(100 BYTE),
  sd_id NUMBER,
  crm_number NUMBER
);