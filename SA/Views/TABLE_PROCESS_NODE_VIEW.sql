CREATE OR REPLACE FORCE VIEW sa.table_process_node_view (function_objid,seqno,func_group_objid,func_group_id,func_group_iter,func_group_iter_focus,process_objid,svc_rqst_objid,svc_rqst_id,svc_rqst_type,process_id,func_group_parent_objid,group_parent_type,group_parent_iter,"VERSION",func_type,func_flags,is_milestone,cond_expected,duration,func_group_iter_expected,func_group_type,use_elapsed) AS
select table_function.objid, table_function.seqno,
 NVL(table_func_group.objid,0), table_func_group.id,
 table_func_group.iter, table_func_group.iter_focus,
 NVL(table_process.objid,0), NVL(table_svc_rqst.objid,0),
 table_svc_rqst.id, table_svc_rqst.type,
 table_process.id, table_group_parent.objid,
 table_group_parent.type, table_group_parent.iter,
 table_process.version, table_function.func_type,
 table_function.flags, table_func_group.is_milestone,
 table_function.cond_expected, table_svc_rqst.duration,
 table_func_group.iter_expected, table_func_group.type,
 table_svc_rqst.use_elapsed
 from table_func_group table_group_parent, table_function, table_func_group, table_process,
  table_svc_rqst
 where table_group_parent.objid = table_function.belongs2func_group
 AND table_func_group.objid (+) = table_function.function2func_group
 AND table_svc_rqst.objid (+) = table_function.function2svc_rqst
 AND table_process.objid (+) = table_function.function2process
;