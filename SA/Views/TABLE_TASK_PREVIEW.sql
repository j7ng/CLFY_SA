CREATE OR REPLACE FORCE VIEW sa.table_task_preview (objid,"ID",s_id,title,s_title,due_date,start_date,comp_date,status,s_status,"PRIORITY",s_priority,tas_type,s_tas_type,login_name,s_login_name,user_objid,first_name,s_first_name,last_name,s_last_name,contact_objid,tas_notes,"CONDITION",s_condition,"ACTIVE",mandatory_ind) AS
select table_task.objid, table_task.task_id, table_task.S_task_id,
 table_task.title, table_task.S_title, table_task.due_date,
 table_task.start_date, table_task.comp_date,
 table_gbst_stat.title, table_gbst_stat.S_title, table_gbst_pri.title, table_gbst_pri.S_title,
 table_gbst_type.title, table_gbst_type.S_title, table_user.login_name, table_user.S_login_name,
 table_user.objid, table_contact.first_name, table_contact.S_first_name,
 table_contact.last_name, table_contact.S_last_name, table_contact.objid,
 table_task.notes, table_condition.title, table_condition.S_title,
 table_task.active, table_cls_factory.mandatory_ind
 from table_gbst_elm table_gbst_pri, table_gbst_elm table_gbst_stat, table_gbst_elm table_gbst_type, table_task, table_user, table_contact,
  table_condition, table_cls_factory
 where table_cls_factory.objid = table_task.task_gen2cls_factory
 AND table_gbst_stat.objid = table_task.task_sts2gbst_elm
 AND table_condition.objid = table_task.task_state2condition
 AND table_gbst_pri.objid = table_task.task_priority2gbst_elm
 AND table_gbst_type.objid = table_task.type_task2gbst_elm
 AND table_user.objid = table_task.task_owner2user
 AND table_contact.objid = table_task.task2contact
 ;
COMMENT ON TABLE sa.table_task_preview IS 'Used to display contact info, owner info, and gbst_elm data from the Action Item Preview/Modify form (8230)';
COMMENT ON COLUMN sa.table_task_preview.objid IS 'Task internal record number';
COMMENT ON COLUMN sa.table_task_preview."ID" IS 'Task ID';
COMMENT ON COLUMN sa.table_task_preview.title IS 'Title of the task';
COMMENT ON COLUMN sa.table_task_preview.due_date IS 'Due date of the task';
COMMENT ON COLUMN sa.table_task_preview.start_date IS 'Start date of the task';
COMMENT ON COLUMN sa.table_task_preview.comp_date IS 'Actual completion date of the task';
COMMENT ON COLUMN sa.table_task_preview.status IS 'Status of the task';
COMMENT ON COLUMN sa.table_task_preview."PRIORITY" IS 'Priority of the task';
COMMENT ON COLUMN sa.table_task_preview.tas_type IS 'Type of the task';
COMMENT ON COLUMN sa.table_task_preview.login_name IS 'Login name of the user';
COMMENT ON COLUMN sa.table_task_preview.user_objid IS 'User-owner internal record number';
COMMENT ON COLUMN sa.table_task_preview.first_name IS 'First name of the contact';
COMMENT ON COLUMN sa.table_task_preview.last_name IS 'Last name of the contact';
COMMENT ON COLUMN sa.table_task_preview.contact_objid IS 'Contact internal record number';
COMMENT ON COLUMN sa.table_task_preview.tas_notes IS 'Notes about the task';
COMMENT ON COLUMN sa.table_task_preview."CONDITION" IS 'Condition/state of the task';
COMMENT ON COLUMN sa.table_task_preview."ACTIVE" IS 'If the task is active';
COMMENT ON COLUMN sa.table_task_preview.mandatory_ind IS 'Indicates whether the action item must be generated; 0=not mandatory, 1=mandatory';