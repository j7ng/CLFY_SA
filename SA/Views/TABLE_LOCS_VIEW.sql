CREATE OR REPLACE FORCE VIEW sa.table_locs_view (objid,location_id,location_name,bin_id,part_num_id,part_number,s_part_number,part_name_id,part_descr,s_part_descr,part_good_qty,part_bad_qty,part_serial_no,bin_name,mod_level,s_mod_level,locdesc,good_res_qty,bad_res_qty,inv_class,pick_request,mod_level_objid,inst_good_qty,inst_bad_qty,inst_objid) AS
select table_inv_locatn.objid, table_inv_locatn.objid,
 table_inv_locatn.location_name, table_inv_bin.objid,
 table_inv_locatn.objid, table_part_num.part_number, table_part_num.S_part_number,
 table_part_num.objid, table_part_num.description, table_part_num.S_description,
 table_inv_locatn.d_good_qty, table_inv_locatn.d_bad_qty,
 table_inv_locatn.loc_serv_level, table_inv_bin.bin_name,
 table_mod_level.mod_level, table_mod_level.S_mod_level, table_inv_locatn.location_descr,
 table_part_inst.good_res_qty, table_part_inst.bad_res_qty,
 table_inv_locatn.inv_class, table_part_inst.pick_request,
 table_mod_level.objid, table_part_inst.part_good_qty,
 table_part_inst.part_bad_qty, table_part_inst.objid
 from table_inv_locatn, table_inv_bin, table_part_num,
  table_mod_level, table_part_inst
 where table_inv_bin.objid = table_part_inst.part_inst2inv_bin
 AND table_part_num.objid = table_mod_level.part_info2part_num
 AND table_inv_locatn.objid = table_inv_bin.inv_bin2inv_locatn
 AND table_mod_level.objid = table_part_inst.n_part_inst2part_mod
 ;
COMMENT ON TABLE sa.table_locs_view IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_locs_view.objid IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_locs_view.location_id IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_locs_view.location_name IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_locs_view.bin_id IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_locs_view.part_num_id IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_locs_view.part_number IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_locs_view.part_name_id IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_locs_view.part_descr IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_locs_view.part_good_qty IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_locs_view.part_bad_qty IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_locs_view.part_serial_no IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_locs_view.bin_name IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_locs_view.mod_level IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_locs_view.locdesc IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_locs_view.good_res_qty IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_locs_view.bad_res_qty IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_locs_view.inv_class IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_locs_view.pick_request IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_locs_view.mod_level_objid IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_locs_view.inst_good_qty IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_locs_view.inst_bad_qty IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_locs_view.inst_objid IS 'Reserved; obsolete';