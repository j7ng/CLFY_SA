CREATE OR REPLACE FORCE VIEW sa.table_sfaacctsite (objid,role_name,account_id,s_account_id,account_name,s_account_name,account_type,account_phone,account_fax,account_desc,account_website,site_id,site_name,s_site_name,site_type,address,s_address,zipcode,city,s_city,"STATE",s_state,country_code,site_typest,status,site_status,site_objid,address_objid,country_objid,account_objid) AS
select table_bus_site_role.objid, table_bus_site_role.role_name,
 table_bus_org.org_id, table_bus_org.S_org_id, table_bus_org.name, table_bus_org.S_name,
 table_bus_org.type, table_bus_org.phone,
 table_bus_org.fax, table_bus_org.business_desc,
 table_bus_org.web_site, table_site.site_id,
 table_site.name, table_site.S_name, table_site.type,
 table_address.address, table_address.S_address, table_address.zipcode,
 table_address.city, table_address.S_city, table_address.state, table_address.S_state,
 table_country.code, table_site.site_type,
 table_site.status, table_site.site_id,
 table_site.objid, table_address.objid,
 table_country.objid, table_bus_org.objid
 from table_bus_site_role, table_bus_org, table_site,
  table_address, table_country
 where table_bus_org.objid = table_bus_site_role.bus_site_role2bus_org
 AND table_country.objid = table_address.address2country
 AND table_address.objid = table_site.cust_primaddr2address
 AND table_site.objid = table_bus_site_role.bus_site_role2site
 ;
COMMENT ON TABLE sa.table_sfaacctsite IS 'Account, site and address information used on form Console-Sales (12000)';
COMMENT ON COLUMN sa.table_sfaacctsite.objid IS 'bus_site_role internal record number';
COMMENT ON COLUMN sa.table_sfaacctsite.role_name IS 'The name of the role';
COMMENT ON COLUMN sa.table_sfaacctsite.account_id IS 'Account ID number';
COMMENT ON COLUMN sa.table_sfaacctsite.account_name IS 'Account name';
COMMENT ON COLUMN sa.table_sfaacctsite.account_type IS 'Account type';
COMMENT ON COLUMN sa.table_sfaacctsite.account_phone IS 'Main account phone number';
COMMENT ON COLUMN sa.table_sfaacctsite.account_fax IS 'Main account fax number';
COMMENT ON COLUMN sa.table_sfaacctsite.account_desc IS 'Account description';
COMMENT ON COLUMN sa.table_sfaacctsite.account_website IS 'The URL of the main web page of the organization';
COMMENT ON COLUMN sa.table_sfaacctsite.site_id IS 'Site ID number assigned according to auto-numbering definition';
COMMENT ON COLUMN sa.table_sfaacctsite.site_name IS 'Site name';
COMMENT ON COLUMN sa.table_sfaacctsite.site_type IS 'Mnemonic representation of the integer site type field';
COMMENT ON COLUMN sa.table_sfaacctsite.address IS 'Site s primaryaddress';
COMMENT ON COLUMN sa.table_sfaacctsite.zipcode IS 'Site s primaryaddress zipcode';
COMMENT ON COLUMN sa.table_sfaacctsite.city IS 'Site s primary address city';
COMMENT ON COLUMN sa.table_sfaacctsite."STATE" IS 'Site s primary address state';
COMMENT ON COLUMN sa.table_sfaacctsite.country_code IS 'Site s primary address country code';
COMMENT ON COLUMN sa.table_sfaacctsite.site_typest IS 'Site Translation of the site type';
COMMENT ON COLUMN sa.table_sfaacctsite.status IS 'Status of site; i.e., active, inactive, obsolete';
COMMENT ON COLUMN sa.table_sfaacctsite.site_status IS 'Used for display of site status. Must be replaced with active/inactive/obsolete in display';
COMMENT ON COLUMN sa.table_sfaacctsite.site_objid IS 'Site internal record number';
COMMENT ON COLUMN sa.table_sfaacctsite.address_objid IS 'Address internal record number';
COMMENT ON COLUMN sa.table_sfaacctsite.country_objid IS 'Country internal record number';
COMMENT ON COLUMN sa.table_sfaacctsite.account_objid IS 'Account internal record number';