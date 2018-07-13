CREATE OR REPLACE FORCE VIEW sa.table_wipelm_opp (wip_objid,elm_objid,clarify_state,"ID",s_id,age,"CONDITION",s_condition,status,s_status,"NAME",s_name,update_stamp) AS
select table_opportunity.opp_wip2wipbin, table_opportunity.objid,
 table_condition.condition, table_opportunity.id, table_opportunity.S_id,
 table_condition.wipbin_time, table_condition.title, table_condition.S_title,
 table_gbst_elm.title, table_gbst_elm.S_title, table_opportunity.name, table_opportunity.S_name,
 table_opportunity.update_stamp
 from table_opportunity, table_condition, table_gbst_elm
 where table_opportunity.opp_wip2wipbin IS NOT NULL
 AND table_gbst_elm.objid = table_opportunity.opp_sts2gbst_elm
 AND table_condition.objid = table_opportunity.opp_state2condition
 ;
COMMENT ON TABLE sa.table_wipelm_opp IS 'View opportunity information for WIPbin';
COMMENT ON COLUMN sa.table_wipelm_opp.wip_objid IS 'WIPbin internal record number';
COMMENT ON COLUMN sa.table_wipelm_opp.elm_objid IS 'Opportunity internal record number';
COMMENT ON COLUMN sa.table_wipelm_opp.clarify_state IS 'Opportunity state';
COMMENT ON COLUMN sa.table_wipelm_opp."ID" IS 'Unique ID number of the opportunity';
COMMENT ON COLUMN sa.table_wipelm_opp.age IS 'Opportunity age';
COMMENT ON COLUMN sa.table_wipelm_opp."CONDITION" IS 'Opportunity condition';
COMMENT ON COLUMN sa.table_wipelm_opp.status IS 'Opportunity status';
COMMENT ON COLUMN sa.table_wipelm_opp."NAME" IS 'Opportunity name';
COMMENT ON COLUMN sa.table_wipelm_opp.update_stamp IS 'Date/time of last update to the opportunity';