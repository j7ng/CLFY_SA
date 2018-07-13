CREATE OR REPLACE FORCE VIEW sa.table_cnt_weblst (objid,con_objid,web_objid,loc_objid,addr_objid,cty_objid,first_name,s_first_name,last_name,s_last_name,phone,primary_site,site,s_site,site_id,country_code,status,login,s_login,"PASSWORD",web_status,user_key,passwd_chg) AS
select table_contact_role.objid, table_contact.objid,
 table_web_user.objid, table_site.objid,
 table_address.objid, table_country.objid,
 table_contact.first_name, table_contact.S_first_name, table_contact.last_name, table_contact.S_last_name,
 table_contact.phone, table_contact_role.primary_site,
 table_site.name, table_site.S_name, table_site.site_id,
 table_country.code, table_contact.status,
 table_web_user.login_name, table_web_user.S_login_name, table_web_user.password,
 table_web_user.status, table_web_user.user_key,
 table_web_user.passwd_chg
 from table_contact_role, table_contact, table_web_user,
  table_site, table_address, table_country
 where table_country.objid = table_address.address2country
 AND table_contact.objid = table_contact_role.contact_role2contact
 AND table_address.objid = table_site.cust_primaddr2address
 AND table_site.objid = table_contact_role.contact_role2site
 AND table_contact.objid = table_web_user.web_user2contact
 ;
COMMENT ON TABLE sa.table_cnt_weblst IS 'Used for <window_id and names>';
COMMENT ON COLUMN sa.table_cnt_weblst.objid IS 'Contact_role internal record number';
COMMENT ON COLUMN sa.table_cnt_weblst.con_objid IS 'Contact internal record number';
COMMENT ON COLUMN sa.table_cnt_weblst.web_objid IS 'Web User internal record number';
COMMENT ON COLUMN sa.table_cnt_weblst.loc_objid IS 'Site internal record number';
COMMENT ON COLUMN sa.table_cnt_weblst.addr_objid IS 'Address internal record number';
COMMENT ON COLUMN sa.table_cnt_weblst.cty_objid IS 'Country internal record number';
COMMENT ON COLUMN sa.table_cnt_weblst.first_name IS 'Contact first name';
COMMENT ON COLUMN sa.table_cnt_weblst.last_name IS 'Contact last name';
COMMENT ON COLUMN sa.table_cnt_weblst.phone IS 'Contact phone number which includes area code, number, and extension';
COMMENT ON COLUMN sa.table_cnt_weblst.primary_site IS 'Indicates whether the related site is where the contact is located; i.e., 0=false, 1=true, default=0';
COMMENT ON COLUMN sa.table_cnt_weblst.site IS 'Name of the site';
COMMENT ON COLUMN sa.table_cnt_weblst.site_id IS 'Site ID number assigned according to auto-numbering definition';
COMMENT ON COLUMN sa.table_cnt_weblst.country_code IS 'Country code used in telephone numbers for that country';
COMMENT ON COLUMN sa.table_cnt_weblst.status IS 'Status of contact; i.e., active/inactive/obsolete';
COMMENT ON COLUMN sa.table_cnt_weblst.login IS 'Web User login name';
COMMENT ON COLUMN sa.table_cnt_weblst."PASSWORD" IS 'Web User password';
COMMENT ON COLUMN sa.table_cnt_weblst.web_status IS 'Status of web user';
COMMENT ON COLUMN sa.table_cnt_weblst.user_key IS 'System generated key value to locate WebSupport user';
COMMENT ON COLUMN sa.table_cnt_weblst.passwd_chg IS 'Date/Time password was last changed';