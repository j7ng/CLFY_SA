CREATE TABLE sa.table_x_hist_stats (
  objid NUMBER,
  task_id VARCHAR2(25 BYTE),
  task_objid NUMBER,
  event VARCHAR2(40 BYTE),
  time_stamp DATE,
  login_name VARCHAR2(40 BYTE),
  event_time NUMBER,
  "QUEUE" VARCHAR2(30 BYTE),
  carrier_mkt VARCHAR2(40 BYTE),
  order_type VARCHAR2(40 BYTE),
  hour_of_day NUMBER,
  x_hist_stats2act_entry NUMBER,
  x_hist_stats2task NUMBER,
  x_hist_stats2queue NUMBER
);
ALTER TABLE sa.table_x_hist_stats ADD SUPPLEMENTAL LOG GROUP dmtsora49218869_0 (carrier_mkt, event, event_time, hour_of_day, login_name, objid, order_type, "QUEUE", task_id, task_objid, time_stamp, x_hist_stats2act_entry, x_hist_stats2queue, x_hist_stats2task) ALWAYS;