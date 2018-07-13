CREATE TABLE sa.table_stage_task (
  objid NUMBER,
  task_id VARCHAR2(25 BYTE),
  description VARCHAR2(255 BYTE),
  objective VARCHAR2(255 BYTE),
  appl_id VARCHAR2(20 BYTE),
  "NAME" VARCHAR2(80 BYTE),
  "ACTIVE" NUMBER,
  mandatory_ind NUMBER,
  dev NUMBER,
  task_type2gbst_elm NUMBER(*,0),
  task_status2gbst_elm NUMBER(*,0)
);
ALTER TABLE sa.table_stage_task ADD SUPPLEMENTAL LOG GROUP dmtsora1378708018_0 ("ACTIVE", appl_id, description, dev, mandatory_ind, "NAME", objective, objid, task_id, task_status2gbst_elm, task_type2gbst_elm) ALWAYS;
COMMENT ON TABLE sa.table_stage_task IS 'Specifies a task in a life cycle stage';
COMMENT ON COLUMN sa.table_stage_task.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_stage_task.task_id IS 'Identifier of the task within stage';
COMMENT ON COLUMN sa.table_stage_task.description IS 'Description of the task';
COMMENT ON COLUMN sa.table_stage_task.objective IS 'Objective or desired outcome of the task';
COMMENT ON COLUMN sa.table_stage_task.appl_id IS 'Clarify application identifier of the application which owns the task';
COMMENT ON COLUMN sa.table_stage_task."NAME" IS 'Name of the task';
COMMENT ON COLUMN sa.table_stage_task."ACTIVE" IS 'Indicates whether the task is currently being used; i.e., 0=inactive, 1=active';
COMMENT ON COLUMN sa.table_stage_task.mandatory_ind IS 'Indicates whether the task when previewed for a process instance, must be generated; 0=not mandatory, 1=mandatory, default=0';
COMMENT ON COLUMN sa.table_stage_task.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_stage_task.task_type2gbst_elm IS 'Type of implementation intended for the task';
COMMENT ON COLUMN sa.table_stage_task.task_status2gbst_elm IS 'Status of the task definition';