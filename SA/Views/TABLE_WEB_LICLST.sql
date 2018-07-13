CREATE OR REPLACE FORCE VIEW sa.table_web_liclst (objid,web_user_objid,lic_type,host_id,"CLASS",precedence,expires,login_name,s_login_name) AS
select table_web_lease.objid, table_web_user.objid,
 table_web_lease.lic_type, table_web_lease.host_id,
 table_web_lease.class, table_web_lease.precedence,
 table_web_lease.expires, table_web_user.login_name, table_web_user.S_login_name
 from table_web_lease, table_web_user
 where table_web_user.objid = table_web_lease.owner2web_user
 ;
COMMENT ON TABLE sa.table_web_liclst IS 'View which selects Web leases owned by Web users';
COMMENT ON COLUMN sa.table_web_liclst.objid IS 'Web Lease internal record number      UNIQUE';
COMMENT ON COLUMN sa.table_web_liclst.web_user_objid IS 'Web User login name';
COMMENT ON COLUMN sa.table_web_liclst.lic_type IS 'Clarify application license: i.e., WEBSUPPORT, WEBUSER';
COMMENT ON COLUMN sa.table_web_liclst.host_id IS 'Host ID: identifier of remote host (the IP address)';
COMMENT ON COLUMN sa.table_web_liclst."CLASS" IS 'Lease class: 0=meter, 1=license';
COMMENT ON COLUMN sa.table_web_liclst.precedence IS 'Lease precedence: 0=lowest, 1=higher, etc';
COMMENT ON COLUMN sa.table_web_liclst.expires IS 'Date/Time lease will expire';
COMMENT ON COLUMN sa.table_web_liclst.login_name IS 'Web User login name';