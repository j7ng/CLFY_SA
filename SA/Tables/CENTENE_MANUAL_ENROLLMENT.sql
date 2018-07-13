CREATE TABLE sa.centene_manual_enrollment (
  x_esn VARCHAR2(30 BYTE),
  pgm_enroll2site_part NUMBER,
  pgm_enroll2part_inst NUMBER,
  pgm_enroll2contact NUMBER,
  pgm_enroll2web_user NUMBER,
  x_zip_code VARCHAR2(10 BYTE) DEFAULT '33178',
  x_state VARCHAR2(10 BYTE) DEFAULT 'FL',
  x_status VARCHAR2(20 BYTE) DEFAULT 'PENDING',
  pgm_enroll2pgm_parameter NUMBER,
  x_insert_date DATE DEFAULT SYSDATE,
  x_update_date DATE
);