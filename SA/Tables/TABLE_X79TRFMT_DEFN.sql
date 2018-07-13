CREATE TABLE sa.table_x79trfmt_defn (
  objid NUMBER,
  dev NUMBER,
  tr_format_id NUMBER,
  server_id NUMBER
);
ALTER TABLE sa.table_x79trfmt_defn ADD SUPPLEMENTAL LOG GROUP dmtsora1668912051_0 (dev, objid, server_id, tr_format_id) ALWAYS;
COMMENT ON TABLE sa.table_x79trfmt_defn IS 'Represents an instance of an alias which identifies a network object. Reserved; future';
COMMENT ON COLUMN sa.table_x79trfmt_defn.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x79trfmt_defn.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_x79trfmt_defn.tr_format_id IS 'Identifies a trouble report format';
COMMENT ON COLUMN sa.table_x79trfmt_defn.server_id IS 'Exchange protocol server ID number';