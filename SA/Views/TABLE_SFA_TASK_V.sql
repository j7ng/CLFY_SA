CREATE OR REPLACE FORCE VIEW sa.table_sfa_task_v (objid,user_objid,priority_objid,status_objid,tas_type_objid,task_id,s_task_id,task_title,s_task_title,task_due_date,task_start_date,task_comp_date,task_status,s_task_status,task_priority,s_task_priority,task_type,s_task_type,task_owner,s_task_owner) AS
select table_task.objid, table_user.objid,
 table_gbst_pri.objid, table_gbst_stat.objid,
 table_gbst_type.objid, table_task.task_id, table_task.S_task_id,
 table_task.title, table_task.S_title, table_task.due_date,
 table_task.start_date, table_task.comp_date,
 table_gbst_stat.title, table_gbst_stat.S_title, table_gbst_pri.title, table_gbst_pri.S_title,
 table_gbst_type.title, table_gbst_type.S_title, table_user.login_name, table_user.S_login_name
 from table_gbst_elm table_gbst_pri, table_gbst_elm table_gbst_stat, table_gbst_elm table_gbst_type, table_task, table_user
 where table_user.objid = table_task.task_owner2user
 AND table_gbst_stat.objid = table_task.task_sts2gbst_elm
 AND table_gbst_type.objid = table_task.type_task2gbst_elm
 AND table_gbst_pri.objid = table_task.task_priority2gbst_elm
 ;
COMMENT ON TABLE sa.table_sfa_task_v IS 'Displays task (Action Item) details. Used by forms Console-Sales (12000), Opportunity Mgr (13000), Action Item (14000), Account (11650), Generic Lookup (20000) and many tabs';
COMMENT ON COLUMN sa.table_sfa_task_v.objid IS 'Task internal record number';
COMMENT ON COLUMN sa.table_sfa_task_v.user_objid IS 'User-owner internal record number';
COMMENT ON COLUMN sa.table_sfa_task_v.priority_objid IS 'Taks priority internal record number';
COMMENT ON COLUMN sa.table_sfa_task_v.status_objid IS 'Task status internal record number';
COMMENT ON COLUMN sa.table_sfa_task_v.tas_type_objid IS 'Task type internal record number';
COMMENT ON COLUMN sa.table_sfa_task_v.task_id IS 'System-generated task ID number';
COMMENT ON COLUMN sa.table_sfa_task_v.task_title IS 'Title of the task';
COMMENT ON COLUMN sa.table_sfa_task_v.task_due_date IS 'Due date of the task';
COMMENT ON COLUMN sa.table_sfa_task_v.task_start_date IS 'Start date of the task';
COMMENT ON COLUMN sa.table_sfa_task_v.task_comp_date IS 'Actual completion date of the task';
COMMENT ON COLUMN sa.table_sfa_task_v.task_status IS 'Status of the task';
COMMENT ON COLUMN sa.table_sfa_task_v.task_priority IS 'Priority of the task';
COMMENT ON COLUMN sa.table_sfa_task_v.task_type IS 'Type of the task';
COMMENT ON COLUMN sa.table_sfa_task_v.task_owner IS 'Login name of the user';