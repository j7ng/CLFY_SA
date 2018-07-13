CREATE TABLE sa.red2_18 (
  us_objid NUMBER,
  us_login_name VARCHAR2(30 BYTE),
  em_first_name VARCHAR2(30 BYTE),
  em_last_name VARCHAR2(30 BYTE)
);
ALTER TABLE sa.red2_18 ADD SUPPLEMENTAL LOG GROUP dmtsora1102383765_0 (em_first_name, em_last_name, us_login_name, us_objid) ALWAYS;