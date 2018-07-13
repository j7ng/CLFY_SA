CREATE OR REPLACE FORCE VIEW sa.table_sfa_opp_wk_v (objid,wip_objid,queue_objid,cond_objid,sts_objid,owner_objid,opp_name,s_opp_name,opp_id,s_opp_id,wip_name,s_wip_name,queue_name,s_queue_name,"CONDITION",s_condition,status,s_status,owner_name,s_owner_name) AS
select table_opportunity.objid, table_wipbin.objid,
 table_queue.objid, table_condition.objid,
 table_gbst_elm.objid, table_user.objid,
 table_opportunity.name, table_opportunity.S_name, table_opportunity.id, table_opportunity.S_id,
 table_wipbin.title, table_wipbin.S_title, table_queue.title, table_queue.S_title,
 table_condition.title, table_condition.S_title, table_gbst_elm.title, table_gbst_elm.S_title,
 table_user.login_name, table_user.S_login_name
 from table_opportunity, table_wipbin, table_queue,
  table_condition, table_gbst_elm, table_user
 where table_user.objid = table_opportunity.opp_owner2user
 AND table_queue.objid (+) = table_opportunity.opp_currq2queue
 AND table_wipbin.objid (+) = table_opportunity.opp_wip2wipbin
 AND table_condition.objid = table_opportunity.opp_state2condition
 AND table_gbst_elm.objid = table_opportunity.opp_sts2gbst_elm
 ;
COMMENT ON TABLE sa.table_sfa_opp_wk_v IS 'Displays opportunity workflow information. Used by Used by Account Mgr (11650), Console-Sales (12000), and Opportunity Mgr (13000)';
COMMENT ON COLUMN sa.table_sfa_opp_wk_v.objid IS 'Opportunity internal record number';
COMMENT ON COLUMN sa.table_sfa_opp_wk_v.wip_objid IS 'WIPBin internal record number';
COMMENT ON COLUMN sa.table_sfa_opp_wk_v.queue_objid IS 'Queue internal record number';
COMMENT ON COLUMN sa.table_sfa_opp_wk_v.cond_objid IS 'Condition internal record number';
COMMENT ON COLUMN sa.table_sfa_opp_wk_v.sts_objid IS 'Gbst_elm internal record number';
COMMENT ON COLUMN sa.table_sfa_opp_wk_v.owner_objid IS 'User internal record number';
COMMENT ON COLUMN sa.table_sfa_opp_wk_v.opp_name IS 'Name of the opportunity';
COMMENT ON COLUMN sa.table_sfa_opp_wk_v.opp_id IS 'ID of the opportunity';
COMMENT ON COLUMN sa.table_sfa_opp_wk_v.wip_name IS 'Name of the wipbin';
COMMENT ON COLUMN sa.table_sfa_opp_wk_v.queue_name IS 'Name of the queue';
COMMENT ON COLUMN sa.table_sfa_opp_wk_v."CONDITION" IS 'Name of the opportunity s condition';
COMMENT ON COLUMN sa.table_sfa_opp_wk_v.status IS 'Satus of the opportunity';
COMMENT ON COLUMN sa.table_sfa_opp_wk_v.owner_name IS 'Name of the opportunity owner';