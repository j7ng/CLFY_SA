CREATE OR REPLACE FORCE VIEW sa.table_sfa_tsk_wk_v (objid,wip_objid,queue_objid,cond_objid,sts_objid,owner_objid,task_name,s_task_name,task_id,s_task_id,wip_name,s_wip_name,queue_name,s_queue_name,"CONDITION",s_condition,status,s_status,owner_name,s_owner_name) AS
select table_task.objid, table_wipbin.objid,
 table_queue.objid, table_condition.objid,
 table_gbst_elm.objid, table_user.objid,
 table_task.title, table_task.S_title, table_task.task_id, table_task.S_task_id,
 table_wipbin.title, table_wipbin.S_title, table_queue.title, table_queue.S_title,
 table_condition.title, table_condition.S_title, table_gbst_elm.title, table_gbst_elm.S_title,
 table_user.login_name, table_user.S_login_name
 from table_task, table_wipbin, table_queue,
  table_condition, table_gbst_elm, table_user
 where table_condition.objid = table_task.task_state2condition
 AND table_queue.objid (+) = table_task.task_currq2queue
 AND table_gbst_elm.objid = table_task.task_sts2gbst_elm
 AND table_wipbin.objid (+) = table_task.task_wip2wipbin
 AND table_user.objid = table_task.task_owner2user
 ;
COMMENT ON TABLE sa.table_sfa_tsk_wk_v IS 'Displays Action Item (Task) workflow information. Used by form Lead (11610), Account Mgr (11650), Console-Sales (12000), and Opportunity Mgr (13000)';
COMMENT ON COLUMN sa.table_sfa_tsk_wk_v.objid IS 'Task internal record number';
COMMENT ON COLUMN sa.table_sfa_tsk_wk_v.wip_objid IS 'Wipbin internal record number';
COMMENT ON COLUMN sa.table_sfa_tsk_wk_v.queue_objid IS 'Queue internal record number';
COMMENT ON COLUMN sa.table_sfa_tsk_wk_v.cond_objid IS 'Condition internal record number';
COMMENT ON COLUMN sa.table_sfa_tsk_wk_v.sts_objid IS 'Gbst_elm internal record number';
COMMENT ON COLUMN sa.table_sfa_tsk_wk_v.owner_objid IS 'User internal record number';
COMMENT ON COLUMN sa.table_sfa_tsk_wk_v.task_name IS 'Name of the opportunity';
COMMENT ON COLUMN sa.table_sfa_tsk_wk_v.task_id IS 'Unique ID of the opportunity';
COMMENT ON COLUMN sa.table_sfa_tsk_wk_v.wip_name IS 'Name of the wipbin';
COMMENT ON COLUMN sa.table_sfa_tsk_wk_v.queue_name IS 'Name of the queue';
COMMENT ON COLUMN sa.table_sfa_tsk_wk_v."CONDITION" IS 'Condition of the opportunity';
COMMENT ON COLUMN sa.table_sfa_tsk_wk_v.status IS 'Status of the opportunity';
COMMENT ON COLUMN sa.table_sfa_tsk_wk_v.owner_name IS 'User name of the opportunity s owner';