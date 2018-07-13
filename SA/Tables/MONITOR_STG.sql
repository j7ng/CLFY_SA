CREATE TABLE sa.monitor_stg (
  s_monitor_id NUMBER(38),
  s_x_date_mvt DATE,
  s_x_phone NUMBER(20),
  s_x_esn VARCHAR2(30 BYTE),
  s_x_cust_id VARCHAR2(80 BYTE),
  s_x_carrier_id NUMBER(10),
  s_x_dealer_id VARCHAR2(80 BYTE),
  s_x_action VARCHAR2(30 BYTE),
  s_x_action_type_id NUMBER(1),
  s_x_reason_code NUMBER(3),
  s_x_line_worked VARCHAR2(1 BYTE),
  s_x_line_worked_by VARCHAR2(30 BYTE),
  s_x_line_worked_date DATE,
  s_x_pin VARCHAR2(6 BYTE),
  s_x_manufacturer VARCHAR2(15 BYTE),
  s_x_initial_act_date DATE,
  s_x_end_user VARCHAR2(30 BYTE),
  s_x_ig_status VARCHAR2(10 BYTE),
  s_x_ig_stgor VARCHAR2(80 BYTE)
);
ALTER TABLE sa.monitor_stg ADD SUPPLEMENTAL LOG GROUP dmtsora766716670_0 (s_monitor_id, s_x_action, s_x_action_type_id, s_x_carrier_id, s_x_cust_id, s_x_date_mvt, s_x_dealer_id, s_x_end_user, s_x_esn, s_x_ig_status, s_x_ig_stgor, s_x_initial_act_date, s_x_line_worked, s_x_line_worked_by, s_x_line_worked_date, s_x_manufacturer, s_x_phone, s_x_pin, s_x_reason_code) ALWAYS;