CREATE OR REPLACE FORCE VIEW sa.table_process_funcgroup_view (group_inst_objid,func_group_objid,parent_group_inst_objid,iter_seqno,iter_instance_count) AS
select table_group_inst.objid, table_group_inst.group2func_group,
 NVL(table_group_inst.child2group_inst,0), table_group_inst.iter_seqno,
 table_group_inst.iter_instance_count
 from table_group_inst
 where table_group_inst.group2func_group IS NOT NULL
;