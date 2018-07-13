CREATE TABLE sa.table_wipbin (
  objid NUMBER,
  title VARCHAR2(24 BYTE),
  s_title VARCHAR2(24 BYTE),
  description VARCHAR2(255 BYTE),
  ranking_rule VARCHAR2(80 BYTE),
  icon_id NUMBER,
  dialog_id NUMBER,
  dev NUMBER,
  wipbin_owner2user NUMBER(*,0)
);
ALTER TABLE sa.table_wipbin ADD SUPPLEMENTAL LOG GROUP dmtsora2129522898_0 (description, dev, dialog_id, icon_id, objid, ranking_rule, s_title, title, wipbin_owner2user) ALWAYS;
COMMENT ON TABLE sa.table_wipbin IS 'Work in Process bin object which contains an individual s work in process; e.g., cases, subcases, solutions, part requests or change requests';
COMMENT ON COLUMN sa.table_wipbin.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_wipbin.title IS 'WIPbin title';
COMMENT ON COLUMN sa.table_wipbin.description IS 'WIPbin description';
COMMENT ON COLUMN sa.table_wipbin.ranking_rule IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_wipbin.icon_id IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_wipbin.dialog_id IS 'Used to distinguish between ClearSupport & Logistics WIPbins; default posts ClearSupport WIPbin form (375)';
COMMENT ON COLUMN sa.table_wipbin.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_wipbin.wipbin_owner2user IS 'User that owns the WIPbin';