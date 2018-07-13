CREATE TABLE sa.centene_actions_log (
  x_esn VARCHAR2(40 BYTE),
  x_action_name VARCHAR2(40 BYTE),
  x_status VARCHAR2(40 BYTE) DEFAULT 'PENDING',
  x_insert_date DATE DEFAULT SYSDATE NOT NULL,
  x_update_stamp DATE DEFAULT SYSDATE NOT NULL,
  x_action_user VARCHAR2(40 BYTE) DEFAULT SYS_CONTEXT ('userenv', 'session_user'),
  old_plan VARCHAR2(100 BYTE),
  new_plan VARCHAR2(100 BYTE),
  extend_months NUMBER
);