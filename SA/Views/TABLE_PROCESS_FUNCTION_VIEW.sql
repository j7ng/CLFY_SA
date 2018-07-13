CREATE OR REPLACE FORCE VIEW sa.table_process_function_view (function_objid,func_group_objid,process_objid,svc_rqst_objid,func_group_parent_objid,seqno,focus_object,flags,func_group_id,func_group_type,func_group_iter,func_group_cond_path,func_group_cond_focus,func_group_iter_path,func_group_iter_rev_path,func_group_iter_target_name,func_group_iter_focus,func_group_iter_sqlwhere,func_group_iter_sqlfrom,svc_rqst_id,svc_rqst_type,svc_rqst_duration,process_id,s_process_id,process_version,process_status,group_parent_type,group_parent_iter) AS
select table_function.objid, NVL(table_func_group.objid,0),
 NVL(table_process.objid,0), NVL(table_svc_rqst.objid,0),
 table_group_parent.objid, table_function.seqno,
 table_function.focus_object, table_function.flags,
 table_func_group.id, table_func_group.type,
 table_func_group.iter, table_func_group.cond_path,
 table_func_group.cond_focus, table_func_group.iter_path,
 table_func_group.iter_rev_path, table_func_group.iter_target_name,
 table_func_group.iter_focus, table_func_group.iter_sqlwhere,
 table_func_group.iter_sqlfrom, table_svc_rqst.id,
 table_svc_rqst.type, table_svc_rqst.duration, table_process.id, table_process.S_id,
 table_process.version, table_process.status,
 table_group_parent.type, table_group_parent.iter
 from table_func_group table_group_parent, table_function, table_func_group, table_process,
  table_svc_rqst
 where table_svc_rqst.objid (+) = table_function.function2svc_rqst
 AND table_process.objid (+) = table_function.function2process
 AND table_group_parent.objid = table_function.belongs2func_group
 AND table_func_group.objid (+) = table_function.function2func_group
;