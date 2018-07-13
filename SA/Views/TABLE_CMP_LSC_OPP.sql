CREATE OR REPLACE FORCE VIEW sa.table_cmp_lsc_opp (opp_objid,cmp_objid,lsc_objid,login_name,s_login_name,stage,frcst_cls_amt,frcst_cls_dt,"NAME",s_name,frcst_cls_prb) AS
select table_opportunity.objid, table_lead_source.source2campaign,
 table_lead_source.objid, table_user.login_name, table_user.S_login_name,
 table_gbst_lst.title, table_opportunity.frcst_cls_amount,
 table_opportunity.frcst_cls_dt, table_opportunity.name, table_opportunity.S_name,
 table_opportunity.frcst_cls_prb
 from table_opportunity, table_lead_source, table_user,
  table_gbst_lst, table_gbst_elm
 where table_lead_source.source2campaign IS NOT NULL
 AND table_user.objid = table_opportunity.opp_owner2user
 AND table_gbst_lst.objid = table_gbst_elm.gbst_elm2gbst_lst
 AND table_lead_source.objid = table_opportunity.opp2lead_source
 AND table_gbst_elm.objid = table_opportunity.opp_sts2gbst_elm
 ;
COMMENT ON TABLE sa.table_cmp_lsc_opp IS 'Used by forms Source (S) Detail (9511), S Description (9512), Campaign (C) Detail (9521), (C) Description (9522), (C) Lead Source (9523), (C) Contact Import (9526), Campaign (11950) and others';
COMMENT ON COLUMN sa.table_cmp_lsc_opp.opp_objid IS 'opportunity object internal record number';
COMMENT ON COLUMN sa.table_cmp_lsc_opp.cmp_objid IS 'campaign object internal record number';
COMMENT ON COLUMN sa.table_cmp_lsc_opp.lsc_objid IS 'lead_source object internal record number';
COMMENT ON COLUMN sa.table_cmp_lsc_opp.login_name IS 'User login name';
COMMENT ON COLUMN sa.table_cmp_lsc_opp.stage IS 'Status/Stage of opportunity';
COMMENT ON COLUMN sa.table_cmp_lsc_opp.frcst_cls_amt IS 'Forecasted close amount of the opportunity';
COMMENT ON COLUMN sa.table_cmp_lsc_opp.frcst_cls_dt IS 'Forecasted close amount of the opportunity';
COMMENT ON COLUMN sa.table_cmp_lsc_opp."NAME" IS 'Name given to the opportunity';
COMMENT ON COLUMN sa.table_cmp_lsc_opp.frcst_cls_prb IS 'Forcasted close probability of the opportunity';