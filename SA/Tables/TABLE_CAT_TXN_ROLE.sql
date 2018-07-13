CREATE TABLE sa.table_cat_txn_role (
  objid NUMBER,
  role_name VARCHAR2(80 BYTE),
  focus_type NUMBER,
  "ACTIVE" NUMBER,
  dev NUMBER,
  cat_txn_role2exch_cat NUMBER(*,0),
  cat_txn_role2exch_txn NUMBER(*,0)
);
ALTER TABLE sa.table_cat_txn_role ADD SUPPLEMENTAL LOG GROUP dmtsora1878689042_0 ("ACTIVE", cat_txn_role2exch_cat, cat_txn_role2exch_txn, dev, focus_type, objid, role_name) ALWAYS;