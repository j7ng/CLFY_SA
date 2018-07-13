CREATE TABLE sa.table_contact_role (
  objid NUMBER,
  role_name VARCHAR2(80 BYTE),
  s_role_name VARCHAR2(80 BYTE),
  primary_site NUMBER,
  dev NUMBER,
  contact_role2site NUMBER(*,0),
  contact_role2contact NUMBER(*,0),
  contact_role2gbst_elm NUMBER(*,0),
  update_stamp DATE
);
ALTER TABLE sa.table_contact_role ADD SUPPLEMENTAL LOG GROUP dmtsora810000364_0 (contact_role2contact, contact_role2gbst_elm, contact_role2site, dev, objid, primary_site, role_name, s_role_name, update_stamp) ALWAYS;
COMMENT ON TABLE sa.table_contact_role IS 'Contact role object; describes roles that contacts play at customer sites';
COMMENT ON COLUMN sa.table_contact_role.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_contact_role.role_name IS 'Role name';
COMMENT ON COLUMN sa.table_contact_role.s_role_name IS 'Searchable Role Name';
COMMENT ON COLUMN sa.table_contact_role.primary_site IS 'Indicates the site where the contact is located; i.e., 0=false, 1=true, default=0';
COMMENT ON COLUMN sa.table_contact_role.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_contact_role.contact_role2site IS 'Reference objid in table_site';
COMMENT ON COLUMN sa.table_contact_role.contact_role2contact IS 'Reference objid in table_contact';
COMMENT ON COLUMN sa.table_contact_role.contact_role2gbst_elm IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_contact_role.update_stamp IS 'Date/time of last update to the contact_role';