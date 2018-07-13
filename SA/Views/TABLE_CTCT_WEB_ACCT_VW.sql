CREATE OR REPLACE FORCE VIEW sa.table_ctct_web_acct_vw (objid,bus_org_objid,contact_objid,web_user_objid,role_name,s_role_name,first_name,s_first_name,last_name,s_last_name,account_name,s_account_name,login_name,s_login_name) AS
select table_ct_bus_role.objid, table_bus_org.objid,
 table_contact.objid, table_web_user.objid,
 table_ct_bus_role.role_name, table_ct_bus_role.S_role_name, table_contact.first_name, table_contact.S_first_name,
 table_contact.last_name, table_contact.S_last_name, table_bus_org.name, table_bus_org.S_name,
 table_web_user.login_name, table_web_user.S_login_name
 from table_ct_bus_role, table_bus_org, table_contact,
  table_web_user
 where table_contact.objid = table_web_user.web_user2contact
 AND table_bus_org.objid = table_ct_bus_role.ct_bus_role2bus_org
 AND table_contact.objid = table_ct_bus_role.ct_bus_role2contact
 ;
COMMENT ON TABLE sa.table_ctct_web_acct_vw IS 'Displays all web users and their roles for the account. Used by form 11671 Web Users';
COMMENT ON COLUMN sa.table_ctct_web_acct_vw.objid IS 'View internal record number';
COMMENT ON COLUMN sa.table_ctct_web_acct_vw.bus_org_objid IS 'Bus_org internal record number';
COMMENT ON COLUMN sa.table_ctct_web_acct_vw.contact_objid IS 'Contact internal record number';
COMMENT ON COLUMN sa.table_ctct_web_acct_vw.web_user_objid IS 'Web_user internal record number';
COMMENT ON COLUMN sa.table_ctct_web_acct_vw.role_name IS 'Name of the contact s role at the Account';
COMMENT ON COLUMN sa.table_ctct_web_acct_vw.first_name IS 'First name of contact';
COMMENT ON COLUMN sa.table_ctct_web_acct_vw.last_name IS 'Last name of contact';
COMMENT ON COLUMN sa.table_ctct_web_acct_vw.account_name IS 'Name of the Account';
COMMENT ON COLUMN sa.table_ctct_web_acct_vw.login_name IS 'Web user s login name';