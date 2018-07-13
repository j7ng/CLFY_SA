CREATE OR REPLACE FORCE VIEW sa.table_sched_con_rol (objid,sched_objid,contact_objid,schedule_id,s_schedule_id,role_name,focus_type,"ACTIVE",first_name,s_first_name,last_name,s_last_name,title,status,access_id) AS
select table_con_csc_role.objid, table_contr_schedule.objid,
 table_contact.objid, table_contr_schedule.schedule_id, table_contr_schedule.S_schedule_id,
 table_con_csc_role.role_name, table_con_csc_role.focus_type,
 table_con_csc_role.active, table_contact.first_name, table_contact.S_first_name,
 table_contact.last_name, table_contact.S_last_name, table_contact.title,
 table_contact.status, table_con_csc_role.access_id
 from table_con_csc_role, table_contr_schedule, table_contact
 where table_contr_schedule.objid = table_con_csc_role.con_role2contr_schedule
 AND table_contact.objid = table_con_csc_role.csc_role2contact
 ;
COMMENT ON TABLE sa.table_sched_con_rol IS 'Displays contact and contract schedule interaction. This is used by form Contract (9133), Payment Options (9141), Quote (9672), <Quote> Payment Options (9677)';
COMMENT ON COLUMN sa.table_sched_con_rol.objid IS 'Con_csc_role internal record number';
COMMENT ON COLUMN sa.table_sched_con_rol.sched_objid IS 'Contr_schedule internal record number';
COMMENT ON COLUMN sa.table_sched_con_rol.contact_objid IS 'Contact internal record number';
COMMENT ON COLUMN sa.table_sched_con_rol.schedule_id IS 'Contract schedule ID number';
COMMENT ON COLUMN sa.table_sched_con_rol.role_name IS 'Name of the contact and contract schedule s interaction. This is from a user-defined popup with default name Contact Role';
COMMENT ON COLUMN sa.table_sched_con_rol.focus_type IS 'Object type ID of the role-player; i.e., 45=a contact s role, 5051=a contract schedule s role';
COMMENT ON COLUMN sa.table_sched_con_rol."ACTIVE" IS 'Indicates whether the role is currently being used; i.e., 0=inactive, 1=active';
COMMENT ON COLUMN sa.table_sched_con_rol.first_name IS 'Contact s first name';
COMMENT ON COLUMN sa.table_sched_con_rol.last_name IS 'Contact s last name';
COMMENT ON COLUMN sa.table_sched_con_rol.title IS 'Contact s professional title';
COMMENT ON COLUMN sa.table_sched_con_rol.status IS 'Status of contact; i.e., active/inactive/obsolete';
COMMENT ON COLUMN sa.table_sched_con_rol.access_id IS 'ID authorizing access to the contract/schedule for the role';