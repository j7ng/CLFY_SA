CREATE TABLE sa.table_nrw_ruletemplates (
  objid NUMBER,
  dev NUMBER,
  n_itemtypeid NUMBER,
  n_icondescription VARCHAR2(50 BYTE),
  n_briefdescription VARCHAR2(255 BYTE),
  n_fulldescription VARCHAR2(255 BYTE),
  n_ruleobjectname VARCHAR2(255 BYTE),
  n_iconpath VARCHAR2(255 BYTE),
  n_smalliconpath VARCHAR2(255 BYTE)
);
ALTER TABLE sa.table_nrw_ruletemplates ADD SUPPLEMENTAL LOG GROUP dmtsora1209697900_0 (dev, n_briefdescription, n_fulldescription, n_icondescription, n_iconpath, n_itemtypeid, n_ruleobjectname, n_smalliconpath, objid) ALWAYS;