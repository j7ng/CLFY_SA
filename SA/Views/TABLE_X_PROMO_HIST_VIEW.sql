CREATE OR REPLACE FORCE VIEW sa.table_x_promo_hist_view (promo_trans_objid,contact_objid,contact_x_cust_id,contact_role_objid,site_objid,site_part_objid,reason,esn,s_esn,x_iccid,x_min,x_service_id,user_objid,agent,s_agent,dealer_objid,dealer,s_dealer,call_trans_objid,date_time,source_sys,action_type,carrier_objid,carrier,x_promo_objid,x_promo_code,x_promo_type,x_units,market,action_text,total_units,trans_reason,result,x_technology,x_call_trans_x_esn,x_promo_group) AS
SELECT table_x_promo_hist.objid,
    table_contact.objid,
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
    table_x_carrier.objid,
    table_x_carrier_group.x_carrier_name,
    table_x_promotion.objid,
    table_x_promotion.x_promo_code,
    table_x_promotion.x_promo_type,
    table_x_promotion.x_units,
    table_x_carrier.x_mkt_submkt_name,
    table_x_call_trans.x_action_text,
    table_x_call_trans.x_total_units,
    table_x_call_trans.x_reason,
    table_x_call_trans.x_result,
    table_part_num.x_technology,
    table_x_call_trans.x_service_id,
    table_x_promotion_group.group_desc
  FROM table_site table_dealer,
    table_x_promo_hist,
    table_contact,
    table_contact_role,
    table_site,
    table_site_part,
    table_user,
    table_x_call_trans,
    table_x_carrier,
    table_x_carrier_group,
    table_x_promotion,
    table_part_num,
    table_mod_level,
    table_x_promotion_group
  WHERE table_site.objid          = table_contact_role.contact_role2site
  AND table_dealer.objid          = table_x_call_trans.x_call_trans2dealer
  AND table_site_part.objid       = table_x_call_trans.call_trans2site_part
  AND table_x_carrier_group.objid = table_x_carrier.carrier2carrier_group
  AND table_contact.objid         = table_contact_role.contact_role2contact
  AND table_x_carrier.objid       = table_x_call_trans.x_call_trans2carrier
  AND table_x_promotion.objid     = table_x_promo_hist.promo_hist2x_promotion
  AND table_user.objid            = table_x_call_trans.x_call_trans2user
  AND table_mod_level.objid       = table_site_part.site_part2part_info
  AND table_x_call_trans.objid    = table_x_promo_hist.promo_hist2x_call_trans
  AND table_site.objid            = table_site_part.site_part2site
  AND table_part_num.objid        = table_mod_level.part_info2part_num
  AND table_x_promotion_group.promo_group2x_promo(+) = table_x_promotion.objid;