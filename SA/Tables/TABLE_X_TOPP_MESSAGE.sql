CREATE TABLE sa.table_x_topp_message (
  objid NUMBER,
  x_user_objid NUMBER,
  x_task_objid NUMBER,
  x_modify_date DATE
);
ALTER TABLE sa.table_x_topp_message ADD SUPPLEMENTAL LOG GROUP dmtsora1950763748_0 (objid, x_modify_date, x_task_objid, x_user_objid) ALWAYS;