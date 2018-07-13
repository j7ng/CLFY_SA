CREATE OR REPLACE FORCE VIEW sa.cwl_test_nlog_actitm (objid,internal,title,creation_time,task_objid,task_title,s_task_title,task_id,s_task_id,originator_objid,originator_name,s_originator_name) AS
select /*+ INDEX(USER_OBJINDEX) */
 table_notes_log.objid, table_notes_log.internal,
 table_notes_log.commitment, table_notes_log.creation_time,
 table_task.objid, table_task.title, table_task.S_title,
 table_task.task_id, table_task.S_task_id, table_user.objid,
 table_user.login_name, table_user.S_login_name
 from table_notes_log, table_task, table_user
 where table_task.objid (+) = table_notes_log.task_notes2task
 AND table_user.objid (+) = table_notes_log.notes_owner2user
;