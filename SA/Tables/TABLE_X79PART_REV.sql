CREATE TABLE sa.table_x79part_rev (
  objid NUMBER,
  vendor VARCHAR2(80 BYTE),
  s_vendor VARCHAR2(80 BYTE),
  "VERSION" VARCHAR2(10 BYTE),
  s_version VARCHAR2(10 BYTE),
  server_id NUMBER,
  dev NUMBER,
  part_rev2x79part NUMBER
);
ALTER TABLE sa.table_x79part_rev ADD SUPPLEMENTAL LOG GROUP dmtsora995679639_0 (dev, objid, part_rev2x79part, server_id, s_vendor, s_version, vendor, "VERSION") ALWAYS;
COMMENT ON TABLE sa.table_x79part_rev IS 'Redundant storage of generic part revision information. Reserved; future';
COMMENT ON COLUMN sa.table_x79part_rev.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x79part_rev.vendor IS 'Vendor of the part';
COMMENT ON COLUMN sa.table_x79part_rev."VERSION" IS 'The name of the version';
COMMENT ON COLUMN sa.table_x79part_rev.server_id IS 'Exchange protocol server ID number';
COMMENT ON COLUMN sa.table_x79part_rev.dev IS 'Row version number for mobile distribution purposes';