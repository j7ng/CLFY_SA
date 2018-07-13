CREATE OR REPLACE FORCE VIEW sa.table_queelm_fnl (que_objid,elm_objid,clarify_state,id_number,age,"CONDITION",s_condition,title,s_title) AS
select table_probdesc.probdesc_q2queue, table_probdesc.objid,
 table_condition.condition, table_probdesc.id_number,
 table_condition.queue_time, table_condition.title, table_condition.S_title,
 table_probdesc.title, table_probdesc.S_title
 from table_probdesc, table_condition
 where table_condition.objid = table_probdesc.probdesc2condition
 AND table_probdesc.probdesc_q2queue IS NOT NULL
 ;
COMMENT ON TABLE sa.table_queelm_fnl IS 'Selects solution information for Queue display';
COMMENT ON COLUMN sa.table_queelm_fnl.que_objid IS 'Queue object ID number';
COMMENT ON COLUMN sa.table_queelm_fnl.elm_objid IS 'Solution object ID number';
COMMENT ON COLUMN sa.table_queelm_fnl.clarify_state IS 'Solution condition';
COMMENT ON COLUMN sa.table_queelm_fnl.id_number IS 'Solution ID number';
COMMENT ON COLUMN sa.table_queelm_fnl.age IS 'Age of task in queue in seconds';
COMMENT ON COLUMN sa.table_queelm_fnl."CONDITION" IS 'Condition of solution';
COMMENT ON COLUMN sa.table_queelm_fnl.title IS 'Title of solution';