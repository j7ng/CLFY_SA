CREATE TABLE sa.table_csc_contact (
  objid NUMBER,
  role_name VARCHAR2(80 BYTE),
  server_id NUMBER,
  dev NUMBER,
  contact2csc_org NUMBER(*,0),
  contact2csc_person NUMBER(*,0)
);
ALTER TABLE sa.table_csc_contact ADD SUPPLEMENTAL LOG GROUP dmtsora1606694786_0 (contact2csc_org, contact2csc_person, dev, objid, role_name, server_id) ALWAYS;
COMMENT ON TABLE sa.table_csc_contact IS 'Describes a person and/or their organization and how to contact them';
COMMENT ON COLUMN sa.table_csc_contact.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_csc_contact.role_name IS 'Name of the related person s role in the related organization';
COMMENT ON COLUMN sa.table_csc_contact.server_id IS 'Exchange prodocol server ID number';
COMMENT ON COLUMN sa.table_csc_contact.dev IS 'Row version number for mobile distribution purposes';