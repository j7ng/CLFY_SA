CREATE TABLE sa.table_csc_revision (
  objid NUMBER,
  description VARCHAR2(20 BYTE),
  csc_date DATE,
  activity_name NUMBER,
  activity_type NUMBER,
  technical_status NUMBER,
  editorial_status NUMBER,
  server_id NUMBER,
  dev NUMBER,
  author2csc_contact NUMBER(*,0),
  rev2csc_admin NUMBER(*,0)
);
ALTER TABLE sa.table_csc_revision ADD SUPPLEMENTAL LOG GROUP dmtsora2049302799_0 (activity_name, activity_type, author2csc_contact, csc_date, description, dev, editorial_status, objid, rev2csc_admin, server_id, technical_status) ALWAYS;