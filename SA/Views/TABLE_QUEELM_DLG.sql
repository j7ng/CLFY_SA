CREATE OR REPLACE FORCE VIEW sa.table_queelm_dlg (que_objid,elm_objid,clarify_state,"ID",age,"CONDITION",s_condition,status,s_status,title,s_title,"PRIORITY",s_priority) AS
select table_dialogue.dialogue_currq2queue, table_dialogue.objid,
 table_condition.condition, table_dialogue.id_number,
 table_condition.queue_time, table_condition.title, table_condition.S_title,
 table_gse_status.title, table_gse_status.S_title, table_dialogue.title, table_dialogue.S_title,
 table_gse_priority.title, table_gse_priority.S_title
 from table_gbst_elm table_gse_priority, table_gbst_elm table_gse_status, table_dialogue, table_condition
 where table_dialogue.dialogue_currq2queue IS NOT NULL
 AND table_gse_priority.objid = table_dialogue.dialogue_pty2gbst_elm
 AND table_condition.objid = table_dialogue.dialogue2condition
 AND table_gse_status.objid = table_dialogue.dialogue_sts2gbst_elm
 ;
COMMENT ON TABLE sa.table_queelm_dlg IS 'View dialogue information for Queue form (728)';
COMMENT ON COLUMN sa.table_queelm_dlg.que_objid IS 'Queue object ID number';
COMMENT ON COLUMN sa.table_queelm_dlg.elm_objid IS 'Dialogue object ID number';
COMMENT ON COLUMN sa.table_queelm_dlg.clarify_state IS 'Dialogue condition';
COMMENT ON COLUMN sa.table_queelm_dlg."ID" IS 'Dialogue ID number';
COMMENT ON COLUMN sa.table_queelm_dlg.age IS 'Age of dialogue in seconds';
COMMENT ON COLUMN sa.table_queelm_dlg."CONDITION" IS 'Condition of dialogue';
COMMENT ON COLUMN sa.table_queelm_dlg.status IS 'Status of dialogue';
COMMENT ON COLUMN sa.table_queelm_dlg.title IS 'Title of dialogue';
COMMENT ON COLUMN sa.table_queelm_dlg."PRIORITY" IS 'Priority of dialogue';