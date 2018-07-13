CREATE TABLE sa.table_n_attachments (
  objid NUMBER,
  dev NUMBER,
  n_description VARCHAR2(80 BYTE),
  n_effectivedate DATE,
  n_expirationdate DATE,
  n_itemid NUMBER,
  n_itemtypeid NUMBER,
  n_keywords VARCHAR2(255 BYTE),
  n_localpath VARCHAR2(255 BYTE),
  n_modificationdate DATE,
  n_remotedatasourceid NUMBER,
  n_remotepath VARCHAR2(255 BYTE)
);
ALTER TABLE sa.table_n_attachments ADD SUPPLEMENTAL LOG GROUP dmtsora1560764410_0 (dev, n_description, n_effectivedate, n_expirationdate, n_itemid, n_itemtypeid, n_keywords, n_localpath, n_modificationdate, n_remotedatasourceid, n_remotepath, objid) ALWAYS;