CREATE TABLE sa.table_nws_foldermembers (
  objid NUMBER,
  dev NUMBER,
  n_itemtypeid NUMBER,
  n_itemid NUMBER,
  n_expirationdate DATE,
  n_modificationdate DATE,
  n_effectivedate DATE,
  n_fldrmems2nws_treefolders NUMBER
);
ALTER TABLE sa.table_nws_foldermembers ADD SUPPLEMENTAL LOG GROUP dmtsora1913125362_0 (dev, n_effectivedate, n_expirationdate, n_fldrmems2nws_treefolders, n_itemid, n_itemtypeid, n_modificationdate, objid) ALWAYS;