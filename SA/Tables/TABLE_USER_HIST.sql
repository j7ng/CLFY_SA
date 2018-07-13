CREATE TABLE sa.table_user_hist (
  objid NUMBER,
  user_hist2user NUMBER,
  column_name VARCHAR2(30 BYTE),
  old_value VARCHAR2(255 BYTE),
  new_value VARCHAR2(255 BYTE),
  changed_date DATE,
  changed_by VARCHAR2(30 BYTE),
  os_user VARCHAR2(30 BYTE),
  trig_event VARCHAR2(1 BYTE)
);