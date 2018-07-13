CREATE OR REPLACE FORCE VIEW sa.table_process_error_view (func_objid,group_inst_objid,func_group_objid,group_func_objid,parent_group_inst_objid,focus_lowid,child_func_type,group_func_type) AS
select table_function.objid, table_group_inst.objid,
 table_func_group.objid, NVL(table_group_function.objid,0),
 NVL(table_group_inst.child2group_inst,0), table_group_inst.focus_lowid,
 NVL(table_function.func_type,0), NVL(table_group_function.func_type,0)
 from table_function table_group_function, table_function, table_group_inst, table_func_group
 where table_func_group.objid = table_function.belongs2func_group (+)
 AND table_func_group.objid = table_group_inst.group2func_group
 AND table_group_inst.child2group_inst IS NOT NULL
 AND table_group_function.objid (+) = table_group_inst.group2function
;