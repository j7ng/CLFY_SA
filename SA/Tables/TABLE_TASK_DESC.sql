CREATE TABLE sa.table_task_desc (
  objid NUMBER,
  description LONG,
  update_stamp DATE,
  dev NUMBER
);
ALTER TABLE sa.table_task_desc ADD SUPPLEMENTAL LOG GROUP dmtsora813680090_0 (dev, objid, update_stamp) ALWAYS;
COMMENT ON TABLE sa.table_task_desc IS 'Contains description of an action item';
COMMENT ON COLUMN sa.table_task_desc.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_task_desc.description IS 'Description of or comments about an action item';
COMMENT ON COLUMN sa.table_task_desc.update_stamp IS 'Date/time of last update to the task_desc';
COMMENT ON COLUMN sa.table_task_desc.dev IS 'Row version number for mobile distribution purposes';