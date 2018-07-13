CREATE TABLE sa.table_x_link (
  objid NUMBER,
  x_link_url VARCHAR2(100 BYTE),
  x_link_redirect_url VARCHAR2(100 BYTE),
  x_link_desc VARCHAR2(255 BYTE)
);
ALTER TABLE sa.table_x_link ADD SUPPLEMENTAL LOG GROUP dmtsora314783676_0 (objid, x_link_desc, x_link_redirect_url, x_link_url) ALWAYS;