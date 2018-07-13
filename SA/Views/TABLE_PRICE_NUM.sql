CREATE OR REPLACE FORCE VIEW sa.table_price_num (part_num,objid,price_prog,"NAME",s_name,price,description,"TYPE",display,eff_date,exp_date,prog_eff_date,prog_exp_date,part_mod) AS
select table_mod_level.part_info2part_num, table_price_inst.objid,
 table_price_prog.objid, table_price_prog.name, table_price_prog.S_name,
 table_price_inst.price, table_price_prog.description,
 table_price_prog.type, table_price_prog.display,
 table_price_inst.effective_date, table_price_inst.expire_date,
 table_price_prog.effective_date, table_price_prog.expire_date,
 table_mod_level.objid
 from table_mod_level, table_price_inst, table_price_prog,
  table_price_qty
 where table_mod_level.objid = table_price_qty.priced_part2mod_level
 AND table_price_qty.objid = table_price_inst.price_inst2price_qty
 AND table_mod_level.part_info2part_num IS NOT NULL
 AND table_price_prog.objid = table_price_inst.price_inst2price_prog
 ;
COMMENT ON TABLE sa.table_price_num IS 'Used to price at revision level by form RMA Request Details (502), More RMA Info (503), Part Request Detail (507), More (Part Request) Info (508), Repair Info (509) and Pricing (511)';
COMMENT ON COLUMN sa.table_price_num.part_num IS 'Part number internal record number';
COMMENT ON COLUMN sa.table_price_num.objid IS 'Price instance internal record number';
COMMENT ON COLUMN sa.table_price_num.price_prog IS 'Price program internal record number';
COMMENT ON COLUMN sa.table_price_num."NAME" IS 'Name of the price program';
COMMENT ON COLUMN sa.table_price_num.price IS 'Price the price instance';
COMMENT ON COLUMN sa.table_price_num.description IS 'Description from the price program';
COMMENT ON COLUMN sa.table_price_num."TYPE" IS 'Type of the price program';
COMMENT ON COLUMN sa.table_price_num.display IS 'If true, display pricing program in list box on parts look-up form';
COMMENT ON COLUMN sa.table_price_num.eff_date IS 'Effective date from the price instance';
COMMENT ON COLUMN sa.table_price_num.exp_date IS 'Expiration date from thhe price instance';
COMMENT ON COLUMN sa.table_price_num.prog_eff_date IS 'Effective date from the price program';
COMMENT ON COLUMN sa.table_price_num.prog_exp_date IS 'Expiration date from the price program';
COMMENT ON COLUMN sa.table_price_num.part_mod IS 'Mod_level internal record number';