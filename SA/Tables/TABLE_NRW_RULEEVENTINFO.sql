CREATE TABLE sa.table_nrw_ruleeventinfo (
  objid NUMBER,
  dev NUMBER,
  n_itemid NUMBER,
  n_itemtypeid NUMBER,
  n_generatedevents LONG
);
ALTER TABLE sa.table_nrw_ruleeventinfo ADD SUPPLEMENTAL LOG GROUP dmtsora1293034535_0 (dev, n_itemid, n_itemtypeid, objid) ALWAYS;