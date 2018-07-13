CREATE TABLE sa.table_n_product (
  objid NUMBER,
  dev NUMBER,
  n_cost NUMBER(19,4),
  n_imagefilename VARCHAR2(255 BYTE),
  n_modificationdate DATE,
  n_optiontreeid NUMBER,
  n_templateid NUMBER,
  n_product2mod_level NUMBER,
  n_prod2n_templates NUMBER,
  n_prod2n_categorytrees NUMBER,
  n_imageurl VARCHAR2(255 BYTE)
);
ALTER TABLE sa.table_n_product ADD SUPPLEMENTAL LOG GROUP dmtsora341704154_0 (dev, n_cost, n_imagefilename, n_imageurl, n_modificationdate, n_optiontreeid, n_prod2n_categorytrees, n_prod2n_templates, n_product2mod_level, n_templateid, objid) ALWAYS;