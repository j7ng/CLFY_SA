CREATE OR REPLACE FORCE VIEW sa.table_process_canc_grp_view (func_objid,group_inst_objid,func_group_objid,parent_group_inst_objid,focus_lowid,func_group_type,func_seqno,func_type,resume_focus_type,resume_focus_lowid,err_code,err_mess,err_type,err_info) AS
select table_function.objid, table_group_inst.objid,
 table_func_group.objid, NVL(table_group_inst.child2group_inst,0),
 table_group_inst.focus_lowid, table_func_group.type,
 table_function.seqno, table_function.func_type,
 table_group_inst.resume_focus_type, table_group_inst.resume_focus_lowid,
 table_group_inst.err_code, table_group_inst.err_mess,
 table_group_inst.err_type, table_group_inst.err_info
 from table_function, table_group_inst, table_func_group
 where table_func_group.objid = table_function.belongs2func_group
 AND table_func_group.objid = table_group_inst.group2func_group
;