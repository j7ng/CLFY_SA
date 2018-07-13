CREATE TABLE sa.table_x_script_types (
  objid NUMBER,
  x_script_type VARCHAR2(20 BYTE),
  x_link VARCHAR2(20 BYTE),
  x_mandatory NUMBER
);
ALTER TABLE sa.table_x_script_types ADD SUPPLEMENTAL LOG GROUP dmtsora1596677338_0 (objid, x_link, x_mandatory, x_script_type) ALWAYS;