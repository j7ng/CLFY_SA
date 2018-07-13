CREATE OR REPLACE FORCE VIEW sa.table_c_price_srvc (part_num_objid,mod_level_objid,price_qty_objid,objid,price_prog_objid,part_number,s_part_number,part_desc,s_part_desc,part_domain,s_part_domain,unit_measure,p_standalone,p_as_parent,p_as_child,mod_level,s_mod_level,"ACTIVE",priced_qty,p_qty_type,fixed_amt,percentage,price,price_inst_eff_dt,price_inst_exp_dt,price_type,is_sppt_prog,price_prog_name,s_price_prog_name,price_prog_dspcc,child_mod_objid,prog_eff_dt,prog_exp_dt,currency_objid,model_num,s_model_num,price_type_str,sub_scale) AS
select table_part_num.objid, table_parent_mod_level.objid,
 table_price_qty.objid, table_price_inst.objid,
 table_price_prog.objid, table_part_num.part_number, table_part_num.S_part_number,
 table_part_num.description, table_part_num.S_description, table_part_num.domain, table_part_num.S_domain,
 table_part_num.unit_measure, table_part_num.p_standalone,
 table_part_num.p_as_parent, table_part_num.p_as_child,
 table_parent_mod_level.mod_level, table_parent_mod_level.S_mod_level, table_parent_mod_level.active,
 table_price_qty.priced_qty, table_price_qty.p_qty_type,
 table_price_inst.price, table_price_inst.price,
 table_price_inst.price, table_price_inst.effective_date,
 table_price_inst.expire_date, table_price_inst.price_type,
 table_part_num.is_sppt_prog, table_price_prog.name, table_price_prog.S_name,
 table_price_prog.displaycc, table_price_qty.priced_part2mod_level,
 table_price_prog.effective_date, table_price_prog.expire_date,
 table_currency.objid, table_part_num.model_num, table_part_num.S_model_num,
 table_price_inst.type_string, table_currency.sub_scale
 from table_mod_level table_parent_mod_level, table_part_num, table_price_qty, table_price_inst,
  table_price_prog, table_currency
 where table_price_prog.objid = table_price_inst.price_inst2price_prog
 AND table_part_num.objid = table_parent_mod_level.part_info2part_num
 AND table_price_qty.objid = table_price_inst.price_inst2price_qty
 AND table_price_qty.priced_part2mod_level IS NOT NULL
 AND table_parent_mod_level.objid = table_price_qty.context_part2mod_level
 AND table_currency.objid = table_price_prog.price_prog2currency
 ;