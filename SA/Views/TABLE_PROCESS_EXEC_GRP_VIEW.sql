CREATE OR REPLACE FORCE VIEW sa.table_process_exec_grp_view (func_objid,group_inst_objid,func_group_objid,focus_lowid,group_seqno,group_status,group_iter_seqno,group_no_functions,group_cond_val,focus_type,error_status,group_status_code,group_start_time,group_end_time,focus_object,group_iter_instance_count,resume_focus_type,resume_focus_lowid,err_code,err_mess,err_type,err_info,func_group_type,func_group_iter_type,"PATH",rev_path,target_name,target_id,attrib_name,filter_list,sqlfrom,sqlwhere,attrib_type,is_flexible,focus,cond_path,cond_rev_path,cond_target_name,cond_target_id,cond_attrib_name,cond_filter_list,cond_sqlfrom,cond_sqlwhere,cond_attrib_type,cond_is_flexible,cond_focus,func_seqno,func_cond_type,func_val_type,func_value,func_cond_operator,func_type) AS
select NVL(table_function.objid,0), table_group_inst.objid,
 table_func_group.objid, table_group_inst.focus_lowid,
 table_group_inst.seqno, table_group_inst.status,
 table_group_inst.iter_seqno, table_group_inst.no_functions,
 table_group_inst.cond_val, table_group_inst.focus_type,
 table_group_inst.error_status, table_group_inst.status_code,
 table_group_inst.start_time, table_group_inst.end_time,
 table_group_inst.focus_object, table_group_inst.iter_instance_count,
 table_group_inst.resume_focus_type, table_group_inst.resume_focus_lowid,
 table_group_inst.err_code, table_group_inst.err_mess,
 table_group_inst.err_type, table_group_inst.err_info,
 table_func_group.type, table_func_group.iter,
 table_function.value, table_function.val_rev_path,
 table_function.val_target_name, table_function.val_target_id,
 table_function.val_attrib_name,
 table_function.val_filter_list, table_function.val_sqlfrom,
 table_function.val_sqlwhere, table_function.val_attrib_type,
 table_function.val_is_flexible, table_function.val_focus,
 table_func_group.cond_path, table_func_group.cond_rev_path,
 table_func_group.cond_target_name, table_func_group.cond_target_id,
 table_func_group.cond_attrib_name,
 table_func_group.cond_filter_list, table_func_group.cond_sqlfrom,
 table_func_group.cond_sqlwhere, table_func_group.cond_attrib_type,
 table_func_group.cond_is_flexible, table_func_group.cond_focus,
 table_function.seqno, table_function.cond_type,
 table_function.val_type, table_function.value,
 table_function.cond_operator, table_function.func_type
 from table_function, table_group_inst, table_func_group
 where table_func_group.objid = table_function.belongs2func_group (+)
 AND table_func_group.objid = table_group_inst.group2func_group
;