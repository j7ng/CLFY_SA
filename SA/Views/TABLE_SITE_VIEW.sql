CREATE OR REPLACE FORCE VIEW sa.table_site_view (objid,site_id,site_name,s_site_name,site_type,address,s_address,city,s_city,"STATE",s_state,country_code,site_typest,status,bus_org_objid,org_id,s_org_id,org_name,s_org_name,org_type,country_name,s_country_name,zipcode,country_objid,address_objid,region,s_region,district,s_district,address_2) AS
select table_site.objid, table_site.site_id,
 table_site.name, table_site.S_name, table_site.type,
 table_address.address, table_address.S_address, table_address.city, table_address.S_city,
 table_address.state, table_address.S_state, table_country.code,
 table_site.site_type, table_site.status,
 table_bus_org.objid, table_bus_org.org_id, table_bus_org.S_org_id,
 table_bus_org.name, table_bus_org.S_name, table_bus_org.type,
 table_country.name, table_country.S_name, table_address.zipcode,
 table_country.objid, table_address.objid,
 table_site.region, table_site.S_region, table_site.district, table_site.S_district,
 table_address.address_2
 from table_site, table_address, table_country,
  table_bus_org
 where table_country.objid = table_address.address2country
 AND table_address.objid = table_site.cust_primaddr2address
 AND table_bus_org.objid = table_site.primary2bus_org
 ;