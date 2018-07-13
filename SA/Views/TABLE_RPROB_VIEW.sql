CREATE OR REPLACE FORCE VIEW sa.table_rprob_view (objid,problem_date,problem_id,part_number,s_part_number,problem_sn,problem_descr,problem_qty,is_closed,mod_level,s_mod_level) AS
select table_recv_prob.objid, table_recv_prob.problem_date,
 table_recv_prob.problem_id, table_part_num.part_number, table_part_num.S_part_number,
 table_recv_prob.problem_sn, table_recv_prob.problem_descr,
 table_recv_prob.problem_qty, table_recv_prob.is_closed,
 table_mod_level.mod_level, table_mod_level.S_mod_level
 from table_recv_prob, table_part_num, table_mod_level
 where table_mod_level.objid = table_recv_prob.problem2part_info
 AND table_part_num.objid = table_mod_level.part_info2part_num
 ;