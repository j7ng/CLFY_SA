CREATE OR REPLACE FORCE VIEW sa.table_employee_appt (employee_objid,appt_objid,start_time,end_time,duration,cell_text) AS
select table_schedule.schedule2employee, table_appointment.objid,
 table_appointment.start_time, table_appointment.end_time,
 table_appointment.duration, table_appointment.cell_text
 from table_schedule, table_appointment
 where table_schedule.schedule2employee IS NOT NULL
 AND table_schedule.objid = table_appointment.appt2schedule
 ;
COMMENT ON TABLE sa.table_employee_appt IS 'Gets appointments for employees';
COMMENT ON COLUMN sa.table_employee_appt.employee_objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_employee_appt.appt_objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_employee_appt.start_time IS 'Appointment start time';
COMMENT ON COLUMN sa.table_employee_appt.end_time IS 'Appointment end time';
COMMENT ON COLUMN sa.table_employee_appt.duration IS 'Length of the appointment in seconds';
COMMENT ON COLUMN sa.table_employee_appt.cell_text IS 'Contains a concatination of locally-selected fields for display by Schedule Tracker. Default is appointment sub_type with start time and end time';