CREATE TABLE sa.table_n_option (
  objid NUMBER,
  dev NUMBER,
  n_templateid NUMBER,
  n_cost NUMBER(19,4),
  n_imagefilename VARCHAR2(255 BYTE),
  n_modificationdate DATE,
  n_option2mod_level NUMBER,
  n_optn2n_templates NUMBER,
  n_optn2n_categorytrees NUMBER,
  n_imageurl VARCHAR2(255 BYTE)
);
ALTER TABLE sa.table_n_option ADD SUPPLEMENTAL LOG GROUP dmtsora2003372423_0 (dev, n_cost, n_imagefilename, n_imageurl, n_modificationdate, n_option2mod_level, n_optn2n_categorytrees, n_optn2n_templates, n_templateid, objid) ALWAYS;