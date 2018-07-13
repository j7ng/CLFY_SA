CREATE TABLE sa.table_n_categorymembers (
  objid NUMBER,
  dev NUMBER,
  n_categoryid NUMBER,
  n_itemtypeid NUMBER,
  n_itemid NUMBER,
  n_expirationdate DATE,
  n_modificationdate DATE,
  n_effectivedate DATE,
  n_catmems2n_categories NUMBER
);
ALTER TABLE sa.table_n_categorymembers ADD SUPPLEMENTAL LOG GROUP dmtsora1127414758_0 (dev, n_categoryid, n_catmems2n_categories, n_effectivedate, n_expirationdate, n_itemid, n_itemtypeid, n_modificationdate, objid) ALWAYS;