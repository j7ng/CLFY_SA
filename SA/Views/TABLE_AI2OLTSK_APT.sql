CREATE OR REPLACE FORCE VIEW sa.table_ai2oltsk_apt (objid,"ID",s_id,title,s_title,due_date,start_date,comp_date,task_notes,status,s_status,status_rank,"PRIORITY",s_priority,priority_rank,login_name,s_login_name,user_objid,first_name,s_first_name,last_name,s_last_name,contact_objid,status_objid,priority_objid,condition_objid,condition_title,s_condition_title,task_desc_objid,description) AS
select table_task.objid, table_task.task_id, table_task.S_task_id,
 table_task.title, table_task.S_title, table_task.due_date,
 table_task.start_date, table_task.comp_date,
 table_task.notes, table_gbst_stat.title, table_gbst_stat.S_title,
 table_gbst_stat.rank, table_gbst_pri.title, table_gbst_pri.S_title,
 table_gbst_pri.rank, table_user.login_name, table_user.S_login_name,
 table_user.objid, table_contact.first_name, table_contact.S_first_name,
 table_contact.last_name, table_contact.S_last_name, table_contact.objid,
 table_gbst_stat.objid, table_gbst_pri.objid,
 table_condition.objid, table_condition.title, table_condition.S_title,
 table_task_desc.objid, table_task_desc.description
 from table_gbst_elm table_gbst_pri, table_gbst_elm table_gbst_stat, table_task, table_user, table_contact,
  table_condition, table_task_desc
 where table_gbst_stat.objid = table_task.task_sts2gbst_elm
 AND table_user.objid = table_task.task_owner2user
 AND table_gbst_pri.objid = table_task.task_priority2gbst_elm
 AND table_condition.objid = table_task.task_state2condition
 AND table_task_desc.objid (+) = table_task.task2task_desc
 AND table_contact.objid (+) = table_task.task2contact
 ;
COMMENT ON TABLE sa.table_ai2oltsk_apt IS 'Used by form PIM Preference (9624) for Outlook integration';
COMMENT ON COLUMN sa.table_ai2oltsk_apt.objid IS 'Task internal record number';
COMMENT ON COLUMN sa.table_ai2oltsk_apt."ID" IS 'Task ID';
COMMENT ON COLUMN sa.table_ai2oltsk_apt.title IS 'Title of the task';
COMMENT ON COLUMN sa.table_ai2oltsk_apt.due_date IS 'Due date of the task';
COMMENT ON COLUMN sa.table_ai2oltsk_apt.start_date IS 'Start date of the task';
COMMENT ON COLUMN sa.table_ai2oltsk_apt.comp_date IS 'Actual completion date of the task';
COMMENT ON COLUMN sa.table_ai2oltsk_apt.task_notes IS 'Notes about the task';
COMMENT ON COLUMN sa.table_ai2oltsk_apt.status IS 'Status of the task';
COMMENT ON COLUMN sa.table_ai2oltsk_apt.status_rank IS 'Rank order of the status in its list';
COMMENT ON COLUMN sa.table_ai2oltsk_apt."PRIORITY" IS 'Priority of the task';
COMMENT ON COLUMN sa.table_ai2oltsk_apt.priority_rank IS 'Rank order of the priority in its list';
COMMENT ON COLUMN sa.table_ai2oltsk_apt.login_name IS 'Login name of the user';
COMMENT ON COLUMN sa.table_ai2oltsk_apt.user_objid IS 'User-owner internal record number';
COMMENT ON COLUMN sa.table_ai2oltsk_apt.first_name IS 'First name of the contact';
COMMENT ON COLUMN sa.table_ai2oltsk_apt.last_name IS 'Last name of the contact';
COMMENT ON COLUMN sa.table_ai2oltsk_apt.contact_objid IS 'Contact internal record number';
COMMENT ON COLUMN sa.table_ai2oltsk_apt.status_objid IS 'Staus internal record number';
COMMENT ON COLUMN sa.table_ai2oltsk_apt.priority_objid IS 'Priority internal record number';
COMMENT ON COLUMN sa.table_ai2oltsk_apt.condition_objid IS 'Condition internal record number';
COMMENT ON COLUMN sa.table_ai2oltsk_apt.condition_title IS 'Title of the condition';
COMMENT ON COLUMN sa.table_ai2oltsk_apt.task_desc_objid IS 'Task description internal record number';
COMMENT ON COLUMN sa.table_ai2oltsk_apt.description IS 'Description of or comments on a task';