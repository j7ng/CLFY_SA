CREATE TABLE sa.tmp_table_gbst_elm (
  objid NUMBER,
  title VARCHAR2(80 BYTE),
  s_title VARCHAR2(80 BYTE),
  "RANK" NUMBER,
  "STATE" NUMBER,
  description VARCHAR2(255 BYTE),
  dev NUMBER,
  gbst_elm2gbst_lst NUMBER(*,0),
  addnl_info VARCHAR2(255 BYTE)
);