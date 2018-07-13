CREATE OR REPLACE FORCE VIEW sa.table_acct_site_view (objid,role_name,site_id,site_name,s_site_name,site_type,address,s_address,city,s_city,"STATE",s_state,country_code,site_typest,status,site_status,site_objid,address_objid,country_objid,country,s_country,zipcode,address_2) AS
select table_bus_site_role.objid, table_bus_site_role.role_name,
 table_site.site_id, table_site.name, table_site.S_name,
 table_site.type, table_address.address, table_address.S_address,
 table_address.city, table_address.S_city, table_address.state, table_address.S_state,
 table_country.code, table_site.site_type,
 table_site.status, table_site.site_id,
 table_site.objid, table_address.objid,
 table_country.objid, table_country.name, table_country.S_name,
 table_address.zipcode, table_address.address_2
 from table_bus_site_role, table_site, table_address,
  table_country
 where table_site.objid = table_bus_site_role.bus_site_role2site
 AND table_country.objid = table_address.address2country
 AND table_address.objid = table_site.cust_primaddr2address
 ;