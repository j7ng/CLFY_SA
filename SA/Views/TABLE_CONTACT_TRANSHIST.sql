CREATE OR REPLACE FORCE VIEW sa.table_contact_transhist (contact_objid,contact_x_cust_id,contact_role_objid,site_objid,site_part_objid,reason,user_objid,agent,s_agent,dealer_objid,dealer,s_dealer,call_trans_objid,date_time,source_sys,action_type,carrier_objid,carrier,x_red_card_objid,smp,red_code,units) AS
select table_contact.objid, table_contact.x_cust_id,
 table_contact_role.objid, table_site.objid,
 table_site_part.objid, table_site_part.x_deact_reason,
 table_user.objid, table_user.login_name, table_user.S_login_name,
 table_dealer.objid, table_dealer.name, table_dealer.S_name,
 table_x_call_trans.objid, table_x_call_trans.x_transact_date,
 table_x_call_trans.x_sourcesystem, table_x_call_trans.x_action_type,
 table_x_carrier.objid, table_x_carrier_group.x_carrier_name,
 table_x_red_card.objid, table_x_red_card.x_smp,
 table_x_red_card.x_red_code, table_x_red_card.x_red_units
 from table_site table_dealer, table_contact, table_contact_role, table_site,
  table_site_part, table_user, table_x_call_trans,
  table_x_carrier, table_x_carrier_group, table_x_red_card
 where table_x_carrier.objid = table_x_call_trans.x_call_trans2carrier
 AND table_dealer.objid = table_x_call_trans.x_call_trans2dealer
 AND table_site_part.objid = table_x_call_trans.call_trans2site_part
 AND table_user.objid = table_x_call_trans.x_call_trans2user
 AND table_site.objid = table_contact_role.contact_role2site
 AND table_contact.objid = table_contact_role.contact_role2contact
 AND table_x_call_trans.objid = table_x_red_card.red_card2call_trans (+)
 AND table_site.objid = table_site_part.site_part2site
 AND table_x_carrier_group.objid = table_x_carrier.carrier2carrier_group
 ;
COMMENT ON TABLE sa.table_contact_transhist IS 'x_call_trans related site,user,x_carrier, x_redcard, selected by site_part';
COMMENT ON COLUMN sa.table_contact_transhist.contact_objid IS 'related contact';
COMMENT ON COLUMN sa.table_contact_transhist.contact_x_cust_id IS 'Unique customer number (populated from site_id for customers)';
COMMENT ON COLUMN sa.table_contact_transhist.contact_role_objid IS 'MTM relate between contact and site';
COMMENT ON COLUMN sa.table_contact_transhist.site_objid IS 'Site objid';
COMMENT ON COLUMN sa.table_contact_transhist.site_part_objid IS 'related site_part';
COMMENT ON COLUMN sa.table_contact_transhist.reason IS 'deactivation reason code';
COMMENT ON COLUMN sa.table_contact_transhist.user_objid IS 'user table internal key';
COMMENT ON COLUMN sa.table_contact_transhist.agent IS 'x_call_trans internal record number';
COMMENT ON COLUMN sa.table_contact_transhist.dealer_objid IS 'site table internal key';
COMMENT ON COLUMN sa.table_contact_transhist.dealer IS 'site name is dealer for this transaction';
COMMENT ON COLUMN sa.table_contact_transhist.call_trans_objid IS 'x_call_trans table internal key';
COMMENT ON COLUMN sa.table_contact_transhist.date_time IS 'date when x_call_transaction occurred';
COMMENT ON COLUMN sa.table_contact_transhist.source_sys IS 'x_call_transaction - source that added this row';
COMMENT ON COLUMN sa.table_contact_transhist.action_type IS 'type of transaction';
COMMENT ON COLUMN sa.table_contact_transhist.carrier_objid IS 'x_carrier internal key';
COMMENT ON COLUMN sa.table_contact_transhist.carrier IS 'Name of the carrier for this transaction';
COMMENT ON COLUMN sa.table_contact_transhist.x_red_card_objid IS 'x_red_card table internal key';
COMMENT ON COLUMN sa.table_contact_transhist.smp IS 'SMP code for this redemption card transaction';
COMMENT ON COLUMN sa.table_contact_transhist.red_code IS 'Transaction Redemption Code';
COMMENT ON COLUMN sa.table_contact_transhist.units IS 'Units issued for redemption';