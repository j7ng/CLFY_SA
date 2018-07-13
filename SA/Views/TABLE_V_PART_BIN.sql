CREATE OR REPLACE FORCE VIEW sa.table_v_part_bin (objid,part_num_id,mod_id,bin_id,inv_locatn_id,part_number,s_part_number,part_descr,s_part_descr,part_good_qty,part_bad_qty,part_serial_no,bin_name,last_trans_time,part_status) AS
select table_part_inst.objid, table_part_num.objid,
 table_mod_level.objid, table_inv_bin.objid,
 table_inv_bin.inv_bin2inv_locatn, table_part_num.part_number, table_part_num.S_part_number,
 table_part_num.description, table_part_num.S_description, table_part_inst.part_good_qty,
 table_part_inst.part_bad_qty, table_part_inst.part_serial_no,
 table_inv_bin.bin_name, table_part_inst.last_trans_time,
 table_part_inst.part_status
 from table_part_inst, table_part_num, table_mod_level,
  table_inv_bin
 where table_part_num.objid = table_mod_level.part_info2part_num
 AND table_inv_bin.inv_bin2inv_locatn IS NOT NULL
 AND table_inv_bin.objid = table_part_inst.part_inst2inv_bin
 AND table_mod_level.objid = table_part_inst.n_part_inst2part_mod
 ;
COMMENT ON TABLE sa.table_v_part_bin IS 'View of inventory part/bin information used by form Picked Parts (552)';
COMMENT ON COLUMN sa.table_v_part_bin.objid IS 'Inventory part internal record number';
COMMENT ON COLUMN sa.table_v_part_bin.part_num_id IS 'Part_num internal record number';
COMMENT ON COLUMN sa.table_v_part_bin.mod_id IS 'Part revision internal record number';
COMMENT ON COLUMN sa.table_v_part_bin.bin_id IS 'Inventory bin internal record number';
COMMENT ON COLUMN sa.table_v_part_bin.inv_locatn_id IS 'Inventory location internal record number';
COMMENT ON COLUMN sa.table_v_part_bin.part_number IS 'Part number/name';
COMMENT ON COLUMN sa.table_v_part_bin.part_descr IS 'Description of the product';
COMMENT ON COLUMN sa.table_v_part_bin.part_good_qty IS 'For parts tracked by quantity, the quantity usable';
COMMENT ON COLUMN sa.table_v_part_bin.part_bad_qty IS 'For parts tracked by quantity, the quantity not usable';
COMMENT ON COLUMN sa.table_v_part_bin.part_serial_no IS 'For parts tracked by serial number, the inventory installed part serial number';
COMMENT ON COLUMN sa.table_v_part_bin.bin_name IS 'Unique name of the inventory bin within an inventory location';
COMMENT ON COLUMN sa.table_v_part_bin.last_trans_time IS 'Date and time of the last transaction against the part instance';
COMMENT ON COLUMN sa.table_v_part_bin.part_status IS 'Status of the inventory part';