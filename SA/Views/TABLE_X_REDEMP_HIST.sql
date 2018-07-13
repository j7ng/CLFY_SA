CREATE OR REPLACE FORCE VIEW sa.table_x_redemp_hist (contact_objid,contact_x_cust_id,contact_role_objid,site_objid,site_part_objid,reason,esn,s_esn,x_iccid,x_min,x_service_id,user_objid,agent,s_agent,dealer_objid,dealer,s_dealer,call_trans_objid,date_time,source_sys,action_type,carrier_objid,carrier,x_red_card_objid,smp,red_code,units,market,action_text,total_units,trans_reason,result,x_technology) AS
select table_contact.objid, table_contact.x_cust_id,
 table_contact_role.objid, table_site.objid,
 table_site_part.objid, table_site_part.x_deact_reason,
 table_site_part.serial_no, table_site_part.S_serial_no, table_site_part.x_iccid,
 table_site_part.x_min, table_site_part.x_service_id,
 table_user.objid, table_user.login_name, table_user.S_login_name,
 table_dealer.objid, table_dealer.name, table_dealer.S_name,
 table_x_call_trans.objid, table_x_call_trans.x_transact_date,
 table_x_call_trans.x_sourcesystem, table_x_call_trans.x_action_type,
 table_x_carrier.objid, table_x_carrier_group.x_carrier_name,
 table_x_red_card.objid, table_x_red_card.x_smp,
 table_x_red_card.x_red_code, table_x_red_card.x_red_units,
 table_x_carrier.x_mkt_submkt_name, table_x_code_table.x_code_name,
 table_x_call_trans.x_total_units, table_x_call_trans.x_reason,
 table_x_call_trans.x_result, table_part_num.x_technology
 from table_site table_dealer, table_contact, table_contact_role, table_site,
  table_site_part, table_user, table_x_call_trans,
  table_x_carrier, table_x_carrier_group, table_x_red_card,
  table_part_num, table_mod_level, table_x_code_table
 where table_mod_level.objid = table_site_part.site_part2part_info
 AND table_contact.objid = table_contact_role.contact_role2contact
 AND table_site.objid = table_contact_role.contact_role2site
 AND table_x_call_trans.objid = table_x_red_card.red_card2call_trans
 AND table_user.objid = table_x_call_trans.x_call_trans2user
 AND table_dealer.objid = table_x_call_trans.x_call_trans2dealer
 AND table_x_carrier.objid = table_x_call_trans.x_call_trans2carrier
 AND table_site.objid = table_site_part.site_part2site
 AND table_site_part.objid = table_x_call_trans.call_trans2site_part
 AND table_x_carrier_group.objid = table_x_carrier.carrier2carrier_group
 AND table_part_num.objid = table_mod_level.part_info2part_num
 AND  table_x_code_table.x_code_number = table_x_call_trans.x_action_type;
COMMENT ON TABLE sa.table_x_redemp_hist IS 'x_call_trans related site,user,x_carrier, x_redcard, selected by site_part';
COMMENT ON COLUMN sa.table_x_redemp_hist.contact_objid IS 'related contact';
COMMENT ON COLUMN sa.table_x_redemp_hist.contact_x_cust_id IS 'Unique customer number (populated from site_id for customers)';
COMMENT ON COLUMN sa.table_x_redemp_hist.contact_role_objid IS 'MTM relate between contact and site';
COMMENT ON COLUMN sa.table_x_redemp_hist.site_objid IS 'Site objid';
COMMENT ON COLUMN sa.table_x_redemp_hist.site_part_objid IS 'related site_part';
COMMENT ON COLUMN sa.table_x_redemp_hist.reason IS 'deactivation reason code';
COMMENT ON COLUMN sa.table_x_redemp_hist.esn IS 'esn';
COMMENT ON COLUMN sa.table_x_redemp_hist.x_iccid IS 'iccid';
COMMENT ON COLUMN sa.table_x_redemp_hist.x_min IS 'min';
COMMENT ON COLUMN sa.table_x_redemp_hist.x_service_id IS 'Serial Number of the Phone for Wireless or Service Id for Wireline';
COMMENT ON COLUMN sa.table_x_redemp_hist.user_objid IS 'user table internal key';
COMMENT ON COLUMN sa.table_x_redemp_hist.agent IS 'x_call_trans internal record number';
COMMENT ON COLUMN sa.table_x_redemp_hist.dealer_objid IS 'site table internal key';
COMMENT ON COLUMN sa.table_x_redemp_hist.dealer IS 'site name is dealer for this transaction';
COMMENT ON COLUMN sa.table_x_redemp_hist.call_trans_objid IS 'x_call_trans table internal key';
COMMENT ON COLUMN sa.table_x_redemp_hist.date_time IS 'date when x_call_transaction occurred';
COMMENT ON COLUMN sa.table_x_redemp_hist.source_sys IS 'x_call_transaction - source that added this row';
COMMENT ON COLUMN sa.table_x_redemp_hist.action_type IS 'type of transaction';
COMMENT ON COLUMN sa.table_x_redemp_hist.carrier_objid IS 'x_carrier internal key';
COMMENT ON COLUMN sa.table_x_redemp_hist.carrier IS 'Name of the carrier for this transaction';
COMMENT ON COLUMN sa.table_x_redemp_hist.x_red_card_objid IS 'x_red_card table internal key';
COMMENT ON COLUMN sa.table_x_redemp_hist.smp IS 'SMP code for this redemption card transaction';
COMMENT ON COLUMN sa.table_x_redemp_hist.red_code IS 'Transaction Redemption Code';
COMMENT ON COLUMN sa.table_x_redemp_hist.units IS 'Units issued for redemption';
COMMENT ON COLUMN sa.table_x_redemp_hist.market IS 'Name of the carrier market for this transaction';
COMMENT ON COLUMN sa.table_x_redemp_hist.action_text IS 'Text of transaction action type';
COMMENT ON COLUMN sa.table_x_redemp_hist.total_units IS 'Total units redeemed in this transaction';
COMMENT ON COLUMN sa.table_x_redemp_hist.trans_reason IS 'Additiona reason for particular transaction action type';
COMMENT ON COLUMN sa.table_x_redemp_hist.result IS 'Result of call transaction, i.e. Completed or Failed';
COMMENT ON COLUMN sa.table_x_redemp_hist.x_technology IS 'technology of phone';