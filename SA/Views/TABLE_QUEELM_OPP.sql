CREATE OR REPLACE FORCE VIEW sa.table_queelm_opp (que_objid,elm_objid,clarify_state,"ID",s_id,age,"CONDITION",s_condition,status,s_status,"NAME",s_name,update_stamp) AS
select table_opportunity.opp_currq2queue, table_opportunity.objid,
 table_condition.condition, table_opportunity.id, table_opportunity.S_id,
 table_condition.queue_time, table_condition.title, table_condition.S_title,
 table_gbst_elm.title, table_gbst_elm.S_title, table_opportunity.name, table_opportunity.S_name,
 table_opportunity.update_stamp
 from table_opportunity, table_condition, table_gbst_elm
 where table_opportunity.opp_currq2queue IS NOT NULL
 AND table_gbst_elm.objid = table_opportunity.opp_sts2gbst_elm
 AND table_condition.objid = table_opportunity.opp_state2condition
 ;
COMMENT ON TABLE sa.table_queelm_opp IS 'View opportunity information for Queue';
COMMENT ON COLUMN sa.table_queelm_opp.que_objid IS 'Queue internal record number';
COMMENT ON COLUMN sa.table_queelm_opp.elm_objid IS 'Contract internal record number';
COMMENT ON COLUMN sa.table_queelm_opp.clarify_state IS 'Opportunity condition';
COMMENT ON COLUMN sa.table_queelm_opp."ID" IS 'Opportunity ID number';
COMMENT ON COLUMN sa.table_queelm_opp.age IS 'Age of opportunity in seconds';
COMMENT ON COLUMN sa.table_queelm_opp."CONDITION" IS 'Condition of opportunity';
COMMENT ON COLUMN sa.table_queelm_opp.status IS 'Status of opportunity';
COMMENT ON COLUMN sa.table_queelm_opp."NAME" IS 'Opportunity name';
COMMENT ON COLUMN sa.table_queelm_opp.update_stamp IS 'Date/time of last update to the opportunity';