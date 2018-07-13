CREATE OR REPLACE FORCE VIEW sa.table_win_cobj_v (objid,win_objid,win_id,win_name,win_desp,win_label,cobj_name,cobj_type,cobj_index,win_base) AS
select table_ctx_obj_db.objid, table_window_db.objid,
 table_window_db.id, table_window_db.title,
 table_window_db.description, table_window_db.dialog_name,
 table_ctx_obj_db.title, table_ctx_obj_db.type,
 table_ctx_obj_db.idx, table_window_db.base_flag
 from table_ctx_obj_db, table_window_db
 where table_window_db.objid = table_ctx_obj_db.ctx_obj2window_db
 ;
COMMENT ON TABLE sa.table_win_cobj_v IS 'Displays form information from ctx_obj_db. Used by forms Generic LookUP non-modal (20000)and Advanced Filters (20001)';
COMMENT ON COLUMN sa.table_win_cobj_v.objid IS 'Ctx_obj_db internal record number';
COMMENT ON COLUMN sa.table_win_cobj_v.win_objid IS 'Window_db internal record number';
COMMENT ON COLUMN sa.table_win_cobj_v.win_id IS 'Form ID number';
COMMENT ON COLUMN sa.table_win_cobj_v.win_name IS 'Title of the form';
COMMENT ON COLUMN sa.table_win_cobj_v.win_desp IS 'Description of the form';
COMMENT ON COLUMN sa.table_win_cobj_v.win_label IS 'Name of the form';
COMMENT ON COLUMN sa.table_win_cobj_v.cobj_name IS 'Title of the contextual object';
COMMENT ON COLUMN sa.table_win_cobj_v.cobj_type IS 'Schema type number of the corresponding database object; e.g., 0=Case. Same as object number';
COMMENT ON COLUMN sa.table_win_cobj_v.cobj_index IS 'Sequence number of the contextual object within its form';
COMMENT ON COLUMN sa.table_win_cobj_v.win_base IS 'Indicates whether form is a base line form; i.e., B=baseline';