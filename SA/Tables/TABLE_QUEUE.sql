CREATE TABLE sa.table_queue (
  objid NUMBER,
  title VARCHAR2(24 BYTE),
  s_title VARCHAR2(24 BYTE),
  shared_pers NUMBER,
  allow_case NUMBER,
  allow_subcase NUMBER,
  allow_probdesc NUMBER,
  allow_dmnd_dtl NUMBER,
  description VARCHAR2(255 BYTE),
  sort_by VARCHAR2(80 BYTE),
  max_resp_time NUMBER,
  obj_received NUMBER,
  obj_accepted NUMBER,
  obj_forwarded NUMBER,
  obj_rejected NUMBER,
  obj_dispatched NUMBER,
  obj_escalated NUMBER,
  legal_obj_type NUMBER,
  icon_id NUMBER,
  allow_bug NUMBER,
  dialog_id NUMBER,
  department VARCHAR2(80 BYTE),
  allow_opp NUMBER,
  allow_contract NUMBER,
  allow_job NUMBER,
  allow_task NUMBER,
  dev NUMBER,
  queue2monitor NUMBER(*,0),
  queue2dist_srvr NUMBER(*,0),
  allow_dialogue NUMBER
);
ALTER TABLE sa.table_queue ADD SUPPLEMENTAL LOG GROUP dmtsora187009997_0 (allow_bug, allow_case, allow_contract, allow_dialogue, allow_dmnd_dtl, allow_job, allow_opp, allow_probdesc, allow_subcase, allow_task, department, description, dev, dialog_id, icon_id, legal_obj_type, max_resp_time, objid, obj_accepted, obj_dispatched, obj_escalated, obj_forwarded, obj_received, obj_rejected, queue2dist_srvr, queue2monitor, shared_pers, sort_by, s_title, title) ALWAYS;
COMMENT ON TABLE sa.table_queue IS 'Queue object that contains tasks awaiting transfer of ownership';
COMMENT ON COLUMN sa.table_queue.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_queue.title IS 'Queue title';
COMMENT ON COLUMN sa.table_queue.shared_pers IS 'Indicates whether the queue is shared or personal; i.e., 0=personal, 1=shared';
COMMENT ON COLUMN sa.table_queue.allow_case IS 'Indicates whether cases are allowed to be dispatched to the queue; i.e., 0=don"t allow, 1=allow';
COMMENT ON COLUMN sa.table_queue.allow_subcase IS 'Indicates whether subcase objects are allowed in the queue; i.e., 0=don"t allow, 1=allow';
COMMENT ON COLUMN sa.table_queue.allow_probdesc IS 'Indicates whether solutions are allowed to be dispatched to the queue; i.e., 0=don"t allow, 1=allow';
COMMENT ON COLUMN sa.table_queue.allow_dmnd_dtl IS 'Indicates whether part request are allowed to be dispatched to the queue; i.e., 0=don"t allow, 1=allow';
COMMENT ON COLUMN sa.table_queue.description IS 'Description of the queue';
COMMENT ON COLUMN sa.table_queue.sort_by IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_queue.max_resp_time IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_queue.obj_received IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_queue.obj_accepted IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_queue.obj_forwarded IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_queue.obj_rejected IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_queue.obj_dispatched IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_queue.obj_escalated IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_queue.legal_obj_type IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_queue.icon_id IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_queue.allow_bug IS 'Indicates whether change requests are allowed to be dispatched to the queue; i.e., 0=don"t allow, 1=allow';
COMMENT ON COLUMN sa.table_queue.dialog_id IS 'Used to distinguish between ClearSupport & Logistics queues; default posts ClearSupport Queue form (728)';
COMMENT ON COLUMN sa.table_queue.department IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_queue.allow_opp IS 'Indicates whether opportunities are allowed to be dispatched to the queue; i.e., 0=don"t allow, 1=allow. Default is allow';
COMMENT ON COLUMN sa.table_queue.allow_contract IS 'Indicates whether contracts/quotes are allowed to be dispatched to the queue; i.e., 0=don"t allow, 1=allow. Default is allow';
COMMENT ON COLUMN sa.table_queue.allow_job IS 'Indicates whether jobs are allowed to be dispatched to the queue; i.e., 0=don"t allow, 1=allow. Default is allow';
COMMENT ON COLUMN sa.table_queue.allow_task IS 'Indicates whether tasks are allowed to be dispatched to the queue; i.e., 0=don"t allow, 1=allow. Default is allow';
COMMENT ON COLUMN sa.table_queue.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_queue.queue2monitor IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_queue.queue2dist_srvr IS 'Remote server the queue is connected to';
COMMENT ON COLUMN sa.table_queue.allow_dialogue IS 'Indicates whether dialogues are allowed to be dispatched to the queue; i.e., 0=don"t allow, 1=allow. Default is allow';