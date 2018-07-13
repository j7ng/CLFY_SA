CREATE TABLE sa.table_task (
  objid NUMBER,
  title VARCHAR2(80 BYTE),
  s_title VARCHAR2(80 BYTE),
  notes LONG,
  start_date DATE,
  due_date DATE,
  comp_date DATE,
  "ACTIVE" NUMBER,
  task_id VARCHAR2(25 BYTE),
  s_task_id VARCHAR2(25 BYTE),
  arch_ind NUMBER,
  dev NUMBER,
  task_sts2gbst_elm NUMBER,
  task_priority2gbst_elm NUMBER,
  type_task2gbst_elm NUMBER,
  sm_task2opportunity NUMBER,
  task_originator2user NUMBER,
  task_owner2user NUMBER,
  task2contact NUMBER,
  task_gen2cls_factory NUMBER,
  task_for2bus_org NUMBER,
  task_state2condition NUMBER,
  task_wip2wipbin NUMBER,
  task_currq2queue NUMBER,
  task_prevq2queue NUMBER,
  sm_task2contract NUMBER,
  task2lead NUMBER,
  task2lit_req NUMBER,
  task2task_desc NUMBER,
  update_stamp DATE,
  x_account_num VARCHAR2(40 BYTE),
  x_activation_timeframe VARCHAR2(40 BYTE),
  x_current_method VARCHAR2(30 BYTE),
  x_expedite NUMBER,
  x_fax_file VARCHAR2(80 BYTE),
  x_original_method VARCHAR2(30 BYTE),
  x_queued_flag VARCHAR2(10 BYTE),
  x_task2site_part NUMBER,
  x_task2x_call_trans NUMBER,
  x_task2x_order_type NUMBER,
  x_task2x_topp_err_codes NUMBER,
  x_trans_login VARCHAR2(30 BYTE),
  x_rate_plan VARCHAR2(60 BYTE),
  x_ota_type VARCHAR2(10 BYTE)
);
ALTER TABLE sa.table_task ADD SUPPLEMENTAL LOG GROUP dmtsora1012359215_1 (x_fax_file, x_original_method, x_ota_type, x_queued_flag, x_rate_plan, x_task2site_part, x_task2x_call_trans, x_task2x_order_type, x_task2x_topp_err_codes, x_trans_login) ALWAYS;
ALTER TABLE sa.table_task ADD SUPPLEMENTAL LOG GROUP dmtsora1012359215_0 ("ACTIVE", arch_ind, comp_date, dev, due_date, objid, sm_task2contract, sm_task2opportunity, start_date, s_task_id, s_title, task2contact, task2lead, task2lit_req, task2task_desc, task_currq2queue, task_for2bus_org, task_gen2cls_factory, task_id, task_originator2user, task_owner2user, task_prevq2queue, task_priority2gbst_elm, task_state2condition, task_sts2gbst_elm, task_wip2wipbin, title, type_task2gbst_elm, update_stamp, x_account_num, x_activation_timeframe, x_current_method, x_expedite) ALWAYS;
COMMENT ON TABLE sa.table_task IS 'Contains information describing an action item; i.e., a task to be performed';
COMMENT ON COLUMN sa.table_task.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_task.title IS 'Title of the task';
COMMENT ON COLUMN sa.table_task.notes IS 'Notes about the task';
COMMENT ON COLUMN sa.table_task.start_date IS 'Desired start date of the task';
COMMENT ON COLUMN sa.table_task.due_date IS 'Required completion date of the task';
COMMENT ON COLUMN sa.table_task.comp_date IS 'Actual completion date of the task';
COMMENT ON COLUMN sa.table_task."ACTIVE" IS 'Indicates whether the task currently being used; i.e., 0=inactive, 1=active, default=1';
COMMENT ON COLUMN sa.table_task.task_id IS 'System-generated task ID number';
COMMENT ON COLUMN sa.table_task.arch_ind IS 'When set to 1, indicates the object is ready for purge/archive';
COMMENT ON COLUMN sa.table_task.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_task.task_sts2gbst_elm IS 'Status of the task. This is a Clarify-defined popup list';
COMMENT ON COLUMN sa.table_task.task_priority2gbst_elm IS 'Priority of the task: This is a Clarify-defined pop up list';
COMMENT ON COLUMN sa.table_task.type_task2gbst_elm IS 'Type of the task: This is a Clarify-defined pop up list';
COMMENT ON COLUMN sa.table_task.sm_task2opportunity IS 'Opportunity which the task supports';
COMMENT ON COLUMN sa.table_task.task_originator2user IS 'User that created the task';
COMMENT ON COLUMN sa.table_task.task_owner2user IS 'User that currently owns the task';
COMMENT ON COLUMN sa.table_task.task2contact IS 'Primary contact to be used for the task';
COMMENT ON COLUMN sa.table_task.task_gen2cls_factory IS 'Class factory which generated the task';
COMMENT ON COLUMN sa.table_task.task_for2bus_org IS 'Account/organization which the task supports';
COMMENT ON COLUMN sa.table_task.task_state2condition IS 'The condition of task';
COMMENT ON COLUMN sa.table_task.task_wip2wipbin IS 'WIPbin into which the task has been accepted';
COMMENT ON COLUMN sa.table_task.task_currq2queue IS 'Queue to which the task has been dispatched';
COMMENT ON COLUMN sa.table_task.task_prevq2queue IS 'Queue to which the task was previously dispatched';
COMMENT ON COLUMN sa.table_task.sm_task2contract IS 'Contract which the task supports. Reserved; future';
COMMENT ON COLUMN sa.table_task.task2lead IS 'Related lead';
COMMENT ON COLUMN sa.table_task.task2lit_req IS 'Related literature request template';
COMMENT ON COLUMN sa.table_task.task2task_desc IS 'Additional discription or comments about the task';
COMMENT ON COLUMN sa.table_task.update_stamp IS 'Date/time of last update to the task';
COMMENT ON COLUMN sa.table_task.x_account_num IS 'denormalized account num field filled in at create time';
COMMENT ON COLUMN sa.table_task.x_activation_timeframe IS 'Activation Time frame from pull down list';
COMMENT ON COLUMN sa.table_task.x_current_method IS 'Current transmission method of task';
COMMENT ON COLUMN sa.table_task.x_expedite IS 'TBD';
COMMENT ON COLUMN sa.table_task.x_fax_file IS 'TBD';
COMMENT ON COLUMN sa.table_task.x_original_method IS 'Original transmission method of task';
COMMENT ON COLUMN sa.table_task.x_queued_flag IS 'TBD';
COMMENT ON COLUMN sa.table_task.x_task2site_part IS 'Task ID to site part for action item for new case';
COMMENT ON COLUMN sa.table_task.x_task2x_call_trans IS 'Task ID to Call Transaction';
COMMENT ON COLUMN sa.table_task.x_task2x_order_type IS 'Task Associated with the order type';
COMMENT ON COLUMN sa.table_task.x_task2x_topp_err_codes IS 'Task ID to Error Codes for action item';
COMMENT ON COLUMN sa.table_task.x_trans_login IS 'TBD';
COMMENT ON COLUMN sa.table_task.x_rate_plan IS 'Dual Rate - Rate Plan Used';
COMMENT ON COLUMN sa.table_task.x_ota_type IS 'OTA Type';