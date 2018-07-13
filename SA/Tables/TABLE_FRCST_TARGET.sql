CREATE TABLE sa.table_frcst_target (
  objid NUMBER,
  comments VARCHAR2(255 BYTE),
  "NAME" VARCHAR2(80 BYTE),
  s_name VARCHAR2(80 BYTE),
  amount NUMBER(19,4),
  line VARCHAR2(20 BYTE),
  start_date DATE,
  end_date DATE,
  "FAMILY" VARCHAR2(20 BYTE),
  id_number VARCHAR2(32 BYTE),
  arch_ind NUMBER,
  dev NUMBER,
  frcst_target2frcst_grp NUMBER,
  frcst_target2user NUMBER,
  frcst_target2currency NUMBER,
  frcst2territory NUMBER,
  frcst_stat2gbst_elm NUMBER,
  frcst2bus_org NUMBER,
  trgt_owner2usr_ter_role NUMBER
);
ALTER TABLE sa.table_frcst_target ADD SUPPLEMENTAL LOG GROUP dmtsora394833895_0 (amount, arch_ind, comments, dev, end_date, "FAMILY", frcst2bus_org, frcst2territory, frcst_stat2gbst_elm, frcst_target2currency, frcst_target2frcst_grp, frcst_target2user, id_number, line, "NAME", objid, start_date, s_name, trgt_owner2usr_ter_role) ALWAYS;