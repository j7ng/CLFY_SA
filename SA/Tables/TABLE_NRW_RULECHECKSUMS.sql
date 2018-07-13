CREATE TABLE sa.table_nrw_rulechecksums (
  objid NUMBER,
  dev NUMBER,
  n_instanceid NUMBER,
  n_eventname VARCHAR2(255 BYTE),
  n_checksum LONG,
  nrw_chk2nrw_ruleinstances NUMBER
);
ALTER TABLE sa.table_nrw_rulechecksums ADD SUPPLEMENTAL LOG GROUP dmtsora95853514_0 (dev, nrw_chk2nrw_ruleinstances, n_eventname, n_instanceid, objid) ALWAYS;