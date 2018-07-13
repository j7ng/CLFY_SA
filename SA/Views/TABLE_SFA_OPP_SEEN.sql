CREATE OR REPLACE FORCE VIEW sa.table_sfa_opp_seen (objid,user_objid) AS
select table_opportunity.objid, table_user.objid
 from mtm_user97_opportunity38, table_opportunity, table_user
 where table_user.objid = mtm_user97_opportunity38.viewer2opportunity
 AND mtm_user97_opportunity38.opp_viewer2user = table_opportunity.objid 
 ;
COMMENT ON TABLE sa.table_sfa_opp_seen IS 'Returns opportunities already viewed by a user';
COMMENT ON COLUMN sa.table_sfa_opp_seen.objid IS 'Opportunity internal record number';
COMMENT ON COLUMN sa.table_sfa_opp_seen.user_objid IS 'User internal record number';