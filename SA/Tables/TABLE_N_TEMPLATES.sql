CREATE TABLE sa.table_n_templates (
  objid NUMBER,
  dev NUMBER,
  n_itemtypeid NUMBER,
  n_expirationdate DATE,
  n_modificationdate DATE,
  n_effectivedate DATE,
  n_templatename VARCHAR2(50 BYTE)
);
ALTER TABLE sa.table_n_templates ADD SUPPLEMENTAL LOG GROUP dmtsora994413271_0 (dev, n_effectivedate, n_expirationdate, n_itemtypeid, n_modificationdate, n_templatename, objid) ALWAYS;