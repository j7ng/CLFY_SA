CREATE OR REPLACE FORCE VIEW sa.table_select_dialog (elm_objid,id_number,title,s_title,"CONDITION",s_condition,status,s_status,"PRIORITY",s_priority,creation_time,"OWNER",s_owner,cond_objid,status_objid,priority_objid,owner_objid) AS
select table_dialogue.objid, table_dialogue.id_number,
 table_dialogue.title, table_dialogue.S_title, table_condition.title, table_condition.S_title,
 table_gse_status.title, table_gse_status.S_title, table_gse_priority.title, table_gse_priority.S_title,
 table_dialogue.creation_time, table_user.login_name, table_user.S_login_name,
 table_condition.objid, table_gse_status.objid,
 table_gse_priority.objid, table_user.objid
 from table_gbst_elm table_gse_priority, table_gbst_elm table_gse_status, table_dialogue, table_condition, table_user
 where table_condition.objid = table_dialogue.dialogue2condition
 AND table_gse_status.objid = table_dialogue.dialogue_sts2gbst_elm
 AND table_gse_priority.objid = table_dialogue.dialogue_pty2gbst_elm
 AND table_user.objid = table_dialogue.dialogue_owner2user
 ;
COMMENT ON TABLE sa.table_select_dialog IS 'Presents Dialogue details for specific dialogue selection. Used by form Select Dialogue (15000)';
COMMENT ON COLUMN sa.table_select_dialog.elm_objid IS 'Dialogue internal record number';
COMMENT ON COLUMN sa.table_select_dialog.id_number IS 'Dialogue object ID Number';
COMMENT ON COLUMN sa.table_select_dialog.title IS 'Dialogue title';
COMMENT ON COLUMN sa.table_select_dialog."CONDITION" IS 'Dialogue condition';
COMMENT ON COLUMN sa.table_select_dialog.status IS 'Dialogue status';
COMMENT ON COLUMN sa.table_select_dialog."PRIORITY" IS 'Dialogue priority';
COMMENT ON COLUMN sa.table_select_dialog.creation_time IS 'Date and time dialogue was created';
COMMENT ON COLUMN sa.table_select_dialog."OWNER" IS 'User login name';
COMMENT ON COLUMN sa.table_select_dialog.cond_objid IS 'Condition internal record number';
COMMENT ON COLUMN sa.table_select_dialog.status_objid IS 'Status gbst_elm internal record number';
COMMENT ON COLUMN sa.table_select_dialog.priority_objid IS 'Priority gbst_elm internal record number';
COMMENT ON COLUMN sa.table_select_dialog.owner_objid IS 'User internal record number';