CREATE TABLE sa.table_cl_keyword (
  objid NUMBER,
  dev NUMBER,
  id_number VARCHAR2(40 BYTE),
  title VARCHAR2(200 BYTE),
  s_title VARCHAR2(200 BYTE)
);
ALTER TABLE sa.table_cl_keyword ADD SUPPLEMENTAL LOG GROUP dmtsora1835212317_0 (dev, id_number, objid, s_title, title) ALWAYS;