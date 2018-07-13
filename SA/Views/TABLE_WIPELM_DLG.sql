CREATE OR REPLACE FORCE VIEW sa.table_wipelm_dlg (wip_objid,elm_objid,clarify_state,"ID",age,"CONDITION",s_condition,status,s_status,title,s_title,"PRIORITY",s_priority) AS
select table_dialogue.dialogue_wip2wipbin, table_dialogue.objid,
 table_condition.condition, table_dialogue.id_number,
 table_condition.wipbin_time, table_condition.title, table_condition.S_title,
 table_gse_status.title, table_gse_status.S_title, table_dialogue.title, table_dialogue.S_title,
 table_gse_priority.title, table_gse_priority.S_title
 from table_gbst_elm table_gse_priority, table_gbst_elm table_gse_status, table_dialogue, table_condition
 where table_dialogue.dialogue_wip2wipbin IS NOT NULL
 AND table_gse_priority.objid = table_dialogue.dialogue_pty2gbst_elm
 AND table_condition.objid = table_dialogue.dialogue2condition
 AND table_gse_status.objid = table_dialogue.dialogue_sts2gbst_elm
 ;
COMMENT ON TABLE sa.table_wipelm_dlg IS 'View dialogue information for WIPbin form (375)';
COMMENT ON COLUMN sa.table_wipelm_dlg.wip_objid IS 'WIPbin internal record number';
COMMENT ON COLUMN sa.table_wipelm_dlg.elm_objid IS 'Dialogue internal record number';
COMMENT ON COLUMN sa.table_wipelm_dlg.clarify_state IS 'Dialogue condition';
COMMENT ON COLUMN sa.table_wipelm_dlg."ID" IS 'Unique ID number of the Dialogue';
COMMENT ON COLUMN sa.table_wipelm_dlg.age IS 'Dialogue age in seconds';
COMMENT ON COLUMN sa.table_wipelm_dlg."CONDITION" IS 'Dialogue condition title';
COMMENT ON COLUMN sa.table_wipelm_dlg.status IS 'Dialogue status';
COMMENT ON COLUMN sa.table_wipelm_dlg.title IS 'Title of the dialogue';
COMMENT ON COLUMN sa.table_wipelm_dlg."PRIORITY" IS 'Dialogue priority';