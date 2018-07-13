CREATE TABLE sa.x_inv_data_exception (
  objid NUMBER,
  x_esn VARCHAR2(30 BYTE),
  x_old_sim_serial_no VARCHAR2(30 BYTE),
  x_new_sim_serial_no VARCHAR2(30 BYTE),
  x_notify_process VARCHAR2(50 BYTE),
  x_source_system VARCHAR2(30 BYTE),
  x_status VARCHAR2(20 BYTE),
  x_process_date DATE
);
ALTER TABLE sa.x_inv_data_exception ADD SUPPLEMENTAL LOG GROUP dmtsora1253509745_0 (objid, x_esn, x_new_sim_serial_no, x_notify_process, x_old_sim_serial_no, x_process_date, x_source_system, x_status) ALWAYS;