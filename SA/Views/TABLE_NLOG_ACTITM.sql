CREATE OR REPLACE FORCE VIEW sa.table_nlog_actitm (objid,internal,title,creation_time,task_objid,task_title,s_task_title,task_id,s_task_id,originator_objid,originator_name,s_originator_name) AS
select /*+ INDEX(USER_OBJINDEX) */
 table_notes_log.objid, table_notes_log.internal,
 table_notes_log.commitment, table_notes_log.creation_time,
 table_task.objid, table_task.title, table_task.S_title,
 table_task.task_id, table_task.S_task_id, table_user.objid,
 table_user.login_name, table_user.S_login_name
 from table_notes_log, table_task, table_user
 where table_task.objid (+) = table_notes_log.task_notes2task
 AND table_user.objid (+) = table_notes_log.notes_owner2user;
COMMENT ON TABLE sa.table_nlog_actitm IS 'Used to display note logs for Action Items. Use by forms Action Item Notes Log (9698) and Action Item (14000)';
COMMENT ON COLUMN sa.table_nlog_actitm.objid IS 'internal record number of the notes_log';
COMMENT ON COLUMN sa.table_nlog_actitm.internal IS 'Internal Information';
COMMENT ON COLUMN sa.table_nlog_actitm.title IS 'Title of Commitment';
COMMENT ON COLUMN sa.table_nlog_actitm.creation_time IS 'Date and time the notes log entry was created';
COMMENT ON COLUMN sa.table_nlog_actitm.task_objid IS 'Task internal record number';
COMMENT ON COLUMN sa.table_nlog_actitm.task_title IS 'Title of the task';
COMMENT ON COLUMN sa.table_nlog_actitm.task_id IS 'Unique ID of the task';
COMMENT ON COLUMN sa.table_nlog_actitm.originator_objid IS 'User internal record number';
COMMENT ON COLUMN sa.table_nlog_actitm.originator_name IS 'Login name of the user';