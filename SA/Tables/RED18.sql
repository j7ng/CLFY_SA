CREATE TABLE sa.red18 (
  us_objid NUMBER,
  us_login_name VARCHAR2(30 BYTE),
  em_first_name VARCHAR2(30 BYTE),
  em_last_name VARCHAR2(30 BYTE)
);
ALTER TABLE sa.red18 ADD SUPPLEMENTAL LOG GROUP dmtsora313010157_0 (em_first_name, em_last_name, us_login_name, us_objid) ALWAYS;