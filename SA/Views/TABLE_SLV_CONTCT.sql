CREATE OR REPLACE FORCE VIEW sa.table_slv_contct (objid,loc_objid,addr_objid,first_name,s_first_name,last_name,s_last_name,phone_num,p_site,s_p_site,p_site_id,country_code,address,s_address,city,s_city,"STATE",s_state,country,s_country,zipcode) AS
select table_employee.objid, table_site.objid,
 table_address.objid, table_employee.first_name, table_employee.S_first_name,
 table_employee.last_name, table_employee.S_last_name, table_employee.phone,
 table_site.name, table_site.S_name, table_site.site_id,
 table_country.code, table_address.address, table_address.S_address,
 table_address.city, table_address.S_city, table_address.state, table_address.S_state,
 table_country.name, table_country.S_name, table_address.zipcode
 from table_employee, table_site, table_address,
  table_country
 where table_site.objid = table_employee.supp_person_off2site
 AND table_country.objid = table_address.address2country
 AND table_address.objid = table_site.cust_primaddr2address
 ;