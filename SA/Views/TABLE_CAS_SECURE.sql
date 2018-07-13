CREATE OR REPLACE FORCE VIEW sa.table_cas_secure (contact_objid,role_objid,site_objid,case_objid,first_name,s_first_name,last_name,s_last_name,phone,role_name,s_role_name,primary_site,site_id,site_name,s_site_name,case_title,s_case_title,case_id) AS
select table_contact.objid, table_contact_role.objid,
 table_site.objid, table_case.objid,
 table_contact.first_name, table_contact.S_first_name, table_contact.last_name, table_contact.S_last_name,
 table_contact.phone, table_contact_role.role_name, table_contact_role.S_role_name,
 table_contact_role.primary_site, table_site.site_id,
 table_site.name, table_site.S_name, table_case.title, table_case.S_title,
 table_case.id_number
 from table_contact, table_contact_role, table_site,
  table_case
 where table_site.objid = table_case.case_reporter2site
 AND table_site.objid = table_contact_role.contact_role2site
 AND table_contact.objid = table_contact_role.contact_role2contact
 ;
COMMENT ON TABLE sa.table_cas_secure IS 'View which supports case level security in WebSupport';
COMMENT ON COLUMN sa.table_cas_secure.contact_objid IS 'Contact internal record number';
COMMENT ON COLUMN sa.table_cas_secure.role_objid IS 'Contact_role internal record number';
COMMENT ON COLUMN sa.table_cas_secure.site_objid IS 'Site internal record number';
COMMENT ON COLUMN sa.table_cas_secure.case_objid IS 'Case internal record number';
COMMENT ON COLUMN sa.table_cas_secure.first_name IS 'Contact first name';
COMMENT ON COLUMN sa.table_cas_secure.last_name IS 'Contact last name';
COMMENT ON COLUMN sa.table_cas_secure.phone IS 'Contact phone number which includes area code, number, and extension';
COMMENT ON COLUMN sa.table_cas_secure.role_name IS 'Role name';
COMMENT ON COLUMN sa.table_cas_secure.primary_site IS 'Indicates the site where the contact is located';
COMMENT ON COLUMN sa.table_cas_secure.site_id IS 'Site ID number assigned according to auto-numbering definition';
COMMENT ON COLUMN sa.table_cas_secure.site_name IS 'Site name';
COMMENT ON COLUMN sa.table_cas_secure.case_title IS 'Case or service call title; summary of case details';
COMMENT ON COLUMN sa.table_cas_secure.case_id IS 'Unique case number assigned based on auto-numbering definition';