CREATE TABLE sa.table_template (
  objid NUMBER,
  dev NUMBER,
  id_number VARCHAR2(40 BYTE),
  s_id_number VARCHAR2(40 BYTE),
  title VARCHAR2(255 BYTE),
  s_title VARCHAR2(255 BYTE),
  "BODY" LONG,
  update_stamp DATE,
  "ACTIVE" NUMBER,
  tmplt2user NUMBER,
  tmplt2workaround NUMBER
);
ALTER TABLE sa.table_template ADD SUPPLEMENTAL LOG GROUP dmtsora1352802476_0 ("ACTIVE", dev, id_number, objid, s_id_number, s_title, title, tmplt2user, tmplt2workaround, update_stamp) ALWAYS;
COMMENT ON TABLE sa.table_template IS 'Contains pre-defined, auto-suggest responses to Mixed Media requests';
COMMENT ON COLUMN sa.table_template.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_template.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_template.id_number IS 'Unique template number assigned based on auto-numbering definition';
COMMENT ON COLUMN sa.table_template.title IS 'Title of the template';
COMMENT ON COLUMN sa.table_template."BODY" IS 'Body of the template';
COMMENT ON COLUMN sa.table_template.update_stamp IS 'Date/time of last update to the template';
COMMENT ON COLUMN sa.table_template."ACTIVE" IS 'Indicates whether the template is active; i.e., 0=inactive, 1=active, default=1';
COMMENT ON COLUMN sa.table_template.tmplt2user IS 'User who originated the template';
COMMENT ON COLUMN sa.table_template.tmplt2workaround IS 'Workaround used by the template';