CREATE TABLE sa.table_install_history (
  objid NUMBER,
  dev NUMBER,
  product VARCHAR2(80 BYTE),
  s_product VARCHAR2(80 BYTE),
  "VERSION" VARCHAR2(20 BYTE),
  comments VARCHAR2(255 BYTE),
  install_date DATE
);
ALTER TABLE sa.table_install_history ADD SUPPLEMENTAL LOG GROUP dmtsora55897168_0 (comments, dev, install_date, objid, product, s_product, "VERSION") ALWAYS;