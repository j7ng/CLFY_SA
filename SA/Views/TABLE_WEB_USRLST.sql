CREATE OR REPLACE FORCE VIEW sa.table_web_usrlst (objid,login_name,s_login_name,"PASSWORD",passwd_chg,web_usr_status,user_objid,usr_login_name,s_usr_login_name,user_status,emp_objid,emp_first_name,s_emp_first_name,emp_last_name,s_emp_last_name,emp_phone,class_name,s_class_name,cs_allowed,cq_allowed) AS
select table_web_user.objid, table_web_user.login_name, table_web_user.S_login_name,
 table_web_user.password, table_web_user.passwd_chg,
 table_web_user.status, table_user.objid,
 table_user.login_name, table_user.S_login_name, table_user.status,
 table_employee.objid, table_employee.first_name, table_employee.S_first_name,
 table_employee.last_name, table_employee.S_last_name, table_employee.phone,
 table_privclass.class_name, table_privclass.S_class_name, table_privclass.CS_allowed,
 table_privclass.CQ_allowed
 from table_web_user, table_user, table_employee,
  table_privclass
 where table_user.objid = table_employee.employee2user
 AND table_user.objid = table_web_user.web_user2user
 AND table_privclass.objid = table_user.user_access2privclass
 ;
COMMENT ON TABLE sa.table_web_usrlst IS 'Used internally to select all the Users associated with Web Users';
COMMENT ON COLUMN sa.table_web_usrlst.objid IS 'Web User internal record number';
COMMENT ON COLUMN sa.table_web_usrlst.login_name IS 'Web User login name';
COMMENT ON COLUMN sa.table_web_usrlst."PASSWORD" IS 'Web User password';
COMMENT ON COLUMN sa.table_web_usrlst.passwd_chg IS 'Date/Time password was last changed; supports password expiration';
COMMENT ON COLUMN sa.table_web_usrlst.web_usr_status IS 'Status of Web User 1=Active, 0=Inactive';
COMMENT ON COLUMN sa.table_web_usrlst.user_objid IS 'User internal record number';
COMMENT ON COLUMN sa.table_web_usrlst.usr_login_name IS 'User login name';
COMMENT ON COLUMN sa.table_web_usrlst.user_status IS 'User status; i.e., 0=inactive, 1=active, default=1';
COMMENT ON COLUMN sa.table_web_usrlst.emp_objid IS 'Employee internal record number';
COMMENT ON COLUMN sa.table_web_usrlst.emp_first_name IS 'Employee last name';
COMMENT ON COLUMN sa.table_web_usrlst.emp_last_name IS 'Employee first name';
COMMENT ON COLUMN sa.table_web_usrlst.emp_phone IS 'Employee phone number';
COMMENT ON COLUMN sa.table_web_usrlst.class_name IS 'Privilage class name';
COMMENT ON COLUMN sa.table_web_usrlst.cs_allowed IS 'Indicates if a ClearSupport license can be checked out';
COMMENT ON COLUMN sa.table_web_usrlst.cq_allowed IS 'Indicates if a ClearQuality license can be checked out';