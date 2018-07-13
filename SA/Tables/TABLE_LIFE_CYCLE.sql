CREATE TABLE sa.table_life_cycle (
  objid NUMBER,
  "NAME" VARCHAR2(50 BYTE),
  description VARCHAR2(255 BYTE),
  appl_id VARCHAR2(20 BYTE),
  "ACTIVE" NUMBER,
  "TEXT" LONG,
  id_number VARCHAR2(80 BYTE),
  is_default NUMBER,
  dev NUMBER
);
ALTER TABLE sa.table_life_cycle ADD SUPPLEMENTAL LOG GROUP dmtsora1902893901_0 ("ACTIVE", appl_id, description, dev, id_number, is_default, "NAME", objid) ALWAYS;
COMMENT ON TABLE sa.table_life_cycle IS 'Specifies a life cycle or a process';
COMMENT ON COLUMN sa.table_life_cycle.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_life_cycle."NAME" IS 'Name of the life cycle';
COMMENT ON COLUMN sa.table_life_cycle.description IS 'Description of the life cycle';
COMMENT ON COLUMN sa.table_life_cycle.appl_id IS 'Clarify application identifier of the application which owns the life cycle';
COMMENT ON COLUMN sa.table_life_cycle."ACTIVE" IS 'Indicates whether the life cycle definition/process is active; i.e., 0=inactive, 1=active';
COMMENT ON COLUMN sa.table_life_cycle."TEXT" IS 'Full description of the life cycle or process';
COMMENT ON COLUMN sa.table_life_cycle.id_number IS 'Unique process number assigned within application ID. Reserved; not used';
COMMENT ON COLUMN sa.table_life_cycle.is_default IS 'Indicates whether the object is the default life_cycle; i.e., 0=no, 1=yes. Used for auto-generated opportunities, which must be related to a life_cycle';
COMMENT ON COLUMN sa.table_life_cycle.dev IS 'Row version number for mobile distribution purposes';