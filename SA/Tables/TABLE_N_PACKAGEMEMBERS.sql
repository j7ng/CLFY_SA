CREATE TABLE sa.table_n_packagemembers (
  objid NUMBER,
  dev NUMBER,
  n_packageid NUMBER,
  n_sequencenumber NUMBER,
  n_itemid NUMBER,
  n_itemtypeid NUMBER,
  n_removable NUMBER,
  n_qty VARCHAR2(50 BYTE),
  n_creditcostperitem NUMBER(19,4),
  n_expirationdate DATE,
  n_modificationdate DATE,
  n_effectivedate DATE,
  n_pkgmems2n_packages NUMBER
);
ALTER TABLE sa.table_n_packagemembers ADD SUPPLEMENTAL LOG GROUP dmtsora1260893_0 (dev, n_creditcostperitem, n_effectivedate, n_expirationdate, n_itemid, n_itemtypeid, n_modificationdate, n_packageid, n_pkgmems2n_packages, n_qty, n_removable, n_sequencenumber, objid) ALWAYS;