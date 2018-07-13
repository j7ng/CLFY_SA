CREATE OR REPLACE FORCE VIEW sa.table_parts_view (objid,location_id,location_name,bin_id,part_num_id,part_number,s_part_number,part_name_id,part_descr,s_part_descr,part_good_qty,part_bad_qty,part_serial_no,bin_name,mod_level,s_mod_level,locdesc,good_res_qty,bad_res_qty,inv_class,pick_request,last_trans_time,part_status,trans_auth,sn_track,hdr_ind,fixed_bin_name,container_id,opened_ind,"ACTIVE") AS
select table_part_inst.objid, table_inv_locatn.objid,
 table_inv_locatn.location_name, table_inv_bin.objid,
 table_mod_level.objid, table_part_num.part_number, table_part_num.S_part_number,
 table_part_num.objid, table_part_num.description, table_part_num.S_description,
 table_part_inst.part_good_qty, table_part_inst.part_bad_qty,
 table_part_inst.part_serial_no, table_inv_bin.bin_name,
 table_mod_level.mod_level, table_mod_level.S_mod_level, table_inv_locatn.location_descr,
 table_part_inst.good_res_qty, table_part_inst.bad_res_qty,
 table_inv_locatn.inv_class, table_part_inst.pick_request,
 table_part_inst.last_trans_time, table_part_inst.part_status,
 table_inv_locatn.trans_auth, table_part_num.sn_track,
 table_part_inst.hdr_ind, table_inv_bin.fixed_bin_name,
 table_inv_bin.id_number, table_inv_bin.opened_ind,
 table_inv_bin.active
 from table_part_inst, table_inv_locatn, table_inv_bin,
  table_mod_level, table_part_num
 where table_inv_bin.objid = table_part_inst.part_inst2inv_bin
 AND table_part_num.objid = table_mod_level.part_info2part_num
 AND table_inv_locatn.objid = table_inv_bin.inv_bin2inv_locatn
 AND table_mod_level.objid = table_part_inst.n_part_inst2part_mod
 ;
COMMENT ON TABLE sa.table_parts_view IS 'Part information used by form Picked Parts (552), Inventory Parts Search (555)';
COMMENT ON COLUMN sa.table_parts_view.objid IS 'Part internal record number';
COMMENT ON COLUMN sa.table_parts_view.location_id IS 'Inventory location  internal record number';
COMMENT ON COLUMN sa.table_parts_view.location_name IS 'For physical inventory locations, the name of the location. For GL accounts, the account number';
COMMENT ON COLUMN sa.table_parts_view.bin_id IS 'Inventory bin internal record number';
COMMENT ON COLUMN sa.table_parts_view.part_num_id IS 'Part revision internal record number';
COMMENT ON COLUMN sa.table_parts_view.part_number IS 'Part number/name';
COMMENT ON COLUMN sa.table_parts_view.part_name_id IS 'Part number internal record number';
COMMENT ON COLUMN sa.table_parts_view.part_descr IS 'Maps to sales and mfg systems';
COMMENT ON COLUMN sa.table_parts_view.part_good_qty IS 'For parts tracked by quantity, the quantity usable';
COMMENT ON COLUMN sa.table_parts_view.part_bad_qty IS 'For parts tracked by quantity, the quantity not usable';
COMMENT ON COLUMN sa.table_parts_view.part_serial_no IS 'For parts tracked by serial number, the part serial number';
COMMENT ON COLUMN sa.table_parts_view.bin_name IS 'Unique name of the inventory bin within an inventory location';
COMMENT ON COLUMN sa.table_parts_view.mod_level IS 'Name of part revision';
COMMENT ON COLUMN sa.table_parts_view.locdesc IS 'Description of the inventory location or GL account';
COMMENT ON COLUMN sa.table_parts_view.good_res_qty IS 'For parts tracked by quantity, the good quantity reserved';
COMMENT ON COLUMN sa.table_parts_view.bad_res_qty IS 'For parts tracked by quantity, the bad quantity reserved';
COMMENT ON COLUMN sa.table_parts_view.inv_class IS 'Part location; i.e.,   0=inventory location, 1=capital GL account, 2=expense GL account';
COMMENT ON COLUMN sa.table_parts_view.pick_request IS 'The part request number for the request that has currently picked the part';
COMMENT ON COLUMN sa.table_parts_view.last_trans_time IS 'Date and time of the last transaction against the part';
COMMENT ON COLUMN sa.table_parts_view.part_status IS 'Status of the part';
COMMENT ON COLUMN sa.table_parts_view.trans_auth IS 'States the type of transactions authorized for the inventory location; i.e., 0=All, 1=None, 2=Authorized Parts only. An authorized part is one for which there is a part_auth object';
COMMENT ON COLUMN sa.table_parts_view.sn_track IS 'Track part for serialization; i.e., 0=by quantity, 1=by serial number';
COMMENT ON COLUMN sa.table_parts_view.hdr_ind IS 'Whether the part instance is a header which tracks a group of serial numbered part instances; i.e., 0=not a header instance, 1=is a header instance, default=0';
COMMENT ON COLUMN sa.table_parts_view.fixed_bin_name IS 'For containers, the name of the fixed bin within which the container resides, for fixed bins this field is blank, default=';
COMMENT ON COLUMN sa.table_parts_view.container_id IS 'For containers, the ID of the container, for fixed bins this field is blank, default=';
COMMENT ON COLUMN sa.table_parts_view.opened_ind IS 'Indicates whether the bin allows parts to be moved in/out or not; i.e, 0=no, it s sealed, 1=yes it is opened, default=1';
COMMENT ON COLUMN sa.table_parts_view."ACTIVE" IS 'Indicates whether the bin is in use; i.e., 0=inactive, 1=active, default=1';