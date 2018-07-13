CREATE OR REPLACE FORCE VIEW sa.table_sched_sit_rol (objid,sched_objid,site_objid,schedule_id,s_schedule_id,role_name,focus_type,"ACTIVE",site_id,site_name,s_site_name,status) AS
select table_sit_csc_role.objid, table_contr_schedule.objid,
 table_site.objid, table_contr_schedule.schedule_id, table_contr_schedule.S_schedule_id,
 table_sit_csc_role.role_name, table_sit_csc_role.focus_type,
 table_sit_csc_role.active, table_site.site_id,
 table_site.name, table_site.S_name, table_site.status
 from table_sit_csc_role, table_contr_schedule, table_site
 where table_contr_schedule.objid = table_sit_csc_role.sit_role2contr_schedule
 AND table_site.objid = table_sit_csc_role.csc_role2site
 ;
COMMENT ON TABLE sa.table_sched_sit_rol IS 'Used by forms Contract (9133), Contract<ID> (9134), More Info (9135, 9674), Line Items (9136, 9675), Schedules (9140, 9676), Payment Options (9141, 9677), Quote (9672, 9673)';
COMMENT ON COLUMN sa.table_sched_sit_rol.objid IS 'Sit_csc_role internal record number';
COMMENT ON COLUMN sa.table_sched_sit_rol.sched_objid IS 'Contr_schedule internal record number';
COMMENT ON COLUMN sa.table_sched_sit_rol.site_objid IS 'Site internal record number';
COMMENT ON COLUMN sa.table_sched_sit_rol.schedule_id IS 'Contract schedule ID number';
COMMENT ON COLUMN sa.table_sched_sit_rol.role_name IS 'Name of the interaction. This is from a user-defined popup with default name Site Role';
COMMENT ON COLUMN sa.table_sched_sit_rol.focus_type IS 'Object type ID of the role-player; i.e., 52=a site s role, 5051=a contract schedule s role';
COMMENT ON COLUMN sa.table_sched_sit_rol."ACTIVE" IS 'Indicates whether the role is currently being used; i.e., 0=inactive, 1=active';
COMMENT ON COLUMN sa.table_sched_sit_rol.site_id IS 'Unique site ID number assigned according to auto-numbering definition';
COMMENT ON COLUMN sa.table_sched_sit_rol.site_name IS 'Site name';
COMMENT ON COLUMN sa.table_sched_sit_rol.status IS 'Status of site; i.e., 0=active, 1=inactive, 2=obsolete';