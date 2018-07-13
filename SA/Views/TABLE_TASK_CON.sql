CREATE OR REPLACE FORCE VIEW sa.table_task_con (objid,"ID",s_id,title,s_title,due_date,start_date,comp_date,status,s_status,"PRIORITY",s_priority,tas_type,s_tas_type,login_name,s_login_name,user_objid,opp_objid,opp_id,s_opp_id,opp_name,s_opp_name,cond_title,s_cond_title,first_name,s_first_name,last_name,s_last_name,contact_objid,cond_objid,bus_org_objid,bus_org_name,s_bus_org_name,phone,e_mail,priority_objid,status_objid,tas_type_objid) AS
select
table_task.objid, table_task.task_id, table_task.S_task_id,
 table_task.title, table_task.S_title, table_task.due_date,
 table_task.start_date, table_task.comp_date,
 table_gbst_stat.title, table_gbst_stat.S_title, table_gbst_pri.title, table_gbst_pri.S_title,
 table_gbst_type.title, table_gbst_type.S_title, table_user.login_name, table_user.S_login_name,
 table_user.objid, table_opportunity.objid,
 table_opportunity.id, table_opportunity.S_id, table_opportunity.name, table_opportunity.S_name,
 table_condition.title, table_condition.S_title, table_contact.first_name, table_contact.S_first_name,
 table_contact.last_name, table_contact.S_last_name, table_contact.objid,
 table_condition.objid, table_bus_org.objid,
 table_bus_org.name, table_bus_org.S_name, table_contact.phone,
 table_contact.e_mail, table_gbst_pri.objid,
 table_gbst_stat.objid, table_gbst_type.objid
 from table_gbst_elm table_gbst_pri, table_gbst_elm table_gbst_type, table_gbst_elm table_gbst_stat, table_task, table_user, table_opportunity,
  table_condition, table_contact, table_bus_org
 where table_gbst_pri.objid = table_task.task_priority2gbst_elm
 AND table_gbst_type.objid = table_task.type_task2gbst_elm
 AND table_user.objid = table_task.task_owner2user
 AND table_condition.objid (+) = table_task.task_state2condition
 AND table_bus_org.objid (+) = table_task.task_for2bus_org
 AND table_contact.objid (+) = table_task.task2contact
 AND table_opportunity.objid (+) = table_task.sm_task2opportunity
 AND table_gbst_stat.objid = table_task.task_sts2gbst_elm
 AND 1 = 2;
COMMENT ON TABLE sa.table_task_con IS 'Used by forms Incoming Call (9580), Action Items (9620), Contact (11401), Recent Interactions (11403), Contact History (11404) and Customer interaction (11400)';
COMMENT ON COLUMN sa.table_task_con.objid IS 'Task internal record number';
COMMENT ON COLUMN sa.table_task_con."ID" IS 'Task ID';
COMMENT ON COLUMN sa.table_task_con.title IS 'Title of the task';
COMMENT ON COLUMN sa.table_task_con.due_date IS 'Due date of the task';
COMMENT ON COLUMN sa.table_task_con.start_date IS 'Start date of the task';
COMMENT ON COLUMN sa.table_task_con.comp_date IS 'Actual completion date of the task';
COMMENT ON COLUMN sa.table_task_con.status IS 'Status of the task';
COMMENT ON COLUMN sa.table_task_con."PRIORITY" IS 'Priority of the task';
COMMENT ON COLUMN sa.table_task_con.tas_type IS 'Type of the task';
COMMENT ON COLUMN sa.table_task_con.login_name IS 'Login name of the user';
COMMENT ON COLUMN sa.table_task_con.user_objid IS 'User-owner internal record number';
COMMENT ON COLUMN sa.table_task_con.opp_objid IS 'Opportunity internal record number';
COMMENT ON COLUMN sa.table_task_con.opp_id IS 'ID of the opportunity';
COMMENT ON COLUMN sa.table_task_con.opp_name IS 'Title of the opportunity';
COMMENT ON COLUMN sa.table_task_con.cond_title IS 'Title of the condition';
COMMENT ON COLUMN sa.table_task_con.first_name IS 'first name of the contact';
COMMENT ON COLUMN sa.table_task_con.last_name IS 'last name of the contact';
COMMENT ON COLUMN sa.table_task_con.contact_objid IS 'Contact internal record number';
COMMENT ON COLUMN sa.table_task_con.cond_objid IS 'Condition internal record number';
COMMENT ON COLUMN sa.table_task_con.bus_org_objid IS 'Bus_org internal record number';
COMMENT ON COLUMN sa.table_task_con.bus_org_name IS 'Name of bus_org';
COMMENT ON COLUMN sa.table_task_con.phone IS 'phone of the contact';
COMMENT ON COLUMN sa.table_task_con.e_mail IS 'e-mail of the contact';
COMMENT ON COLUMN sa.table_task_con.priority_objid IS 'Priority internal record number';
COMMENT ON COLUMN sa.table_task_con.status_objid IS 'Status internal record number';
COMMENT ON COLUMN sa.table_task_con.tas_type_objid IS 'Task type internal record number';