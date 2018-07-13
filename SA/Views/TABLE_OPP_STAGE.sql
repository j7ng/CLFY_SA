CREATE OR REPLACE FORCE VIEW sa.table_opp_stage (opp_objid,owner_objid,stage,"NAME",s_name,frcst_cls_dt,purch_date,frcst_cls_amt,login_name,s_login_name,lsc_objid) AS
select table_opportunity.objid, table_user.objid,
 table_gbst_lst.title, table_opportunity.name, table_opportunity.S_name,
 table_opportunity.frcst_cls_dt, table_opportunity.purch_date,
 table_opportunity.frcst_cls_amount, table_user.login_name, table_user.S_login_name,
 table_opportunity.opp2lead_source
 from table_opportunity, table_user, table_gbst_lst,
  table_gbst_elm
 where table_gbst_lst.objid = table_gbst_elm.gbst_elm2gbst_lst
 AND table_opportunity.opp2lead_source IS NOT NULL
 AND table_gbst_elm.objid = table_opportunity.opp_sts2gbst_elm
 AND table_user.objid = table_opportunity.opp_owner2user
 ;
COMMENT ON TABLE sa.table_opp_stage IS 'Used to select all Opportunities for a given Lead Source';
COMMENT ON COLUMN sa.table_opp_stage.opp_objid IS 'opportunity object ID number';
COMMENT ON COLUMN sa.table_opp_stage.owner_objid IS 'lead_source object ID number';
COMMENT ON COLUMN sa.table_opp_stage.stage IS 'Status/Stage of opportunity';
COMMENT ON COLUMN sa.table_opp_stage."NAME" IS 'Name given to the opportunity';
COMMENT ON COLUMN sa.table_opp_stage.frcst_cls_dt IS 'Forecasted close date';
COMMENT ON COLUMN sa.table_opp_stage.purch_date IS 'When the opportunity is expected to close';
COMMENT ON COLUMN sa.table_opp_stage.frcst_cls_amt IS 'Forecasted close amount';
COMMENT ON COLUMN sa.table_opp_stage.login_name IS 'User login name';
COMMENT ON COLUMN sa.table_opp_stage.lsc_objid IS 'Internal record number';