CREATE OR REPLACE FORCE VIEW sa.table_site_svc_appt (site_objid,pinst_objid,scheudle_objid,appointment_objid,start_time,end_time,duration,"RANK") AS
select table_site_part.site_part2site, table_site_part.objid,
 table_schedule.objid, table_appointment.objid,
 table_appointment.start_time, table_appointment.end_time,
 table_appointment.duration, table_gbst_elm.rank
 from table_site_part, table_schedule, table_appointment,
  table_gbst_elm
 where table_site_part.site_part2site IS NOT NULL
 AND table_gbst_elm.objid = table_appointment.appt2appt_type
 AND table_schedule.objid = table_appointment.appt2schedule
 AND table_site_part.objid = table_schedule.schedule2site_part
 ;
COMMENT ON TABLE sa.table_site_svc_appt IS 'Contains service interuption information';
COMMENT ON COLUMN sa.table_site_svc_appt.site_objid IS 'Site internal record number';
COMMENT ON COLUMN sa.table_site_svc_appt.pinst_objid IS 'Part internal record number';
COMMENT ON COLUMN sa.table_site_svc_appt.scheudle_objid IS 'Schedule internal record number';
COMMENT ON COLUMN sa.table_site_svc_appt.appointment_objid IS 'Appointment internal record number';
COMMENT ON COLUMN sa.table_site_svc_appt.start_time IS 'Start time of appointment';
COMMENT ON COLUMN sa.table_site_svc_appt.end_time IS 'End time of appointment';
COMMENT ON COLUMN sa.table_site_svc_appt.duration IS 'Length of appointment in seconds';
COMMENT ON COLUMN sa.table_site_svc_appt."RANK" IS 'Position of the item in the list; important in tracking scheduled/unscheduled and config time for service interuption report';