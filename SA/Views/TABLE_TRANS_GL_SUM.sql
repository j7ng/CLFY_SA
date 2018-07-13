CREATE OR REPLACE FORCE VIEW sa.table_trans_gl_sum (objid,part_mod_objid,to_location,fr_location,trans_date,ref_number,trans_id,part_number,s_part_number,part_num_desc,s_part_num_desc,qty,std_cost,serial_no,mod_level,s_mod_level,notes,to_gl_acct,from_gl_acct,fr_bin_objid,to_bin_objid,part_objid,movement_type,to_inst_objid,fr_inst_objid) AS
select table_part_trans.objid, table_mod_level.objid,
 table_to_bin.location_name, table_from_bin.location_name,
 table_part_trans.creation_date, table_part_trans.reference_no,
 table_part_trans.transaction_id, table_part_num.part_number, table_part_num.S_part_number,
 table_part_num.description, table_part_num.S_description, table_part_trans.quantity,
 table_part_trans.standard_cost, table_from_inst.part_serial_no,
 table_mod_level.mod_level, table_mod_level.S_mod_level, table_part_trans.notes,
 table_to_bin.gl_acct_no, table_from_bin.gl_acct_no,
 table_from_bin.objid, table_to_bin.objid,
 table_part_num.objid, table_part_trans.movement_type,
 table_part_trans.to_inst2part_inst, table_from_inst.objid
 from table_inv_bin table_from_bin, table_inv_bin table_to_bin, table_part_inst table_from_inst, table_part_trans, table_mod_level, table_part_num
 where table_from_inst.objid = table_part_trans.from_inst2part_inst
 AND table_part_num.objid = table_mod_level.part_info2part_num
 AND table_to_bin.objid = table_part_trans.to_fixed2inv_bin
 AND table_from_bin.objid = table_part_trans.from_fixed2inv_bin
 AND table_part_trans.to_inst2part_inst IS NOT NULL
 AND table_mod_level.objid = table_from_inst.n_part_inst2part_mod
 ;
COMMENT ON TABLE sa.table_trans_gl_sum IS 'GL transaction query. Used by Cycle Count Calculate Parmeters (8437)';
COMMENT ON COLUMN sa.table_trans_gl_sum.objid IS 'Part transaction internal record number';
COMMENT ON COLUMN sa.table_trans_gl_sum.part_mod_objid IS 'Part revision internal record number';
COMMENT ON COLUMN sa.table_trans_gl_sum.to_location IS 'The TO location for the parts';
COMMENT ON COLUMN sa.table_trans_gl_sum.fr_location IS 'The FROM location for the parts';
COMMENT ON COLUMN sa.table_trans_gl_sum.trans_date IS 'The date of transaction';
COMMENT ON COLUMN sa.table_trans_gl_sum.ref_number IS 'The reference number of transaction';
COMMENT ON COLUMN sa.table_trans_gl_sum.trans_id IS 'The ID number of transaction';
COMMENT ON COLUMN sa.table_trans_gl_sum.part_number IS 'Part number/name';
COMMENT ON COLUMN sa.table_trans_gl_sum.part_num_desc IS 'Maps to sales and mfg systems';
COMMENT ON COLUMN sa.table_trans_gl_sum.qty IS 'The quantity of transaction';
COMMENT ON COLUMN sa.table_trans_gl_sum.std_cost IS 'The cost of transaction';
COMMENT ON COLUMN sa.table_trans_gl_sum.serial_no IS 'The serial number transaction';
COMMENT ON COLUMN sa.table_trans_gl_sum.mod_level IS 'Part revision';
COMMENT ON COLUMN sa.table_trans_gl_sum.notes IS 'Notes for the transaction';
COMMENT ON COLUMN sa.table_trans_gl_sum.to_gl_acct IS 'The capital GL account of the TO inventory bin. This is the same as the GL account of its parent inventory location';
COMMENT ON COLUMN sa.table_trans_gl_sum.from_gl_acct IS 'The capital GL account of the FROM inventory bin. This is the same as the GL account of its parent inventory location';
COMMENT ON COLUMN sa.table_trans_gl_sum.fr_bin_objid IS 'Internal record number of the FROM inventory bin';
COMMENT ON COLUMN sa.table_trans_gl_sum.to_bin_objid IS 'Internal record number of the TO inventory bin';
COMMENT ON COLUMN sa.table_trans_gl_sum.part_objid IS 'Internal record number of the part number';
COMMENT ON COLUMN sa.table_trans_gl_sum.movement_type IS 'Movement type; i.e., 0=good to good, 1=good to bad, 2=bad to good, 3=bad to bad';
COMMENT ON COLUMN sa.table_trans_gl_sum.to_inst_objid IS 'The TO part_inst internal record number for this part transaction';
COMMENT ON COLUMN sa.table_trans_gl_sum.fr_inst_objid IS 'The FROM part_inst internal record number for this part transaction';