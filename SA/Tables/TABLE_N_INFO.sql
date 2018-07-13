CREATE TABLE sa.table_n_info (
  objid NUMBER,
  dev NUMBER,
  n_propertyname VARCHAR2(255 BYTE),
  n_propertyvalue VARCHAR2(255 BYTE),
  n_expirationdate DATE,
  n_modificationdate DATE,
  n_effectivedate DATE
);
ALTER TABLE sa.table_n_info ADD SUPPLEMENTAL LOG GROUP dmtsora1914850820_0 (dev, n_effectivedate, n_expirationdate, n_modificationdate, n_propertyname, n_propertyvalue, objid) ALWAYS;