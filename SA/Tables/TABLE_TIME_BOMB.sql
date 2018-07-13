CREATE TABLE sa.table_time_bomb (
  objid NUMBER,
  title VARCHAR2(40 BYTE),
  escalate_time DATE,
  end_time DATE,
  focus_lowid NUMBER,
  focus_type NUMBER,
  suppl_info LONG,
  time_period NUMBER,
  flags NUMBER,
  left_repeat NUMBER,
  report_title VARCHAR2(80 BYTE),
  property_set VARCHAR2(80 BYTE),
  "USERS" VARCHAR2(30 BYTE),
  dev NUMBER,
  trckr_info2com_tmplte NUMBER(*,0),
  cmit_creator2employee NUMBER(*,0),
  rule2com_tmplte NUMBER(*,0),
  time_bomb2param NUMBER(*,0),
  creation_time DATE
);