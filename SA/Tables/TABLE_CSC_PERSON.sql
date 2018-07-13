CREATE TABLE sa.table_csc_person (
  objid NUMBER,
  first_name VARCHAR2(30 BYTE),
  s_first_name VARCHAR2(30 BYTE),
  last_name VARCHAR2(30 BYTE),
  s_last_name VARCHAR2(30 BYTE),
  title VARCHAR2(30 BYTE),
  contact_type VARCHAR2(255 BYTE),
  salutation VARCHAR2(20 BYTE),
  communication_mode NUMBER,
  server_id NUMBER,
  dev NUMBER,
  csc_person2csc_address NUMBER(*,0)
);
ALTER TABLE sa.table_csc_person ADD SUPPLEMENTAL LOG GROUP dmtsora158967027_0 (communication_mode, contact_type, csc_person2csc_address, dev, first_name, last_name, objid, salutation, server_id, s_first_name, s_last_name, title) ALWAYS;