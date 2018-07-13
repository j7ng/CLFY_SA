CREATE TABLE sa.table_x_zip_code_new (
  objid NUMBER,
  x_zip VARCHAR2(10 BYTE),
  x_city VARCHAR2(30 BYTE),
  x_state VARCHAR2(40 BYTE),
  x_has_warranty NUMBER
);
ALTER TABLE sa.table_x_zip_code_new ADD SUPPLEMENTAL LOG GROUP dmtsora1639268564_0 (objid, x_city, x_has_warranty, x_state, x_zip) ALWAYS;