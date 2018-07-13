CREATE OR REPLACE FORCE VIEW sa.smob_users_v (user_objid,login_name,s_login_name,status,first_name,last_name,smart_user_id,parent_user_objid,spiff_id,spiff_accept_date,spiff_confirm_code,"ROLE",epay_id,epay_status,epay_last_update,contact_objid,site_objid,site_name,site_id,x_start_date,x_end_date) AS
select distinct u.objid user_objid,
      u.login_name,
      u.s_login_name,
      decode(substr(u.x_start_date - sysdate,1,1),'-',
              decode(substr(u.x_end_date-sysdate,1,1),'-','INACTIVE','ACTIVE'),'INACTIVE') STATUS,
      e.first_name,
      e.last_name,
      e.employee_no smart_user_id,
      sup_user.objid parent_user_objid,
      comms.signup_id spiff_id,
      comms.terms_accept_date spiff_accept_date,
      comms.signup_confirm_code spiff_confirm_code,
      comms.role role,
      comms.provider_id epay_id,
      comms.prov_cust_status epay_status,
      comms.prov_cust_last_update epay_last_update,
      c.objid contact_objid,
      decode(s.name,'Topp Telecom','',s.objid) site_objid,
      decode(s.name,'Topp Telecom','',s.name) site_name,
      decode(s.name,'Topp Telecom','',s.site_id) site_id,
      u.x_start_date,
      u.x_end_date
from table_employee e,table_employee sup,
     x_dealer_commissions comms,
     table_user u,table_user sup_user,
     table_site s,table_contact c
where e.employee2user = u.objid
and  e.objid = comms.dealer_comms2employee
and   e.emp_supvr2employee= sup.objid
and   sup.employee2user = sup_user.objid
and  e.employee2contact  = c.objid(+)
and u.agent_id = 'SMOB'
and e.supp_person_off2site = s.objid(+);