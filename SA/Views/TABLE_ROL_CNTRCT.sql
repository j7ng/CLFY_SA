CREATE OR REPLACE FORCE VIEW sa.table_rol_cntrct (objid,con_objid,contr_objid,sched_objid,contr_id,s_contr_id,sch_id,s_sch_id,first_name,s_first_name,last_name,s_last_name,phone,contr_role,access_id,"ACTIVE") AS
select table_con_csc_role.objid, table_contact.objid,
 table_contract.objid, table_contr_schedule.objid,
 table_contract.id, table_contract.S_id, table_contr_schedule.schedule_id, table_contr_schedule.S_schedule_id,
 table_contact.first_name, table_contact.S_first_name, table_contact.last_name, table_contact.S_last_name,
 table_contact.phone, table_con_csc_role.role_name,
 table_con_csc_role.access_id, table_con_csc_role.active
 from table_con_csc_role, table_contact, table_contract,
  table_contr_schedule
 where table_contact.objid = table_con_csc_role.csc_role2contact
 AND table_contr_schedule.objid = table_con_csc_role.con_role2contr_schedule
 AND table_contract.objid = table_contr_schedule.schedule2contract
 ;
COMMENT ON TABLE sa.table_rol_cntrct IS 'Search by Contract or Access ID. Used by form Incoming Call (8110)';
COMMENT ON COLUMN sa.table_rol_cntrct.objid IS 'Con_csc_role internal record number';
COMMENT ON COLUMN sa.table_rol_cntrct.con_objid IS 'Contact internal record number';
COMMENT ON COLUMN sa.table_rol_cntrct.contr_objid IS 'Contract internal record number';
COMMENT ON COLUMN sa.table_rol_cntrct.sched_objid IS 'Contract Schedule internal record number';
COMMENT ON COLUMN sa.table_rol_cntrct.contr_id IS 'Contract ID';
COMMENT ON COLUMN sa.table_rol_cntrct.sch_id IS 'Contract Schedule id';
COMMENT ON COLUMN sa.table_rol_cntrct.first_name IS 'Contact first name';
COMMENT ON COLUMN sa.table_rol_cntrct.last_name IS 'Contact last name';
COMMENT ON COLUMN sa.table_rol_cntrct.phone IS 'Contact phone number includes area code, number, and extension';
COMMENT ON COLUMN sa.table_rol_cntrct.contr_role IS 'Contract Role Name';
COMMENT ON COLUMN sa.table_rol_cntrct.access_id IS 'Access ID';
COMMENT ON COLUMN sa.table_rol_cntrct."ACTIVE" IS 'Active flag';