CREATE OR REPLACE FORCE VIEW sa.table_c_pct_price (parent_mod_level_objid,price_qty_objid,ref_price_qty_objid,price_inst_objid,ref_price_inst_objid,ref_price_price,ref_price_eff,ref_price_exp,price_prog_objid,ref_child_mod_level_objid) AS
select table_con_price_qty.context_part2mod_level, table_con_price_qty.objid,
 table_ref_price_qty.objid, table_con_price_inst.objid,
 table_ref_price_inst.objid, table_ref_price_inst.price,
 table_ref_price_inst.effective_date, table_ref_price_inst.expire_date,
 table_ref_price_inst.price_inst2price_prog, table_ref_price_qty.priced_part2mod_level
 from table_price_inst table_con_price_inst, table_price_inst table_ref_price_inst, table_price_qty table_con_price_qty, table_price_qty table_ref_price_qty
 where table_con_price_qty.context_part2mod_level IS NOT NULL
 AND table_con_price_qty.objid = table_con_price_inst.price_inst2price_qty
 AND table_ref_price_qty.objid = table_con_price_inst.ref_price2price_qty
 AND table_ref_price_qty.objid = table_ref_price_inst.price_inst2price_qty
 AND table_ref_price_inst.price_inst2price_prog IS NOT NULL
 AND table_ref_price_qty.priced_part2mod_level IS NOT NULL
 ;
COMMENT ON TABLE sa.table_c_pct_price IS 'Used in part pricing by form Select Generic (9148) Services (NOT USED)';
COMMENT ON COLUMN sa.table_c_pct_price.parent_mod_level_objid IS 'Mod level internal record number of parent part';
COMMENT ON COLUMN sa.table_c_pct_price.price_qty_objid IS 'Internal record number of the priced price_qty';
COMMENT ON COLUMN sa.table_c_pct_price.ref_price_qty_objid IS 'Internal record number of the reference price quantify';
COMMENT ON COLUMN sa.table_c_pct_price.price_inst_objid IS 'Internal record number of the percentage price object';
COMMENT ON COLUMN sa.table_c_pct_price.ref_price_inst_objid IS 'Internal record number of the reference price used for percentage pricing';
COMMENT ON COLUMN sa.table_c_pct_price.ref_price_price IS 'The reference price used in calculating the percentage price';
COMMENT ON COLUMN sa.table_c_pct_price.ref_price_eff IS 'The reference price effective date';
COMMENT ON COLUMN sa.table_c_pct_price.ref_price_exp IS 'The reference price expire date';
COMMENT ON COLUMN sa.table_c_pct_price.price_prog_objid IS 'Price program internal record number';
COMMENT ON COLUMN sa.table_c_pct_price.ref_child_mod_level_objid IS 'Internal record number';