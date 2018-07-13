CREATE OR REPLACE FORCE VIEW sa.table_wipelm_task (wip_objid,elm_objid,clarify_state,"ID",s_id,age,"CONDITION",s_condition,status,s_status,title,s_title,start_date,x_carrier_id,x_mkt_submkt_name,x_service_id,task_start_date) AS
select table_task.task_wip2wipbin, table_task.objid,
 table_condition.condition, table_task.task_id, table_task.S_task_id,
 table_condition.wipbin_time, table_condition.title, table_condition.S_title,
 table_gbst_elm.title, table_gbst_elm.S_title, table_task.title, table_task.S_title,
 table_task.start_date, table_x_carrier.x_carrier_id,
 table_x_carrier.x_mkt_submkt_name, table_x_call_trans.x_service_id,
 table_task.start_date
 from table_task, table_condition, table_gbst_elm,
  table_x_carrier, table_x_call_trans
 where table_task.task_wip2wipbin IS NOT NULL
 AND table_x_carrier.objid = table_x_call_trans.x_call_trans2carrier
 AND table_gbst_elm.objid = table_task.task_sts2gbst_elm
 AND table_condition.objid = table_task.task_state2condition
 AND table_x_call_trans.objid = table_task.x_task2x_call_trans
 ;
COMMENT ON TABLE sa.table_wipelm_task IS 'View task information for WIPbin form (375)';
COMMENT ON COLUMN sa.table_wipelm_task.wip_objid IS 'WIPbin internal record number';
COMMENT ON COLUMN sa.table_wipelm_task.elm_objid IS 'Task internal record number';
COMMENT ON COLUMN sa.table_wipelm_task.clarify_state IS 'Task Condition number';
COMMENT ON COLUMN sa.table_wipelm_task."ID" IS 'Unique ID number of the task';
COMMENT ON COLUMN sa.table_wipelm_task.age IS 'Task age in seconds';
COMMENT ON COLUMN sa.table_wipelm_task."CONDITION" IS 'Task condition title';
COMMENT ON COLUMN sa.table_wipelm_task.status IS 'Task status';
COMMENT ON COLUMN sa.table_wipelm_task.title IS 'Title of the task';
COMMENT ON COLUMN sa.table_wipelm_task.start_date IS 'Desired start date of the task';
COMMENT ON COLUMN sa.table_wipelm_task.x_carrier_id IS 'Carrier Market Identification Number';
COMMENT ON COLUMN sa.table_wipelm_task.x_mkt_submkt_name IS 'Carrier Market/Submarket Name';
COMMENT ON COLUMN sa.table_wipelm_task.x_service_id IS 'Phone Serial Number for Wireless and Service Id for Wireline';
COMMENT ON COLUMN sa.table_wipelm_task.task_start_date IS 'Desired start date of the task';