CREATE TABLE sa.webcsr_external_links (
  objid NUMBER,
  title VARCHAR2(100 BYTE),
  url VARCHAR2(400 BYTE),
  logo CLOB,
  logo_url VARCHAR2(400 BYTE),
  bus_org VARCHAR2(40 BYTE),
  created_by VARCHAR2(30 BYTE),
  last_upd_by VARCHAR2(30 BYTE),
  created_or_last_upd DATE
);