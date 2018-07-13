CREATE OR REPLACE FORCE VIEW sa.table_x_cntct_code_view (site_part_objid,instance_name,serial_no,s_serial_no,install_date,selected_prd,part_status,service_end_dt,x_service_id,x_min,x_pin,x_deact_reason,x_min_change_flag,x_notify_carrier,x_expire_dt,user_objid,login_name,s_login_name,contact_objid,first_name,s_first_name,last_name,s_last_name,phone,fax_number,e_mail,status,x_middle_initial,x_ss_number,x_dateofbirth,x_gender,x_mobilenumber,x_pagernumber,x_no_name_flag,x_no_address_flag,x_cust_id,x_call_objid,x_transact_date,x_sourcesystem,x_line_status,x_action_type,x_code_objid,x_gen_code,x_sequence) AS
select table_site_part.objid, table_site_part.instance_name,
 table_site_part.serial_no, table_site_part.S_serial_no, table_site_part.install_date,
 table_site_part.selected_prd, table_site_part.part_status,
 table_site_part.service_end_dt, table_site_part.x_service_id,
 table_site_part.x_min, table_site_part.x_pin,
 table_site_part.x_deact_reason, table_site_part.x_min_change_flag,
 table_site_part.x_notify_carrier, table_site_part.x_expire_dt,
 table_user.objid, table_user.login_name, table_user.S_login_name,
 table_contact.objid, table_contact.first_name, table_contact.S_first_name,
 table_contact.last_name, table_contact.S_last_name, table_contact.phone,
 table_contact.fax_number, table_contact.e_mail,
 table_contact.status, table_contact.x_middle_initial, 
 table_contact.x_ss_number, table_contact.x_dateofbirth,
 table_contact.x_gender, table_contact.x_mobilenumber,
 table_contact.x_pagernumber, table_contact.x_no_name_flag,
 table_contact.x_no_address_flag, table_contact.x_cust_id,
 table_x_call_trans.objid, table_x_call_trans.x_transact_date,
 table_x_call_trans.x_sourcesystem, table_x_call_trans.x_line_status,
 table_x_call_trans.x_action_type, table_x_code_hist.objid,
 table_x_code_hist.x_gen_code, table_x_code_hist.x_sequence
 from mtm_site_part22_contact6, table_site_part, table_user, table_contact,
  table_x_call_trans, table_x_code_hist
 where table_site_part.objid = mtm_site_part22_contact6.site_part2contact
 AND mtm_site_part22_contact6.contact2site_part = table_contact.objid
 AND table_site_part.objid = table_x_call_trans.call_trans2site_part
 AND table_x_call_trans.objid = table_x_code_hist.code_hist2call_trans
 AND table_user.objid = table_x_call_trans.x_call_trans2user
;