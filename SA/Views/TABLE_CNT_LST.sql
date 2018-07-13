CREATE OR REPLACE FORCE VIEW sa.table_cnt_lst (objid,con_objid,loc_objid,addr_objid,cty_objid,first_name,s_first_name,last_name,s_last_name,phone,site,s_site,site_id,role_name,s_role_name,primary_site,country_code,status) AS
select table_contact_role.objid, table_contact.objid,
 table_site.objid, table_address.objid,
 table_country.objid, table_contact.first_name, table_contact.S_first_name,
 table_contact.last_name, table_contact.S_last_name, table_contact.phone,
 table_site.name, table_site.S_name, table_site.site_id,
 table_contact_role.role_name, table_contact_role.S_role_name, table_contact_role.primary_site,
 table_country.code, table_contact.status
 from table_contact_role, table_contact, table_site,
  table_address, table_country
 where table_country.objid = table_address.address2country
 AND table_site.objid = table_contact_role.contact_role2site
 AND table_contact.objid = table_contact_role.contact_role2contact
 AND table_address.objid = table_site.cust_primaddr2address
 ;
COMMENT ON TABLE sa.table_cnt_lst IS 'Used for <window_id and names>';
COMMENT ON COLUMN sa.table_cnt_lst.objid IS 'Contact_role internal record number';
COMMENT ON COLUMN sa.table_cnt_lst.con_objid IS 'Contact internal record number';
COMMENT ON COLUMN sa.table_cnt_lst.loc_objid IS 'Site internal record number';
COMMENT ON COLUMN sa.table_cnt_lst.addr_objid IS 'Address internal record number';
COMMENT ON COLUMN sa.table_cnt_lst.cty_objid IS 'Country internal record number';
COMMENT ON COLUMN sa.table_cnt_lst.first_name IS 'Contact first name';
COMMENT ON COLUMN sa.table_cnt_lst.last_name IS 'Contact last name';
COMMENT ON COLUMN sa.table_cnt_lst.phone IS 'Contact phone number which includes area code, number, and extension';
COMMENT ON COLUMN sa.table_cnt_lst.site IS 'The name of the site';
COMMENT ON COLUMN sa.table_cnt_lst.site_id IS 'Site ID number assigned according to auto-numbering definition';
COMMENT ON COLUMN sa.table_cnt_lst.role_name IS 'Role of the contact at the site';
COMMENT ON COLUMN sa.table_cnt_lst.primary_site IS 'Indicates whether the related site is where the contact is located; i.e., 0=false, 1=true, default=0';
COMMENT ON COLUMN sa.table_cnt_lst.country_code IS 'Country code used in telephone numbers for that country';
COMMENT ON COLUMN sa.table_cnt_lst.status IS 'Status of contact; i.e., active/inactive/obsolete';