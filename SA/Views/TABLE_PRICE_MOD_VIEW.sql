CREATE OR REPLACE FORCE VIEW sa.table_price_mod_view (part_mod,part_num,price_inst,price_prog,"NAME",s_name,price,description,"TYPE",display,eff_date,exp_date,prog_eff_date,prog_exp_date) AS
select table_mod_level.objid, table_part_num.objid,
 table_price_inst.objid, table_price_prog.objid,
 table_price_prog.name, table_price_prog.S_name, table_price_inst.price,
 table_price_prog.description, table_price_prog.type,
 table_price_prog.display, table_price_inst.effective_date,
 table_price_inst.expire_date, table_price_prog.effective_date,
 table_price_prog.expire_date
 from table_mod_level, table_part_num, table_price_inst,
  table_price_prog
 where table_part_num.objid = table_price_inst.price_inst2part_num
 AND table_part_num.objid = table_mod_level.part_info2part_num
 AND table_price_prog.objid = table_price_inst.price_inst2price_prog
 ;