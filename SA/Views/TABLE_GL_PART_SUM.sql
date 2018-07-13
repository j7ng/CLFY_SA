CREATE OR REPLACE FORCE VIEW sa.table_gl_part_sum (objid,trans_date,qty,unit_price,to_gl,to_gl_objid,from_gl,from_gl_objid,to_bin,to_bin_objid,from_bin,from_bin_objid,trans_id) AS
select table_part_trans.objid, table_part_trans.creation_date,
 table_part_trans.quantity, table_part_trans.standard_cost,
 table_to_fixed.gl_acct_no, table_to_fixed.objid,
 table_from_fixed.gl_acct_no, table_from_fixed.objid,
 table_to_bin.bin_name, table_to_bin.objid,
 table_from_bin.bin_name, table_from_bin.objid,
 table_part_trans.transaction_id
 from table_inv_bin table_from_bin, table_inv_bin table_from_fixed, table_inv_bin table_to_bin, table_inv_bin table_to_fixed, table_part_trans
 where table_from_bin.objid = table_part_trans.from_bin2inv_bin
 AND table_from_fixed.objid = table_part_trans.from_fixed2inv_bin
 AND table_to_fixed.objid = table_part_trans.to_fixed2inv_bin
 AND table_to_bin.objid = table_part_trans.to_bin2inv_bin
 ;
COMMENT ON TABLE sa.table_gl_part_sum IS 'Used by the server process in cbbatch for GL summary computations';
COMMENT ON COLUMN sa.table_gl_part_sum.objid IS 'Part transaction internal record number';
COMMENT ON COLUMN sa.table_gl_part_sum.trans_date IS 'The date of transaction';
COMMENT ON COLUMN sa.table_gl_part_sum.qty IS 'The quantity of this transaction';
COMMENT ON COLUMN sa.table_gl_part_sum.unit_price IS 'The price per unit';
COMMENT ON COLUMN sa.table_gl_part_sum.to_gl IS 'The TO GL account name';
COMMENT ON COLUMN sa.table_gl_part_sum.to_gl_objid IS 'The TO GL account object ID';
COMMENT ON COLUMN sa.table_gl_part_sum.from_gl IS 'The FROM GL account';
COMMENT ON COLUMN sa.table_gl_part_sum.from_gl_objid IS 'The FROM GL account object ID';
COMMENT ON COLUMN sa.table_gl_part_sum.to_bin IS 'The TO bin name';
COMMENT ON COLUMN sa.table_gl_part_sum.to_bin_objid IS 'The TO bin object ID';
COMMENT ON COLUMN sa.table_gl_part_sum.from_bin IS 'The FROM bin name';
COMMENT ON COLUMN sa.table_gl_part_sum.from_bin_objid IS 'The FROM bin object ID';
COMMENT ON COLUMN sa.table_gl_part_sum.trans_id IS 'Transaction ID of this part transaction';