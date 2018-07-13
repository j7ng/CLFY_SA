CREATE TABLE sa.table_close_bug (
  objid NUMBER,
  creation_time DATE,
  description LONG,
  no_fix NUMBER,
  aging_time NUMBER,
  release_rev VARCHAR2(32 BYTE),
  test_name VARCHAR2(80 BYTE),
  dev NUMBER,
  close_bug2act_entry NUMBER(*,0),
  clbg_oldstat2gbst_elm NUMBER(*,0),
  clbg_newstat2gbst_elm NUMBER(*,0)
);
ALTER TABLE sa.table_close_bug ADD SUPPLEMENTAL LOG GROUP dmtsora1326831461_0 (aging_time, clbg_newstat2gbst_elm, clbg_oldstat2gbst_elm, close_bug2act_entry, creation_time, dev, no_fix, objid, release_rev, test_name) ALWAYS;