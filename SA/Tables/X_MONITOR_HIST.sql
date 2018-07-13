CREATE TABLE sa.x_monitor_hist (
  x_monitor_hist_id NUMBER(38) NOT NULL,
  x_line_worked VARCHAR2(1 BYTE),
  x_line_worked_by VARCHAR2(30 BYTE),
  x_line_worked_date DATE
);
ALTER TABLE sa.x_monitor_hist ADD SUPPLEMENTAL LOG GROUP dmtsora606442569_0 (x_line_worked, x_line_worked_by, x_line_worked_date, x_monitor_hist_id) ALWAYS;