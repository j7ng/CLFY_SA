CREATE TABLE sa.table_status_chg (
  objid NUMBER,
  creation_time DATE,
  notes LONG,
  dev NUMBER,
  case_status_chg2case NUMBER(*,0),
  subc_stat_chg2subcase NUMBER(*,0),
  status_chg2act_entry NUMBER(*,0),
  status_chger2user NUMBER(*,0),
  c_status_chg2gbst_elm NUMBER(*,0),
  p_status_chg2gbst_elm NUMBER(*,0),
  status_chg2bug NUMBER(*,0),
  status_chg2demand_dtl NUMBER(*,0),
  status_chg2opportunity NUMBER(*,0),
  job_status_chg2job NUMBER(*,0),
  contr_status_chg2contract NUMBER(*,0),
  status_chg2task NUMBER(*,0),
  status_chg2dialogue NUMBER,
  status_chg2probdesc NUMBER
);
ALTER TABLE sa.table_status_chg ADD SUPPLEMENTAL LOG GROUP dmtsora293292558_0 (case_status_chg2case, contr_status_chg2contract, creation_time, c_status_chg2gbst_elm, dev, job_status_chg2job, objid, p_status_chg2gbst_elm, status_chg2act_entry, status_chg2bug, status_chg2demand_dtl, status_chg2dialogue, status_chg2opportunity, status_chg2probdesc, status_chg2task, status_chger2user, subc_stat_chg2subcase) ALWAYS;