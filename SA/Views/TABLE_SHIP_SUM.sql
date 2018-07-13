CREATE OR REPLACE FORCE VIEW sa.table_ship_sum (objid,last_fulf_sn,shipped_sn,ship_parts_objid,ship_date,waybill,ship_weight,rma_number,part_number,s_part_number,part_num_desc,s_part_num_desc,shipped_qty,serial_no,site_name,"ACTIVITY","CONDITION",s_condition,status,s_status,"OWNER",s_owner,title,dtl_num,dtl_type,dtl_date,carrier,s_carrier,part_rev,s_part_rev,dtl_objid,ship_address,ship_address2,ship_city,ship_state,ship_zip,ship_pieces) AS
select table_ship_dtl.objid, table_demand_dtl.last_fulf_sn,
 table_ship_dtl.serial_no, table_ship_parts.objid,
 table_ship_parts.ship_date, table_ship_parts.waybill,
 table_ship_parts.total_weight, table_demand_dtl.detail_number,
 table_ship_dtl.part_number, table_ship_dtl.S_part_number, table_ship_dtl.description, table_ship_dtl.S_description,
 table_demand_dtl.shipped_qty, table_demand_dtl.serial_no,
 table_ship_parts.ship_to_name, table_demand_dtl.activity,
 table_condition.title, table_condition.S_title, table_gse_status.title, table_gse_status.S_title,
 table_ship_parts.shipper_user, table_ship_parts.S_shipper_user, table_demand_dtl.title,
 table_demand_dtl.detail_number, table_demand_dtl.request_type,
 table_demand_dtl.details_date, table_site.name, table_site.S_name,
 table_ship_dtl.mod_level, table_ship_dtl.S_mod_level, table_demand_dtl.objid,
 table_ship_parts.ship_address, table_ship_parts.ship_address2,
 table_ship_parts.ship_city, table_ship_parts.ship_state,
 table_ship_parts.ship_zip, table_ship_parts.pieces
 from table_gbst_elm table_gse_status, table_ship_dtl, table_demand_dtl, table_ship_parts,
  table_condition, table_site
 where table_demand_dtl.objid = table_ship_dtl.ship_dtl2demand_dtl
 AND table_condition.objid = table_demand_dtl.demand_dtl2condition
 AND table_gse_status.objid = table_demand_dtl.dmnd_dtl_sts2gbst_elm
 AND table_site.objid (+) = table_ship_parts.carrier2vendor
 AND table_ship_parts.objid = table_ship_dtl.ship_dtl2ship_parts
 ;
COMMENT ON TABLE sa.table_ship_sum IS 'Displays queries in the query group. Used by form Shipments Query List (589)';
COMMENT ON COLUMN sa.table_ship_sum.objid IS 'Ship_dtl internal record number';
COMMENT ON COLUMN sa.table_ship_sum.last_fulf_sn IS 'Last fulfilled serial number for req detail';
COMMENT ON COLUMN sa.table_ship_sum.shipped_sn IS 'Shipped serial number for req detail';
COMMENT ON COLUMN sa.table_ship_sum.ship_parts_objid IS 'Ship_parts internal record number';
COMMENT ON COLUMN sa.table_ship_sum.ship_date IS 'The ship date for the parts';
COMMENT ON COLUMN sa.table_ship_sum.waybill IS 'The waybill number';
COMMENT ON COLUMN sa.table_ship_sum.ship_weight IS 'The total weight of the shipment';
COMMENT ON COLUMN sa.table_ship_sum.rma_number IS 'The part request number for the request of the shipment';
COMMENT ON COLUMN sa.table_ship_sum.part_number IS 'Part number/name';
COMMENT ON COLUMN sa.table_ship_sum.part_num_desc IS 'Part number, maps to sales and mfg systems';
COMMENT ON COLUMN sa.table_ship_sum.shipped_qty IS 'The quantity shipped';
COMMENT ON COLUMN sa.table_ship_sum.serial_no IS 'Serial number for the request';
COMMENT ON COLUMN sa.table_ship_sum.site_name IS 'Local copy of the site name';
COMMENT ON COLUMN sa.table_ship_sum."ACTIVITY" IS 'Reserved; future';
COMMENT ON COLUMN sa.table_ship_sum."CONDITION" IS 'Part request condition';
COMMENT ON COLUMN sa.table_ship_sum.status IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_ship_sum."OWNER" IS 'Ship Originator - login name';
COMMENT ON COLUMN sa.table_ship_sum.title IS 'Part request title';
COMMENT ON COLUMN sa.table_ship_sum.dtl_num IS 'Request ID';
COMMENT ON COLUMN sa.table_ship_sum.dtl_type IS 'Request types; i.e., "depot repair", "advance exchange", or "return for credit"';
COMMENT ON COLUMN sa.table_ship_sum.dtl_date IS 'Request date';
COMMENT ON COLUMN sa.table_ship_sum.carrier IS 'Carrier for shipment';
COMMENT ON COLUMN sa.table_ship_sum.part_rev IS 'Name of the part revision, AKA part version';
COMMENT ON COLUMN sa.table_ship_sum.dtl_objid IS 'Internal reference number of the part request';
COMMENT ON COLUMN sa.table_ship_sum.ship_address IS 'Ship to address; line 1';
COMMENT ON COLUMN sa.table_ship_sum.ship_address2 IS 'Ship to address; line 2';
COMMENT ON COLUMN sa.table_ship_sum.ship_city IS 'Ship to city';
COMMENT ON COLUMN sa.table_ship_sum.ship_state IS 'Ship to state';
COMMENT ON COLUMN sa.table_ship_sum.ship_zip IS 'Ship to zip code';
COMMENT ON COLUMN sa.table_ship_sum.ship_pieces IS 'Number of pieces in the shipment';