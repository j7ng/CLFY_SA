CREATE OR REPLACE FORCE VIEW sa.table_sfa_pipeline (objid,currency_objid,owner_objid,owner_name,s_owner_name,stage,opp_cls_amt,opp_cls_dt,opp_name,s_opp_name,opp_cls_prb,opp_id,s_opp_id,currency_name,s_currency_name,sub_scale,lst_objid,lst_elm_objid) AS
select table_opportunity.objid, table_currency.objid,
 table_user.objid, table_user.login_name, table_user.S_login_name,
 table_gbst_lst.title, table_opportunity.frcst_cls_amount,
 table_opportunity.frcst_cls_dt, table_opportunity.name, table_opportunity.S_name,
 table_opportunity.frcst_cls_prb, table_opportunity.id, table_opportunity.S_id,
 table_currency.name, table_currency.S_name, table_currency.sub_scale,
 table_gbst_lst.objid, table_gbst_elm.objid
 from table_opportunity, table_currency, table_user,
  table_gbst_lst, table_gbst_elm
 where table_gbst_lst.objid = table_gbst_elm.gbst_elm2gbst_lst
 AND table_gbst_elm.objid = table_opportunity.opp_sts2gbst_elm
 AND table_user.objid = table_opportunity.opp_owner2user
 AND table_currency.objid = table_opportunity.opp2currency
 ;
COMMENT ON TABLE sa.table_sfa_pipeline IS 'Displays Opportunity financials. Used by form ___';
COMMENT ON COLUMN sa.table_sfa_pipeline.objid IS 'Opportunity internal record number';
COMMENT ON COLUMN sa.table_sfa_pipeline.currency_objid IS 'Currency internal record number';
COMMENT ON COLUMN sa.table_sfa_pipeline.owner_objid IS 'User internal record number';
COMMENT ON COLUMN sa.table_sfa_pipeline.owner_name IS 'User login name';
COMMENT ON COLUMN sa.table_sfa_pipeline.stage IS 'Status/Stage of opportunity';
COMMENT ON COLUMN sa.table_sfa_pipeline.opp_cls_amt IS 'Forecasted close amount of the opportunity';
COMMENT ON COLUMN sa.table_sfa_pipeline.opp_cls_dt IS 'Forecasted close date of the opportunity';
COMMENT ON COLUMN sa.table_sfa_pipeline.opp_name IS 'Name given to the opportunity';
COMMENT ON COLUMN sa.table_sfa_pipeline.opp_cls_prb IS 'Forcasted close probability of the opportunity';
COMMENT ON COLUMN sa.table_sfa_pipeline.opp_id IS 'Opportunity ID number';
COMMENT ON COLUMN sa.table_sfa_pipeline.currency_name IS 'Name of the currency the opportunity is denominated in';
COMMENT ON COLUMN sa.table_sfa_pipeline.sub_scale IS 'Gives the decimal scale of the sub unit in which the currency will be calculated: e.g., US dollar has a sub unit (cent) whose scale=2; Italian lira has no sub unit, its sub unit scale=0';
COMMENT ON COLUMN sa.table_sfa_pipeline.lst_objid IS 'Status/Stage gbst_lst internal record number';
COMMENT ON COLUMN sa.table_sfa_pipeline.lst_elm_objid IS 'Status/Stage gbst_elm internal record number';