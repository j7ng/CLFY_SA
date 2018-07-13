CREATE OR REPLACE FORCE VIEW sa.table_opp_view (opp_objid,"ID",s_id,owner_objid,stage,s_stage,"NAME",s_name,frcst_cls_dt,purch_date,frcst_cls_amt,login_name,s_login_name,frcst_cls_prb,"CONDITION",s_condition) AS
select table_opportunity.objid, table_opportunity.id, table_opportunity.S_id,
 table_user.objid, table_cycle_stage.name, table_cycle_stage.S_name,
 table_opportunity.name, table_opportunity.S_name, table_opportunity.frcst_cls_dt,
 table_opportunity.purch_date, table_opportunity.frcst_cls_amount,
 table_user.login_name, table_user.S_login_name, table_opportunity.frcst_cls_prb,
 table_condition.title, table_condition.S_title
 from table_opportunity, table_user, table_cycle_stage,
  table_condition
 where table_condition.objid = table_opportunity.opp_state2condition
 AND table_user.objid = table_opportunity.opp_owner2user
 AND table_cycle_stage.objid = table_opportunity.opp2cycle_stage
 ;
COMMENT ON TABLE sa.table_opp_view IS 'Used by forms Incoming Call (9580) the Select Opportunity (9600), Contact (11401), Preview Tab (12001), Generic Lookup (20000), My Clarify (12000), Customer Interaction (11400)';
COMMENT ON COLUMN sa.table_opp_view.opp_objid IS 'Opportunity internal record number';
COMMENT ON COLUMN sa.table_opp_view."ID" IS 'Opportunity ID number';
COMMENT ON COLUMN sa.table_opp_view.owner_objid IS 'Internal record number of the opportunity owner';
COMMENT ON COLUMN sa.table_opp_view.stage IS 'Status/Stage of opportunity';
COMMENT ON COLUMN sa.table_opp_view."NAME" IS 'Name of the opportunity';
COMMENT ON COLUMN sa.table_opp_view.frcst_cls_dt IS 'Forecasted close date of the opportunity';
COMMENT ON COLUMN sa.table_opp_view.purch_date IS 'Purchase date from the opportunity';
COMMENT ON COLUMN sa.table_opp_view.frcst_cls_amt IS 'Forecasted close currency amount from the opportunity';
COMMENT ON COLUMN sa.table_opp_view.login_name IS 'User login name';
COMMENT ON COLUMN sa.table_opp_view.frcst_cls_prb IS 'Forecasted close probability from the opportunity';
COMMENT ON COLUMN sa.table_opp_view."CONDITION" IS 'Condition/state of the opportunity';