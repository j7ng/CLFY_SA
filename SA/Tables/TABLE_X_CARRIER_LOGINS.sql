CREATE TABLE sa.table_x_carrier_logins (
  objid NUMBER,
  x_login_id VARCHAR2(30 BYTE),
  x_password VARCHAR2(30 BYTE),
  x_status VARCHAR2(30 BYTE),
  x_task_id VARCHAR2(30 BYTE),
  x_login2trans_profile NUMBER,
  x_session VARCHAR2(30 BYTE),
  x_update_flag DATE
);
ALTER TABLE sa.table_x_carrier_logins ADD SUPPLEMENTAL LOG GROUP dmtsora1126474736_0 (objid, x_login2trans_profile, x_login_id, x_password, x_session, x_status, x_task_id, x_update_flag) ALWAYS;