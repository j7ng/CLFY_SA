CREATE TABLE sa.table_contr_inst (
  objid NUMBER,
  description VARCHAR2(255 BYTE),
  s_description VARCHAR2(255 BYTE),
  dev NUMBER,
  contr_inst2contr_itm NUMBER(*,0),
  install_prod2site_part NUMBER(*,0)
);
ALTER TABLE sa.table_contr_inst ADD SUPPLEMENTAL LOG GROUP dmtsora898521966_0 (contr_inst2contr_itm, description, dev, install_prod2site_part, objid, s_description) ALWAYS;