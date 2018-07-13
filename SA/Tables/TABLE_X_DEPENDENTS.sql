CREATE TABLE sa.table_x_dependents (
  objid NUMBER,
  x_first_name VARCHAR2(40 BYTE),
  x_last_name VARCHAR2(40 BYTE),
  x_email VARCHAR2(100 BYTE),
  x_dependents2contact NUMBER
);
ALTER TABLE sa.table_x_dependents ADD SUPPLEMENTAL LOG GROUP dmtsora40725733_0 (objid, x_dependents2contact, x_email, x_first_name, x_last_name) ALWAYS;