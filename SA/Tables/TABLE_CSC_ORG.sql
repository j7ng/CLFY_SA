CREATE TABLE sa.table_csc_org (
  objid NUMBER,
  "NAME" VARCHAR2(80 BYTE),
  business VARCHAR2(255 BYTE),
  region VARCHAR2(80 BYTE),
  phone VARCHAR2(20 BYTE),
  fax VARCHAR2(20 BYTE),
  alt_phone VARCHAR2(20 BYTE),
  email VARCHAR2(80 BYTE),
  server_id NUMBER,
  dev NUMBER,
  csc_org2csc_address NUMBER(*,0)
);
ALTER TABLE sa.table_csc_org ADD SUPPLEMENTAL LOG GROUP dmtsora1783737991_0 (alt_phone, business, csc_org2csc_address, dev, email, fax, "NAME", objid, phone, region, server_id) ALWAYS;
COMMENT ON TABLE sa.table_csc_org IS 'Contains organization information. It may be used independently, or as part of a contact description';
COMMENT ON COLUMN sa.table_csc_org.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_csc_org."NAME" IS 'Name of the organization';
COMMENT ON COLUMN sa.table_csc_org.business IS 'Description of organization s primary business';
COMMENT ON COLUMN sa.table_csc_org.region IS 'Description of organization s location';
COMMENT ON COLUMN sa.table_csc_org.phone IS 'Primary phone number for the organization';
COMMENT ON COLUMN sa.table_csc_org.fax IS 'Primary fax number for organization';
COMMENT ON COLUMN sa.table_csc_org.alt_phone IS 'Alternate phone number for the organization';
COMMENT ON COLUMN sa.table_csc_org.email IS 'Organization s email address';
COMMENT ON COLUMN sa.table_csc_org.server_id IS 'Exchange prodocol server ID number';
COMMENT ON COLUMN sa.table_csc_org.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_csc_org.csc_org2csc_address IS 'Related CSC address';