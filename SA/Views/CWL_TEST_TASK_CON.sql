CREATE OR REPLACE FORCE VIEW sa.cwl_test_task_con (objid,"ID",s_id,title,s_title,due_date,start_date,comp_date,status,s_status,"PRIORITY",s_priority,tas_type,s_tas_type,login_name,s_login_name,user_objid,opp_objid,opp_id,s_opp_id,opp_name,s_opp_name,cond_title,s_cond_title,first_name,s_first_name,last_name,s_last_name,contact_objid,cond_objid,bus_org_objid,bus_org_name,s_bus_org_name,phone,e_mail,priority_objid,status_objid,tas_type_objid) AS
select /*+ INDEX( TASK_OBJINDEX ) */
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
;