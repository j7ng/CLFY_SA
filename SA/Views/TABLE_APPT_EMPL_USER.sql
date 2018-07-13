CREATE OR REPLACE FORCE VIEW sa.table_appt_empl_user (employee,first_name,s_first_name,last_name,s_last_name,user_id,status,employee_no,work_group,region,s_region,district,s_district,city,s_city,"STATE",s_state) AS
select table_employee.objid, table_employee.first_name, table_employee.S_first_name,
 table_employee.last_name, table_employee.S_last_name, table_user.objid,
 table_user.status, table_employee.employee_no,
 table_employee.work_group, table_site.region, table_site.S_region,
 table_site.district, table_site.S_district, table_address.city, table_address.S_city,
 table_address.state, table_address.S_state
 from table_employee, table_user, table_site,
  table_address
 where table_user.objid = table_employee.employee2user
 AND table_address.objid = table_site.cust_primaddr2address
 AND table_site.objid = table_employee.supp_person_off2site
 ;
COMMENT ON TABLE sa.table_appt_empl_user IS 'View of employee information. Used by form Schedule Tracker (899)';
COMMENT ON COLUMN sa.table_appt_empl_user.employee IS 'Employee unique object ID';
COMMENT ON COLUMN sa.table_appt_empl_user.first_name IS 'Employee first name';
COMMENT ON COLUMN sa.table_appt_empl_user.last_name IS 'Employee last name';
COMMENT ON COLUMN sa.table_appt_empl_user.user_id IS 'Employee user ID';
COMMENT ON COLUMN sa.table_appt_empl_user.status IS 'User status; i.e., 0=inactive, 1=active, default=1';
COMMENT ON COLUMN sa.table_appt_empl_user.employee_no IS 'The employee ID number';
COMMENT ON COLUMN sa.table_appt_empl_user.work_group IS 'Work group to which employee belongs';
COMMENT ON COLUMN sa.table_appt_empl_user.region IS 'Region to which the site belongs';
COMMENT ON COLUMN sa.table_appt_empl_user.district IS 'District to which the site belongs';
COMMENT ON COLUMN sa.table_appt_empl_user.city IS 'Employee site city';
COMMENT ON COLUMN sa.table_appt_empl_user."STATE" IS 'Employee site state';