CREATE OR REPLACE FORCE VIEW sa.table_empl_user (employee,location_id,address_id,first_name,s_first_name,last_name,s_last_name,phone_num,p_site,s_p_site,p_site_id,p_site_type,country_code,address,s_address,city,s_city,"STATE",s_state,country,s_country,zipcode,login_name,s_login_name,user_id,status,acting_super,available,avail_note,allow_proxy,printer,labor_rate,node_id) AS
select table_employee.objid, table_site.objid,
 table_address.objid, table_employee.first_name, table_employee.S_first_name,
 table_employee.last_name, table_employee.S_last_name, table_employee.phone,
 table_site.name, table_site.S_name, table_site.site_id,
 table_site.type, table_country.code,
 table_address.address, table_address.S_address, table_address.city, table_address.S_city,
 table_address.state, table_address.S_state, table_country.name, table_country.S_name,
 table_address.zipcode, table_user.login_name, table_user.S_login_name,
 table_user.objid, table_user.status,
 table_employee.acting_supvr, table_employee.available,
 table_employee.avail_note, table_employee.allow_proxy,
 table_employee.printer, table_employee.labor_rate,
 table_user.node_id
 from table_employee, table_site, table_address,
  table_country, table_user
 where table_user.objid = table_employee.employee2user
 AND table_country.objid = table_address.address2country
 AND table_site.objid = table_employee.supp_person_off2site
 AND table_address.objid = table_site.cust_primaddr2address
 ;