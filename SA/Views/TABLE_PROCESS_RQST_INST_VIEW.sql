CREATE OR REPLACE FORCE VIEW sa.table_process_rqst_inst_view (rqst_inst_objid,svc_rqst_objid,svc_fld_objid,busy,error_status,err_code,err_info,err_mess,err_type,focus_lowid,focus_object,focus_type,resume_focus_lowid,resume_focus_type,status,svc_type,cb_exesub,duration,"ID",svc_name,attrib_name,fml_attrib_type,db_attrib_type,is_flexible,filter_list,fld_name,focus,focus_alpha,"PATH",sqlfrom,sqlwhere,target_id,target_name,"TYPE",type_alpha,sub_service,sub_field,retry_interval,max_retries,retry_count,proc_inst_objid,start_time) AS
select table_rqst_inst.objid, table_svc_rqst.objid,
 NVL(table_svc_fld.objid,0), table_rqst_inst.busy,
 table_rqst_inst.error_status, table_rqst_inst.err_code,
 table_rqst_inst.err_info, table_rqst_inst.err_mess,
 table_rqst_inst.err_type, table_rqst_inst.focus_lowid,
 table_rqst_inst.focus_object, table_rqst_inst.focus_type,
 table_rqst_inst.resume_focus_lowid, table_rqst_inst.resume_focus_type,
 table_rqst_inst.status, table_svc_rqst.type,
 table_svc_rqst.cb_exesub, table_svc_rqst.duration,
 table_svc_rqst.id, table_svc_rqst.svc_name,
 table_svc_fld.attrib_name, table_svc_fld.fml_attrib_type,
 table_svc_fld.db_attrib_type, table_svc_fld.is_flexible,
 table_svc_fld.object_cond, table_svc_fld.fld_name,
 table_svc_fld.focus, table_svc_fld.focus_alpha,
 table_svc_fld.path, table_svc_fld.object_sqlfrom,
 table_svc_fld.object_sqlwhere, table_svc_fld.object_target_id,
 table_svc_fld.target_name, table_svc_fld.type,
 table_svc_fld.type_alpha, table_svc_rqst.sub_service,
 table_svc_rqst.sub_field, table_svc_rqst.retry_interval,
 table_svc_rqst.max_retries, table_rqst_inst.retry_count,
 table_rqst_inst.rqst_inst2proc_inst, table_rqst_inst.start_time
 from table_rqst_inst, table_svc_rqst, table_svc_fld
 where table_svc_rqst.objid = table_rqst_inst.rqst_inst2svc_rqst
 AND table_svc_rqst.objid = table_svc_fld.fld2svc_rqst (+)
 AND table_rqst_inst.rqst_inst2proc_inst IS NOT NULL
;