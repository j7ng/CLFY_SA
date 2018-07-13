CREATE TABLE sa.table_btn_action (
  objid NUMBER,
  title VARCHAR2(80 BYTE),
  button_type NUMBER,
  execution_order NUMBER,
  platform VARCHAR2(80 BYTE),
  command VARCHAR2(255 BYTE),
  is_sync NUMBER,
  dev NUMBER,
  btn_action2control_db NUMBER(*,0)
);
ALTER TABLE sa.table_btn_action ADD SUPPLEMENTAL LOG GROUP dmtsora1718181577_0 (btn_action2control_db, button_type, command, dev, execution_order, is_sync, objid, platform, title) ALWAYS;