CREATE OR REPLACE FORCE VIEW sa.table_empl_view (employee,user_id,site_id,login_name,s_login_name,fax,beeper,e_mail,normal_biz_high,normal_biz_mid,normal_biz_low,after_biz_high,after_biz_mid,after_biz_low) AS
select table_employee.objid, table_user.objid,
 table_employee.supp_person_off2site, table_user.login_name, table_user.S_login_name,
 table_employee.fax, table_employee.beeper,
 table_employee.e_mail, table_employee.normal_biz_high,
 table_employee.normal_biz_mid, table_employee.normal_biz_low,
 table_employee.after_biz_high, table_employee.after_biz_mid,
 table_employee.after_biz_low
 from table_employee, table_user
 where table_user.objid = table_employee.employee2user
 AND table_employee.supp_person_off2site IS NOT NULL
 ;
COMMENT ON TABLE sa.table_empl_view IS 'View of employee and employees business hours';
COMMENT ON COLUMN sa.table_empl_view.employee IS 'Employee internal record number';
COMMENT ON COLUMN sa.table_empl_view.user_id IS 'User internal record number';
COMMENT ON COLUMN sa.table_empl_view.site_id IS 'Site internal record number';
COMMENT ON COLUMN sa.table_empl_view.login_name IS 'User login name';
COMMENT ON COLUMN sa.table_empl_view.fax IS 'Employee s fax number which includes area code, number, and extension';
COMMENT ON COLUMN sa.table_empl_view.beeper IS 'Employee s beeper number which includes area code and number';
COMMENT ON COLUMN sa.table_empl_view.e_mail IS 'Employee s e-mail address';
COMMENT ON COLUMN sa.table_empl_view.normal_biz_high IS 'High urgency notify method during business hours';
COMMENT ON COLUMN sa.table_empl_view.normal_biz_mid IS 'Medium urgency notify method during business hours';
COMMENT ON COLUMN sa.table_empl_view.normal_biz_low IS 'Low urgency notify method during business hours';
COMMENT ON COLUMN sa.table_empl_view.after_biz_high IS 'High urgency notify method after business hours';
COMMENT ON COLUMN sa.table_empl_view.after_biz_mid IS 'Medium urgency notify method after business hours';
COMMENT ON COLUMN sa.table_empl_view.after_biz_low IS 'Low urgency notify method after business hours';