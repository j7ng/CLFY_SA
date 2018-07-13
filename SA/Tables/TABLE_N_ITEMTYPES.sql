CREATE TABLE sa.table_n_itemtypes (
  objid NUMBER,
  dev NUMBER,
  n_itemtypeid NUMBER,
  n_itemtypename VARCHAR2(50 BYTE),
  n_expirationdate DATE,
  n_modificationdate DATE,
  n_effectivedate DATE
);
ALTER TABLE sa.table_n_itemtypes ADD SUPPLEMENTAL LOG GROUP dmtsora1808301280_0 (dev, n_effectivedate, n_expirationdate, n_itemtypeid, n_itemtypename, n_modificationdate, objid) ALWAYS;