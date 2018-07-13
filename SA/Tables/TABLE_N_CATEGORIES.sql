CREATE TABLE sa.table_n_categories (
  objid NUMBER,
  dev NUMBER,
  n_itemtypeid NUMBER,
  n_sequencenumber NUMBER,
  n_name VARCHAR2(50 BYTE),
  n_parentid NUMBER,
  n_optiontreeid NUMBER,
  n_expirationdate DATE,
  n_modificationdate DATE,
  n_effectivedate DATE,
  n_cats2n_categorytrees NUMBER,
  n_child2n_categories NUMBER
);
ALTER TABLE sa.table_n_categories ADD SUPPLEMENTAL LOG GROUP dmtsora1737807615_0 (dev, n_cats2n_categorytrees, n_child2n_categories, n_effectivedate, n_expirationdate, n_itemtypeid, n_modificationdate, n_name, n_optiontreeid, n_parentid, n_sequencenumber, objid) ALWAYS;