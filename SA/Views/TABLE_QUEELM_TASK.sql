CREATE OR REPLACE FORCE VIEW sa.table_queelm_task (que_objid,elm_objid,clarify_state,"ID",s_id,age,"CONDITION",s_condition,status,s_status,title,s_title,start_date) AS
select table_task.task_currq2queue, table_task.objid,
 table_condition.condition, table_task.task_id, table_task.S_task_id,
 table_condition.queue_time, table_condition.title, table_condition.S_title,
 table_gbst_elm.title, table_gbst_elm.S_title, table_task.title, table_task.S_title,
 table_task.start_date
 from table_task, table_condition, table_gbst_elm
 where table_condition.objid = table_task.task_state2condition
 AND table_task.task_currq2queue IS NOT NULL
 AND table_gbst_elm.objid = table_task.task_sts2gbst_elm
 ;
COMMENT ON TABLE sa.table_queelm_task IS 'View task information for Queue form (728)';
COMMENT ON COLUMN sa.table_queelm_task.que_objid IS 'Queue object ID number';
COMMENT ON COLUMN sa.table_queelm_task.elm_objid IS 'Task object ID number';
COMMENT ON COLUMN sa.table_queelm_task.clarify_state IS 'Task condition';
COMMENT ON COLUMN sa.table_queelm_task."ID" IS 'Task ID number';
COMMENT ON COLUMN sa.table_queelm_task.age IS 'Age of task in seconds';
COMMENT ON COLUMN sa.table_queelm_task."CONDITION" IS 'Condition of task';
COMMENT ON COLUMN sa.table_queelm_task.status IS 'Status of task';
COMMENT ON COLUMN sa.table_queelm_task.title IS 'Title of task';
COMMENT ON COLUMN sa.table_queelm_task.start_date IS 'Desired start date of the task';