CREATE OR REPLACE FORCE VIEW sa.table_n_users (n_userid,n_password,n_firstname,s_n_firstname,n_lastname,s_n_lastname,n_address1,s_n_address1,n_address2,n_city,s_n_city,n_state,s_n_state,n_postalcode,n_country,s_n_country,n_telephone,n_telephoneext,n_fax,n_email,n_modificationdate,n_status,n_effectivedate,n_username,s_n_username) AS
select table_user.objid, table_user.password,
 table_employee.first_name, table_employee.S_first_name, table_employee.last_name, table_employee.S_last_name,
 table_address.address, table_address.S_address, table_address.address_2,
 table_address.city, table_address.S_city, table_address.state, table_address.S_state,
 table_address.zipcode, table_country.name, table_country.S_name,
 table_employee.phone, table_employee.on_call_hw,
 table_employee.fax, table_employee.e_mail,
 table_employee.site_strt_date, table_user.status,
 table_employee.wg_strt_date, table_user.login_name, table_user.S_login_name
 from table_user, table_employee, table_address,
  table_country, table_site
 where table_user.objid = table_employee.employee2user
 AND table_address.objid = table_site.cust_primaddr2address
 AND table_country.objid = table_address.address2country
 AND table_site.objid = table_employee.supp_person_off2site
 ;