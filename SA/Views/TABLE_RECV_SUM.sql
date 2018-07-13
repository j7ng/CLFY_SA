CREATE OR REPLACE FORCE VIEW sa.table_recv_sum (objid,trans_date,ref_number,qty,to_location,fr_location,to_bin,from_bin,part_number,serial_no,receipt_type,title,mod_level,s_mod_level,dtl_objid,hdr_objid,part_num_desc,s_part_num_desc,detail_number,recv_serial_no) AS
select table_recv_parts.objid, table_part_trans.creation_date,
 table_part_trans.reference_no, table_part_trans.quantity,
 table_to_loc.location_name, table_from_loc.location_name,
 table_to_bin.bin_name, table_from_bin.bin_name,
 table_part_trans.part_number, table_demand_dtl.serial_no,
 table_recv_parts.receipt_type, table_demand_dtl.title,
 table_mod_level.mod_level, table_mod_level.S_mod_level, table_demand_dtl.objid,
 table_demand_dtl.demand_dtl2demand_hdr, table_part_num.description, table_part_num.S_description,
 table_demand_dtl.detail_number, table_part_inst.part_serial_no
 from table_inv_bin table_from_bin, table_inv_bin table_to_bin, table_inv_locatn table_from_loc, table_inv_locatn table_to_loc, table_recv_parts, table_part_trans, table_demand_dtl,
  table_mod_level, table_part_num, table_part_inst
 where table_to_loc.objid = table_to_bin.inv_bin2inv_locatn
 AND table_part_inst.objid = table_part_trans.from_inst2part_inst
 AND table_part_num.objid = table_mod_level.part_info2part_num
 AND table_to_bin.objid = table_part_trans.to_bin2inv_bin
 AND table_demand_dtl.objid = table_part_trans.part_trans2demand_dtl
 AND table_from_bin.objid = table_part_trans.from_bin2inv_bin
 AND table_recv_parts.objid = table_part_trans.recv_trans2recv_parts
 AND table_from_loc.objid = table_from_bin.inv_bin2inv_locatn
 AND table_mod_level.objid = table_part_inst.n_part_inst2part_mod
 AND table_demand_dtl.demand_dtl2demand_hdr IS NOT NULL
 ;
COMMENT ON TABLE sa.table_recv_sum IS 'Queries in the query group. Used by form Receipts Query List (590)';
COMMENT ON COLUMN sa.table_recv_sum.objid IS 'Recv_parts internal record number';
COMMENT ON COLUMN sa.table_recv_sum.trans_date IS 'The date of transaction';
COMMENT ON COLUMN sa.table_recv_sum.ref_number IS 'The reference number of transaction';
COMMENT ON COLUMN sa.table_recv_sum.qty IS 'The quantity of transaction';
COMMENT ON COLUMN sa.table_recv_sum.to_location IS 'The TO location for the parts';
COMMENT ON COLUMN sa.table_recv_sum.fr_location IS 'The FROM location for the parts';
COMMENT ON COLUMN sa.table_recv_sum.to_bin IS 'The To inventory bin name';
COMMENT ON COLUMN sa.table_recv_sum.from_bin IS 'The From inventory bin name';
COMMENT ON COLUMN sa.table_recv_sum.part_number IS 'The part number';
COMMENT ON COLUMN sa.table_recv_sum.serial_no IS 'The serial number of the requested part';
COMMENT ON COLUMN sa.table_recv_sum.receipt_type IS 'The receipt type of the transaction';
COMMENT ON COLUMN sa.table_recv_sum.title IS 'Part request title';
COMMENT ON COLUMN sa.table_recv_sum.mod_level IS 'The revision of the part';
COMMENT ON COLUMN sa.table_recv_sum.dtl_objid IS 'Unique object ID number of parent object';
COMMENT ON COLUMN sa.table_recv_sum.hdr_objid IS 'Demand hdr internal record number';
COMMENT ON COLUMN sa.table_recv_sum.part_num_desc IS 'Maps to sales and mfg systems';
COMMENT ON COLUMN sa.table_recv_sum.detail_number IS 'The part request number for the request';
COMMENT ON COLUMN sa.table_recv_sum.recv_serial_no IS 'The serial number of the received part';