CREATE OR REPLACE FORCE VIEW sa.table_rol_contct (objid,con_objid,loc_objid,addr_objid,first_name,s_first_name,last_name,s_last_name,phone,hours,role_name,s_role_name,primary_site,site,s_site,site_id,site_type,spec_consid,country_code,address,s_address,city,s_city,"STATE",s_state,country,s_country,zipcode,expertise_lev,fax_number,e_mail,mail_stop,title,region,s_region,district,s_district,notes,site_typest,address_2,status,site_alert,cnct_alert,bus_org_objid,org_id,s_org_id,org_name,s_org_name,org_type,salutation,tz_objid,tz_name,s_tz_name,x_cust_id,x_no_name_flag,x_no_address_flag,x_middle_initial,x_no_phone_flag,mdbk,x_new_esn) AS
select table_contact_role.objid, table_contact.objid,
table_site.objid, table_address.objid,
table_contact.first_name, table_contact.S_first_name, table_contact.last_name, table_contact.S_last_name,
table_contact.phone, table_contact.hours,
table_contact_role.role_name, table_contact_role.S_role_name, table_contact_role.primary_site,
table_site.name, table_site.S_name, table_site.site_id,
table_site.type, table_site.spec_consid,
table_country.code, table_address.address, table_address.S_address,
table_address.city, table_address.S_city, table_address.state, table_address.S_state,
table_country.name, table_country.S_name, table_address.zipcode,
table_contact.expertise_lev, table_contact.fax_number,
table_contact.e_mail, table_contact.mail_stop,
table_contact.title, table_site.region, table_site.S_region,
table_site.district, table_site.S_district, table_site.notes,
table_site.site_type, table_address.address_2,
table_contact.status, table_site.alert_ind,
table_contact.alert_ind, table_bus_org.objid,
table_bus_org.org_id, table_bus_org.S_org_id, table_bus_org.name, table_bus_org.S_name,
table_bus_org.type, table_contact.salutation,
table_time_zone.objid, table_time_zone.name, table_time_zone.S_name,
table_contact.x_cust_id, table_contact.x_no_name_flag,
table_contact.x_no_address_flag, table_contact.x_middle_initial,
table_contact.x_no_phone_flag, table_contact.mdbk,
table_contact.x_new_esn
from table_contact_role, table_contact, table_site,
table_address, table_country, table_bus_org,
table_time_zone
where table_country.objid = table_address.address2country
AND table_site.objid = table_contact_role.contact_role2site
AND table_contact.objid = table_contact_role.contact_role2contact
AND table_time_zone.objid = table_address.address2time_zone
AND table_address.objid = table_site.cust_primaddr2address
AND table_bus_org.objid  = nvl(table_site.primary2bus_org,-2);