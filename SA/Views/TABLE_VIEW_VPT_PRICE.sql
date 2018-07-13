CREATE OR REPLACE FORCE VIEW sa.table_view_vpt_price (vend_part_obj,vendor_part_no,s_vendor_part_no,site_id,site_obj,site_name,s_site_name,mod_lev_obj,mod_level,s_mod_level,vendor_rev,s_vendor_rev,vendor_part_objid,role_name,warranty,avg_cost,price,effective_date,expire_date,prc_prog_name,s_prc_prog_name,qty,objid,prc_prog_obj,prc_qty_obj) AS
select table_vendor_part.objid, table_vendor_part.vendor_part_no, table_vendor_part.S_vendor_part_no,
 table_site.site_id, table_site.objid,
 table_site.name, table_site.S_name, table_mod_level.objid,
 table_mod_level.mod_level, table_mod_level.S_mod_level, table_vendor_part.vendor_rev, table_vendor_part.S_vendor_rev,
 table_vendor_part.objid, table_vendor_part.role_name,
 table_vendor_part.warranty, table_vendor_part.avg_cost,
 table_price_inst.price, table_price_inst.effective_date,
 table_price_inst.expire_date, table_price_prog.name, table_price_prog.S_name,
 table_price_qty.priced_qty, table_price_inst.objid,
 table_price_prog.objid, table_price_qty.objid
 from table_vendor_part, table_site, table_mod_level,
  table_price_inst, table_price_prog, table_price_qty
 where table_price_prog.objid = table_price_inst.price_inst2price_prog
 AND table_mod_level.objid = table_vendor_part.vendor_part2mod_level
 AND table_vendor_part.objid = table_price_qty.priced2vendor_part
 AND table_price_qty.objid = table_price_inst.price_inst2price_qty
 AND table_site.objid = table_vendor_part.vendor_part2site
 ;
COMMENT ON TABLE sa.table_view_vpt_price IS 'Reserved; future';
COMMENT ON COLUMN sa.table_view_vpt_price.vend_part_obj IS 'Part internal record number';
COMMENT ON COLUMN sa.table_view_vpt_price.vendor_part_no IS 'Vendor s part number';
COMMENT ON COLUMN sa.table_view_vpt_price.site_id IS 'Unique site number assigned according to auto-numbering definition';
COMMENT ON COLUMN sa.table_view_vpt_price.site_obj IS 'Site internal record number';
COMMENT ON COLUMN sa.table_view_vpt_price.site_name IS 'Site name';
COMMENT ON COLUMN sa.table_view_vpt_price.mod_lev_obj IS 'Internal record number';
COMMENT ON COLUMN sa.table_view_vpt_price.mod_level IS 'Part revision internal record number';
COMMENT ON COLUMN sa.table_view_vpt_price.vendor_rev IS 'Vendor site s part number revision level';
COMMENT ON COLUMN sa.table_view_vpt_price.vendor_part_objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_view_vpt_price.role_name IS 'Role played by the vendor for the part, e.g., supplier, repair vendor, exchange vendor etc';
COMMENT ON COLUMN sa.table_view_vpt_price.warranty IS 'Warranty length in days for the role';
COMMENT ON COLUMN sa.table_view_vpt_price.avg_cost IS 'Part s average cost';
COMMENT ON COLUMN sa.table_view_vpt_price.price IS 'Price for a given product';
COMMENT ON COLUMN sa.table_view_vpt_price.effective_date IS 'Date the price instance becomes effective';
COMMENT ON COLUMN sa.table_view_vpt_price.expire_date IS 'Last date the price instance is effective';
COMMENT ON COLUMN sa.table_view_vpt_price.prc_prog_name IS 'Name for the pricing program';
COMMENT ON COLUMN sa.table_view_vpt_price.qty IS 'The quantity of the priced part being quoted';
COMMENT ON COLUMN sa.table_view_vpt_price.objid IS 'Price_inst internal record number';
COMMENT ON COLUMN sa.table_view_vpt_price.prc_prog_obj IS 'Price program internal record number';
COMMENT ON COLUMN sa.table_view_vpt_price.prc_qty_obj IS 'Price_qty internal record number';