CREATE TABLE sa.table_cls_factory (
  objid NUMBER,
  title VARCHAR2(80 BYTE),
  focus_type NUMBER,
  context_type NUMBER,
  shared_pers NUMBER,
  "ACTIVE" NUMBER,
  mandatory_ind NUMBER,
  dev NUMBER,
  factory2user NUMBER(*,0),
  factory2subcase NUMBER(*,0),
  factory2stage_task NUMBER(*,0),
  factory2task NUMBER(*,0)
);
ALTER TABLE sa.table_cls_factory ADD SUPPLEMENTAL LOG GROUP dmtsora976638657_0 ("ACTIVE", context_type, dev, factory2stage_task, factory2subcase, factory2task, factory2user, focus_type, mandatory_ind, objid, shared_pers, title) ALWAYS;
COMMENT ON TABLE sa.table_cls_factory IS 'Defines objects needed for generating other objects';
COMMENT ON COLUMN sa.table_cls_factory.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_cls_factory.title IS 'Title of the template';
COMMENT ON COLUMN sa.table_cls_factory.focus_type IS 'Object type ID of the root object being generated; e.g., 24=subcase';
COMMENT ON COLUMN sa.table_cls_factory.context_type IS 'Object type ID of the object being generated for any contextual information needed to generate the focus_type object; e.g., 0=case as the context for subcase generation';
COMMENT ON COLUMN sa.table_cls_factory.shared_pers IS 'Indicates whether the template is shareable with users other than the originator/current owner; i.e., 0=private, 1=shareable, default=1';
COMMENT ON COLUMN sa.table_cls_factory."ACTIVE" IS 'Indicates whether the template is active; i.e., 0=inactive, 1=active, default=1';
COMMENT ON COLUMN sa.table_cls_factory.mandatory_ind IS 'Indicates whether the task when previewed for a process instance, must be generated; 0=not mandatory, 1=mandatory, default=0';
COMMENT ON COLUMN sa.table_cls_factory.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_cls_factory.factory2subcase IS 'Example subcase used in auto generation';
COMMENT ON COLUMN sa.table_cls_factory.factory2stage_task IS 'Task which the factory implements';
COMMENT ON COLUMN sa.table_cls_factory.factory2task IS 'Example task used in auto task generation';