CREATE OR REPLACE FORCE VIEW sa.table_sub_preview (objid,id_number,title,s_title,description,required_date,elapsed_time,warning_time,"ACTIVE",sub_type,status,s_status,"PRIORITY",s_priority,severity,s_severity,login_name,s_login_name,user_objid,mandatory_ind) AS
select table_subcase.objid, table_subcase.id_number,
 table_subcase.title, table_subcase.S_title, table_subcase.description,
 table_subcase.required_date, table_subcase.elapsed_time,
 table_subcase.warning_time, table_subcase.dist,
 table_subcase.sub_type, table_gbst_stat.title, table_gbst_stat.S_title,
 table_gbst_pri.title, table_gbst_pri.S_title, table_gbst_svri.title, table_gbst_svri.S_title,
 table_user.login_name, table_user.S_login_name, table_user.objid,
 table_cls_factory.mandatory_ind
 from table_gbst_elm table_gbst_pri, table_gbst_elm table_gbst_stat, table_gbst_elm table_gbst_svri, table_subcase, table_user, table_cls_factory
 where table_gbst_stat.objid = table_subcase.subc_casests2gbst_elm
 AND table_cls_factory.objid = table_subcase.subc_gen2cls_factory
 AND table_user.objid = table_subcase.subc_owner2user
 AND table_gbst_pri.objid = table_subcase.subc_priorty2gbst_elm
 AND table_gbst_svri.objid = table_subcase.subc_svrity2gbst_elm
 ;
COMMENT ON TABLE sa.table_sub_preview IS 'Used to display subcase info, owner info, and gbst_elm data for preview and modify in Subcase Preview and Modify form (8240)';
COMMENT ON COLUMN sa.table_sub_preview.objid IS 'Subcase internal record number';
COMMENT ON COLUMN sa.table_sub_preview.id_number IS 'Subcase ID';
COMMENT ON COLUMN sa.table_sub_preview.title IS 'Title of the subcase';
COMMENT ON COLUMN sa.table_sub_preview.description IS 'Notes about the task';
COMMENT ON COLUMN sa.table_sub_preview.required_date IS 'Required date of the subcase';
COMMENT ON COLUMN sa.table_sub_preview.elapsed_time IS 'Elapsed time of the subcase';
COMMENT ON COLUMN sa.table_sub_preview.warning_time IS 'Date and time of commitment warning of the subcase';
COMMENT ON COLUMN sa.table_sub_preview."ACTIVE" IS 'If the subcase is active';
COMMENT ON COLUMN sa.table_sub_preview.sub_type IS 'Subcase type';
COMMENT ON COLUMN sa.table_sub_preview.status IS 'Status of the subcase';
COMMENT ON COLUMN sa.table_sub_preview."PRIORITY" IS 'Priority of the subcase';
COMMENT ON COLUMN sa.table_sub_preview.severity IS 'Severity of the subcase';
COMMENT ON COLUMN sa.table_sub_preview.login_name IS 'Login name of the user';
COMMENT ON COLUMN sa.table_sub_preview.user_objid IS 'User-owner internal record number';
COMMENT ON COLUMN sa.table_sub_preview.mandatory_ind IS 'Indicates whether the task when previewed for a process instance, must be generated; 0=not mandatory, 1=mandatory, default=0';