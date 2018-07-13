CREATE OR REPLACE FORCE VIEW sa.table_qq_con_site (objid,first_name,s_first_name,last_name,s_last_name,site_name,s_site_name,site_id,qq_id,primary_site) AS
select table_contact.objid, table_contact.first_name, table_contact.S_first_name,
 table_contact.last_name, table_contact.S_last_name, table_site.name, table_site.S_name,
 table_site.site_id, table_quick_quote.id,
 table_contact_role.primary_site
 from table_contact, table_site, table_quick_quote,
  table_contact_role
 where table_contact.objid = table_quick_quote.q_quote2contact
 AND table_site.objid = table_contact_role.contact_role2site
 AND table_contact.objid = table_contact_role.contact_role2contact
 ;
COMMENT ON TABLE sa.table_qq_con_site IS 'Used to filter on Contact based on quote ID, contact name, and site from the Incoming Call Form(9580). Reserved; obsolete';
COMMENT ON COLUMN sa.table_qq_con_site.objid IS 'Lead_source internal record number';
COMMENT ON COLUMN sa.table_qq_con_site.first_name IS 'Contact s first name';
COMMENT ON COLUMN sa.table_qq_con_site.last_name IS 'Contact s last name';
COMMENT ON COLUMN sa.table_qq_con_site.site_name IS 'Site name';
COMMENT ON COLUMN sa.table_qq_con_site.site_id IS 'Unique site number assigned according to auto-numbering definition';
COMMENT ON COLUMN sa.table_qq_con_site.qq_id IS 'ID number of the quick quote';
COMMENT ON COLUMN sa.table_qq_con_site.primary_site IS 'Home office site of the contact';