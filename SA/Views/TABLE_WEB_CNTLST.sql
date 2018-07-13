CREATE OR REPLACE FORCE VIEW sa.table_web_cntlst (objid,login_name,s_login_name,"PASSWORD",passwd_chg,web_usr_status,contact_objid,first_name,s_first_name,last_name,s_last_name,phone,contact_status) AS
select table_web_user.objid, table_web_user.login_name, table_web_user.S_login_name,
 table_web_user.password, table_web_user.passwd_chg,
 table_web_user.status, table_contact.objid,
 table_contact.first_name, table_contact.S_first_name, table_contact.last_name, table_contact.S_last_name,
 table_contact.phone, table_contact.status
 from table_web_user, table_contact
 where table_contact.objid = table_web_user.web_user2contact
 ;
COMMENT ON TABLE sa.table_web_cntlst IS 'View used internally to select all the Contacts associated with Web Users';
COMMENT ON COLUMN sa.table_web_cntlst.objid IS 'Web_User internal record number';
COMMENT ON COLUMN sa.table_web_cntlst.login_name IS 'Web User login name';
COMMENT ON COLUMN sa.table_web_cntlst."PASSWORD" IS 'Web User password';
COMMENT ON COLUMN sa.table_web_cntlst.passwd_chg IS 'Date/Time password was last changed; supports password expiration';
COMMENT ON COLUMN sa.table_web_cntlst.web_usr_status IS 'Status of Web User: 1=Active, 0=Inactive';
COMMENT ON COLUMN sa.table_web_cntlst.contact_objid IS 'Contact internal record number';
COMMENT ON COLUMN sa.table_web_cntlst.first_name IS 'Contact first name';
COMMENT ON COLUMN sa.table_web_cntlst.last_name IS 'Contact last name';
COMMENT ON COLUMN sa.table_web_cntlst.phone IS 'Contact phone number which includes area code, number, and extension';
COMMENT ON COLUMN sa.table_web_cntlst.contact_status IS 'Status of Contact 0=Active, 1=Inactive, 2=Obsolete';