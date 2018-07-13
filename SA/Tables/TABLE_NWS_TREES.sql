CREATE TABLE sa.table_nws_trees (
  objid NUMBER,
  dev NUMBER,
  n_treename VARCHAR2(255 BYTE),
  n_itemtypeid NUMBER,
  n_itemid NUMBER,
  n_expirationdate DATE,
  n_modificationdate DATE,
  n_effectivedate DATE
);
ALTER TABLE sa.table_nws_trees ADD SUPPLEMENTAL LOG GROUP dmtsora307647515_0 (dev, n_effectivedate, n_expirationdate, n_itemid, n_itemtypeid, n_modificationdate, n_treename, objid) ALWAYS;