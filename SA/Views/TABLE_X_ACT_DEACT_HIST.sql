CREATE OR REPLACE FORCE VIEW sa.table_x_act_deact_hist (contact_objid,contact_x_cust_id,contact_role_objid,site_objid,site_part_objid,reason,esn,s_esn,x_iccid,x_min,x_service_id,user_objid,agent,s_agent,dealer_objid,dealer,s_dealer,call_trans_objid,date_time,source_sys,action_type,action_text,carrier_objid,carrier,market,total_units,trans_reason,result,x_technology,points,"GROUP_ID",group_name,service_plan_id,service_plan,new_due_date) AS
SELECT table_contact.objid,
    NVL(table_contact.x_cust_id,'-1'),
    NULL,
    table_site.objid,
    table_site_part.objid,
    table_site_part.x_deact_reason,
    table_site_part.x_service_id,
    table_site_part.S_serial_no,
    table_site_part.x_iccid,
    table_site_part.x_min,
    table_site_part.x_service_id,
    table_user.objid,
    table_user.login_name,
    table_user.S_login_name,
    table_dealer.objid,
    table_dealer.name,
    table_dealer.S_name,
    table_x_call_trans.objid,
    table_x_call_trans.x_transact_date,
    table_x_call_trans.x_sourcesystem,
    table_x_call_trans.x_action_type,
    table_x_code_table.x_code_name,
    table_x_carrier.objid,
    table_x_carrier_group.x_carrier_name,
    table_x_carrier.x_mkt_submkt_name,
    table_x_call_trans.x_total_units,
    table_x_call_trans.x_reason,
    table_x_call_trans.x_result,
    table_part_num.x_technology,
    (select sum(nvl(table_x_point_trans.x_points,0)) x_points
     from   table_x_point_trans
     where  table_x_point_trans.POINT_TRANS2REF_TABLE_OBJID = table_x_call_trans.objid
     and    table_x_point_trans.REF_TABLE_NAME              = 'TABLE_X_CALL_TRANS') x_points,
    table_x_call_trans_ext.account_group_id group_id,
    x_account_group.account_group_name group_name,
    table_x_call_trans_ext.service_plan_id,
    x_service_plan.webcsr_display_name service_plan,
    table_x_call_trans.x_new_due_date
  FROM table_part_num,
    table_mod_level,
    table_part_inst pi,
    table_contact,
    table_site,
    table_user,
    table_site table_dealer,
    table_x_code_table,
    table_x_carrier_group,
    table_x_carrier,
    table_x_call_trans,
    table_site_part,
    table_x_call_trans_ext,
    x_account_group,
    x_service_plan
  WHERE 1                                                 =1
  AND table_site_part.objid                               = table_x_call_trans.call_trans2site_part
  AND table_x_call_trans.x_reason                         = 'BYOP REGISTER'
  AND table_x_call_trans.x_result                         = 'Completed'
  AND table_x_carrier.objid(+)                            = table_x_call_trans.x_call_trans2carrier
  AND table_x_carrier_group.objid(+)                      = table_x_carrier.carrier2carrier_group
  AND table_x_code_table.x_code_number                    = table_x_call_trans.x_action_type
  AND table_dealer.objid                                  = table_x_call_trans.x_call_trans2dealer
  AND table_user.objid                                    = table_x_call_trans.x_call_trans2user
  AND table_site.objid(+)                                 = table_site_part.site_part2site
  AND table_mod_level.objid(+)                            = table_site_part.site_part2part_info
  AND table_part_num.objid(+)                             = table_mod_level.part_info2part_num
  AND pi.part_serial_no                                   = table_site_part.x_service_id
  AND table_contact.objid(+)                              = pi.x_part_inst2contact
  AND table_x_call_trans.objid                            = table_x_call_trans_ext.call_trans_ext2call_trans (+)
  AND table_x_call_trans_ext.account_group_id             = x_account_group.objid (+)
  AND table_x_call_trans_ext.service_plan_id              = x_service_plan.objid (+)
  UNION
  SELECT table_contact.objid,
    table_contact.x_cust_id,
    table_contact_role.objid,
    table_site.objid,
    table_site_part.objid,
    table_site_part.x_deact_reason,
    table_site_part.serial_no,
    table_site_part.S_serial_no,
    table_site_part.x_iccid,
    table_site_part.x_min,
    table_site_part.x_service_id,
    table_user.objid,
    table_user.login_name,
    table_user.S_login_name,
    table_dealer.objid,
    table_dealer.name,
    table_dealer.S_name,
    table_x_call_trans.objid,
    table_x_call_trans.x_transact_date,
    table_x_call_trans.x_sourcesystem,
    table_x_call_trans.x_action_type,
    table_x_code_table.x_code_name ,
    table_x_carrier.objid,
    table_x_carrier_group.x_carrier_name,
    table_x_carrier.x_mkt_submkt_name,
    table_x_call_trans.x_total_units,
    table_x_call_trans.x_reason,
    table_x_call_trans.x_result,
    table_part_num.x_technology,
    (select sum(nvl(table_x_point_trans.x_points,0)) x_points
     from   table_x_point_trans
     where  table_x_point_trans.POINT_TRANS2REF_TABLE_OBJID = table_x_call_trans.objid
     and    table_x_point_trans.REF_TABLE_NAME              = 'TABLE_X_CALL_TRANS') x_points,
    table_x_call_trans_ext.account_group_id group_id,
    x_account_group.account_group_name group_name,
    table_x_call_trans_ext.service_plan_id,
    x_service_plan.webcsr_display_name service_plan,
    table_x_call_trans.x_new_due_date
  FROM table_site table_dealer,
    table_contact,
    table_contact_role,
    table_site,
    table_site_part,
    table_user,
    table_x_call_trans,
    table_x_carrier,
    table_x_carrier_group,
    table_part_num,
    table_mod_level,
    table_x_code_table,
    table_x_call_trans_ext,
    x_account_group,
    x_service_plan
  WHERE table_part_num.objid                              = table_mod_level.part_info2part_num
  AND table_contact.objid                                 = table_contact_role.contact_role2contact
  AND table_x_carrier.objid                               = table_x_call_trans.x_call_trans2carrier
  AND table_user.objid                                    = table_x_call_trans.x_call_trans2user
  AND table_site.objid                                    = table_contact_role.contact_role2site
  AND table_mod_level.objid                               = table_site_part.site_part2part_info
  AND table_site.objid                                    = table_site_part.site_part2site
  AND table_dealer.objid                                  = table_x_call_trans.x_call_trans2dealer
  AND table_site_part.objid                               = table_x_call_trans.call_trans2site_part
  AND table_x_carrier_group.objid                         = table_x_carrier.carrier2carrier_group
  AND table_x_code_table.x_code_number                    = table_x_call_trans.x_action_type
  AND table_x_call_trans.objid                            = table_x_call_trans_ext.call_trans_ext2call_trans (+)
  AND table_x_call_trans_ext.account_group_id             = x_account_group.objid (+)
  AND table_x_call_trans_ext.service_plan_id              = x_service_plan.objid (+);