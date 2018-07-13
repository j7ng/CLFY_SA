CREATE OR REPLACE FORCE VIEW sa.table_sit_prt_view (objid,location_id,site_id,location_name,bin_id,part_num_id,part_number,s_part_number,part_name_id,part_descr,s_part_descr,part_good_qty,part_bad_qty,part_serial_no,bin_name,mod_level,s_mod_level,locdesc,last_trans_time,part_status,inv_class,trans_auth,role_name,"RANK",hdr_ind) AS
select table_part_inst.objid, table_inv_locatn.objid,
 table_inv_role.inv_role2site, table_inv_locatn.location_name,
 table_inv_bin.objid, table_mod_level.objid,
 table_part_num.part_number, table_part_num.S_part_number, table_part_num.objid,
 table_part_num.description, table_part_num.S_description, table_part_inst.part_good_qty,
 table_part_inst.part_bad_qty, table_part_inst.part_serial_no,
 table_inv_bin.bin_name, table_mod_level.mod_level, table_mod_level.S_mod_level,
 table_inv_locatn.location_descr, table_part_inst.last_trans_time,
 table_part_inst.part_status, table_inv_locatn.inv_class,
 table_inv_locatn.trans_auth, table_inv_role.role_name,
 table_inv_role.rank, table_part_inst.hdr_ind
 from table_part_inst, table_inv_locatn, table_inv_role,
  table_inv_bin, table_mod_level, table_part_num
 where table_inv_bin.objid = table_part_inst.part_inst2inv_bin
 AND table_mod_level.objid = table_part_inst.n_part_inst2part_mod
 AND table_inv_role.inv_role2site IS NOT NULL
 AND table_inv_locatn.objid = table_inv_bin.inv_bin2inv_locatn
 AND table_part_num.objid = table_mod_level.part_info2part_num
 AND table_inv_locatn.objid = table_inv_role.inv_role2inv_locatn
 ;
COMMENT ON TABLE sa.table_sit_prt_view IS 'View of inventory part information used by form Picked Parts (552)';
COMMENT ON COLUMN sa.table_sit_prt_view.objid IS 'Inventory part internal record number';
COMMENT ON COLUMN sa.table_sit_prt_view.location_id IS 'Inventory location internal record number';
COMMENT ON COLUMN sa.table_sit_prt_view.site_id IS 'Site internal record number';
COMMENT ON COLUMN sa.table_sit_prt_view.location_name IS 'For physical inventory locations, the name of the location. For GL accounts, the account number';
COMMENT ON COLUMN sa.table_sit_prt_view.bin_id IS 'Inventory bin internal record number';
COMMENT ON COLUMN sa.table_sit_prt_view.part_num_id IS 'Part revision internal record number';
COMMENT ON COLUMN sa.table_sit_prt_view.part_number IS 'Part number/name';
COMMENT ON COLUMN sa.table_sit_prt_view.part_name_id IS 'Part internal record number';
COMMENT ON COLUMN sa.table_sit_prt_view.part_descr IS 'Description of the product';
COMMENT ON COLUMN sa.table_sit_prt_view.part_good_qty IS 'For parts tracked by quantity, the quantity usable';
COMMENT ON COLUMN sa.table_sit_prt_view.part_bad_qty IS 'For parts tracked by quantity, the quantity not usable';
COMMENT ON COLUMN sa.table_sit_prt_view.part_serial_no IS 'For parts tracked by serial number, the inventory installed part serial number';
COMMENT ON COLUMN sa.table_sit_prt_view.bin_name IS 'Unique name of the inventory bin within an inventory location';
COMMENT ON COLUMN sa.table_sit_prt_view.mod_level IS 'Part revison of the inventory part';
COMMENT ON COLUMN sa.table_sit_prt_view.locdesc IS 'Description of the inventory location or GL account';
COMMENT ON COLUMN sa.table_sit_prt_view.last_trans_time IS 'Date and time of the last transaction against the part instance';
COMMENT ON COLUMN sa.table_sit_prt_view.part_status IS 'Status of the inventory part';
COMMENT ON COLUMN sa.table_sit_prt_view.inv_class IS 'Inventory location class; i.e.,   0=inventory location, 1=capital GL account, 2=expense GL account';
COMMENT ON COLUMN sa.table_sit_prt_view.trans_auth IS 'States the type of transactions authorized for the inventory location; i.e., 0=all, 1=none, 2=Authorized Parts only. An authorized part is one for which there is a part_auth object';
COMMENT ON COLUMN sa.table_sit_prt_view.role_name IS 'Name of role played by the focus type; e.g., sites default-bad parts inventory location, inventory locations located-at site';
COMMENT ON COLUMN sa.table_sit_prt_view."RANK" IS 'For servicing inventory locations, ranks the order in which locations should be displayed for a given site in the Pick form; e.g., 0=not applicable, 1=first displayed, 2=second displayed, etc., default=0';
COMMENT ON COLUMN sa.table_sit_prt_view.hdr_ind IS 'Whether the part instance is a header which tracks a group of serialized part instances; 0=serial tracked part instance, 1=serial tracked header instance, 2=quantity tracked part instance, 3=empty header instance, default=0';