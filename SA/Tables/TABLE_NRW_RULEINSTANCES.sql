CREATE TABLE sa.table_nrw_ruleinstances (
  objid NUMBER,
  dev NUMBER,
  n_ruleid NUMBER,
  n_itemid NUMBER,
  n_itemtypeid NUMBER,
  n_serializationblob LONG,
  nrw_rinst2nrw_ruletemplates NUMBER
);
ALTER TABLE sa.table_nrw_ruleinstances ADD SUPPLEMENTAL LOG GROUP dmtsora16985668_0 (dev, nrw_rinst2nrw_ruletemplates, n_itemid, n_itemtypeid, n_ruleid, objid) ALWAYS;