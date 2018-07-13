CREATE TABLE sa.table_state_prov (
  objid NUMBER,
  "NAME" VARCHAR2(40 BYTE),
  s_name VARCHAR2(40 BYTE),
  full_name VARCHAR2(80 BYTE),
  code NUMBER,
  is_default NUMBER,
  dev NUMBER,
  state_prov2country NUMBER(*,0),
  display_order NUMBER
);
ALTER TABLE sa.table_state_prov ADD SUPPLEMENTAL LOG GROUP dmtsora1691877239_0 (code, dev, display_order, full_name, is_default, "NAME", objid, state_prov2country, s_name) ALWAYS;
COMMENT ON TABLE sa.table_state_prov IS 'State or Province object which defines specific states or provinces';
COMMENT ON COLUMN sa.table_state_prov.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_state_prov."NAME" IS 'State or province name';
COMMENT ON COLUMN sa.table_state_prov.full_name IS 'State or province full name';
COMMENT ON COLUMN sa.table_state_prov.code IS 'State or province code';
COMMENT ON COLUMN sa.table_state_prov.is_default IS '1=This is the default state or province for a country, 0=This is not the default';
COMMENT ON COLUMN sa.table_state_prov.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_state_prov.display_order IS 'Sort order or rank within for display of the object. If not set, display order defaults to name order';