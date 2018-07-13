CREATE OR REPLACE FORCE VIEW sa.table_prtins_view (objid,location_id,location_name,bin_id,part_num_id,part_number,s_part_number,part_name_id,part_descr,s_part_descr,part_good_qty,part_bad_qty,part_serial_no,bin_name,mod_level,s_mod_level) AS
select table_part_inst.objid, table_inv_locatn.objid,
 table_inv_locatn.location_name, table_inv_bin.objid,
 table_mod_level.objid, table_part_num.part_number, table_part_num.S_part_number,
 table_part_num.objid, table_part_num.description, table_part_num.S_description,
 table_part_inst.part_good_qty, table_part_inst.part_bad_qty,
 table_part_inst.part_serial_no, table_inv_bin.bin_name,
 table_mod_level.mod_level, table_mod_level.S_mod_level
 from table_part_inst, table_inv_locatn, table_inv_bin,
  table_mod_level, table_part_num
 where table_mod_level.objid = table_part_inst.n_part_inst2part_mod
 AND table_inv_locatn.objid = table_inv_bin.inv_bin2inv_locatn
 AND table_part_num.objid = table_mod_level.part_info2part_num
 AND table_inv_bin.objid = table_part_inst.part_inst2inv_bin
 ;
COMMENT ON TABLE sa.table_prtins_view IS 'Installed part s location, bin, rev level, and part number';
COMMENT ON COLUMN sa.table_prtins_view.objid IS 'Part internal record number';
COMMENT ON COLUMN sa.table_prtins_view.location_id IS 'Inventory location internal record number';
COMMENT ON COLUMN sa.table_prtins_view.location_name IS 'For physical inventory locations, the name of the location. For GL accounts, the account number';
COMMENT ON COLUMN sa.table_prtins_view.bin_id IS 'Inventory bin internal record number';
COMMENT ON COLUMN sa.table_prtins_view.part_num_id IS 'Part revision internal record number';
COMMENT ON COLUMN sa.table_prtins_view.part_number IS 'Part number/name';
COMMENT ON COLUMN sa.table_prtins_view.part_name_id IS 'Part internal record number';
COMMENT ON COLUMN sa.table_prtins_view.part_descr IS 'Product description';
COMMENT ON COLUMN sa.table_prtins_view.part_good_qty IS 'For parts tracked by quantity, the quantity usable';
COMMENT ON COLUMN sa.table_prtins_view.part_bad_qty IS 'For parts tracked by quantity, the quantity  not usable';
COMMENT ON COLUMN sa.table_prtins_view.part_serial_no IS 'For parts tracked by serial number, the part serial number';
COMMENT ON COLUMN sa.table_prtins_view.bin_name IS 'Inventory bin name';
COMMENT ON COLUMN sa.table_prtins_view.mod_level IS 'Part revision name';