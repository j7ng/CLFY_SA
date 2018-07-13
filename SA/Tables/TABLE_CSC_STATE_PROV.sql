CREATE TABLE sa.table_csc_state_prov (
  objid NUMBER,
  "NAME" VARCHAR2(40 BYTE),
  s_name VARCHAR2(40 BYTE),
  full_name VARCHAR2(80 BYTE),
  code NUMBER,
  is_default NUMBER,
  server_id NUMBER,
  dev NUMBER,
  state_prov2csc_country NUMBER(*,0)
);
ALTER TABLE sa.table_csc_state_prov ADD SUPPLEMENTAL LOG GROUP dmtsora2070836416_0 (code, dev, full_name, is_default, "NAME", objid, server_id, state_prov2csc_country, s_name) ALWAYS;
COMMENT ON TABLE sa.table_csc_state_prov IS 'State or Province object which defines specific states or provinces';
COMMENT ON COLUMN sa.table_csc_state_prov.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_csc_state_prov."NAME" IS 'State or province name';
COMMENT ON COLUMN sa.table_csc_state_prov.full_name IS 'State or province full name';
COMMENT ON COLUMN sa.table_csc_state_prov.code IS 'State or province code';
COMMENT ON COLUMN sa.table_csc_state_prov.is_default IS '1=This is the default state or province for a country, 0=This is not the default';
COMMENT ON COLUMN sa.table_csc_state_prov.server_id IS 'Exchange prodocol server ID number';
COMMENT ON COLUMN sa.table_csc_state_prov.dev IS 'Row version number for mobile distribution purposes';