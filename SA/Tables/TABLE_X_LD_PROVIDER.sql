CREATE TABLE sa.table_x_ld_provider (
  objid NUMBER,
  x_ldp_code NUMBER,
  x_ldp_name VARCHAR2(20 BYTE)
);
ALTER TABLE sa.table_x_ld_provider ADD SUPPLEMENTAL LOG GROUP dmtsora727491489_0 (objid, x_ldp_code, x_ldp_name) ALWAYS;
COMMENT ON TABLE sa.table_x_ld_provider IS 'Contains a list of all the long distance providers that are available for a carrier market';
COMMENT ON COLUMN sa.table_x_ld_provider.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_ld_provider.x_ldp_code IS 'Long Distance Provider Code';
COMMENT ON COLUMN sa.table_x_ld_provider.x_ldp_name IS 'Long Distance Provider Name';