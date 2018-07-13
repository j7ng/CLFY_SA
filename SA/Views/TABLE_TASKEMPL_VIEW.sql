CREATE OR REPLACE FORCE VIEW sa.table_taskempl_view (objid,user_objid,opp_objid,employee_objid,"ID",s_id,title,s_title,start_date,status,s_status,"PRIORITY",s_priority,first_name,s_first_name,last_name,s_last_name) AS
select table_task.objid, table_user.objid,
 table_task.sm_task2opportunity, table_employee.objid,
 table_task.task_id, table_task.S_task_id, table_task.title, table_task.S_title,
 table_task.start_date, table_status_gbst_elm.title, table_status_gbst_elm.S_title,
 table_priority_gbst_elm.title, table_priority_gbst_elm.S_title, table_employee.first_name, table_employee.S_first_name,
 table_employee.last_name, table_employee.S_last_name
 from table_gbst_elm table_priority_gbst_elm, table_gbst_elm table_status_gbst_elm, table_task, table_user, table_employee
 where table_task.sm_task2opportunity IS NOT NULL
 AND table_status_gbst_elm.objid = table_task.task_sts2gbst_elm
 AND table_user.objid = table_employee.employee2user
 AND table_priority_gbst_elm.objid = table_task.task_priority2gbst_elm
 AND table_user.objid = table_task.task_owner2user
 ;
COMMENT ON TABLE sa.table_taskempl_view IS 'Used internally to select tasks';
COMMENT ON COLUMN sa.table_taskempl_view.objid IS 'Task internal record number';
COMMENT ON COLUMN sa.table_taskempl_view.user_objid IS 'User internal record number';
COMMENT ON COLUMN sa.table_taskempl_view.opp_objid IS 'Opportunity internal record number';
COMMENT ON COLUMN sa.table_taskempl_view.employee_objid IS 'Employee internal record number';
COMMENT ON COLUMN sa.table_taskempl_view."ID" IS 'System-generated task ID number';
COMMENT ON COLUMN sa.table_taskempl_view.title IS 'Task title';
COMMENT ON COLUMN sa.table_taskempl_view.start_date IS 'Task start date';
COMMENT ON COLUMN sa.table_taskempl_view.status IS 'Task status';
COMMENT ON COLUMN sa.table_taskempl_view."PRIORITY" IS 'Task priority';
COMMENT ON COLUMN sa.table_taskempl_view.first_name IS 'Employee first name';
COMMENT ON COLUMN sa.table_taskempl_view.last_name IS 'Employee last name';