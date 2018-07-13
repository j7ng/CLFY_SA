CREATE TABLE sa.table_n_reports (
  objid NUMBER,
  dev NUMBER,
  n_functionname VARCHAR2(100 BYTE),
  n_shortdescription VARCHAR2(100 BYTE),
  n_longdescription LONG,
  n_expirationdate DATE,
  n_modificationdate DATE,
  n_effectivedate DATE
);
ALTER TABLE sa.table_n_reports ADD SUPPLEMENTAL LOG GROUP dmtsora776740036_0 (dev, n_effectivedate, n_expirationdate, n_functionname, n_modificationdate, n_shortdescription, objid) ALWAYS;