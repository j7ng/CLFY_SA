CREATE OR REPLACE FORCE VIEW sa.table_appt_schedule (appt_objid,sch_objid,start_time,end_time,duration,description,class_title,s_class_title,type_title,s_type_title) AS
select table_appointment.objid, table_appointment.appt2schedule,
 table_appointment.start_time, table_appointment.end_time,
 table_appointment.duration, table_appointment.description,
 table_class_gse.title, table_class_gse.S_title, table_type_gse.title, table_type_gse.S_title
 from table_gbst_elm table_class_gse, table_gbst_elm table_type_gse, table_appointment
 where table_class_gse.objid = table_appointment.appt2appt_type
 AND table_appointment.appt2schedule IS NOT NULL
 AND table_type_gse.objid = table_appointment.appt2sub_type
 ;
COMMENT ON TABLE sa.table_appt_schedule IS 'Used by form Schedule (282), Unavailability Alert (283)';
COMMENT ON COLUMN sa.table_appt_schedule.appt_objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_appt_schedule.sch_objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_appt_schedule.start_time IS 'Appointment start time';
COMMENT ON COLUMN sa.table_appt_schedule.end_time IS 'Appointment end time';
COMMENT ON COLUMN sa.table_appt_schedule.duration IS 'Length of the appointment in seconds';
COMMENT ON COLUMN sa.table_appt_schedule.description IS 'Description of the appointment entry';
COMMENT ON COLUMN sa.table_appt_schedule.class_title IS 'Class name of the appointment';
COMMENT ON COLUMN sa.table_appt_schedule.type_title IS 'Subclass name of the appointment';