CREATE TABLE sa.table_n_competitors (
  objid NUMBER,
  dev NUMBER,
  n_expirationdate DATE,
  n_modificationdate DATE,
  n_effectivedate DATE,
  n_name VARCHAR2(50 BYTE)
);
ALTER TABLE sa.table_n_competitors ADD SUPPLEMENTAL LOG GROUP dmtsora1467858019_0 (dev, n_effectivedate, n_expirationdate, n_modificationdate, n_name, objid) ALWAYS;