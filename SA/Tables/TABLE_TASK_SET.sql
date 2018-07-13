CREATE TABLE sa.table_task_set (
  objid NUMBER,
  "ACTIVE" NUMBER,
  "ID" VARCHAR2(40 BYTE),
  "NAME" VARCHAR2(80 BYTE),
  description VARCHAR2(255 BYTE),
  dev NUMBER,
  task_set2cls_group NUMBER(*,0)
);
ALTER TABLE sa.table_task_set ADD SUPPLEMENTAL LOG GROUP dmtsora1868920444_0 ("ACTIVE", description, dev, "ID", "NAME", objid, task_set2cls_group) ALWAYS;