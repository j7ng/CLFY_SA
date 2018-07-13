CREATE OR REPLACE FORCE VIEW sa.table_repair_sum (objid,details_objid,part_mod_objid,request_date,case_id_number,rma_number,site_name,s_site_name,part_number,s_part_number,request_type,request_status,order_qty,"ACTIVITY",required_date,details_status,part_num,s_part_num,details_date,part_serial_no) AS
select table_demand_hdr.objid, table_demand_dtl.objid,
 table_mod_level.objid, table_demand_hdr.header_date,
 table_demand_hdr.header_case_no, table_demand_dtl.detail_number,
 table_demand_hdr.site_name, table_demand_hdr.S_site_name, table_part_num.part_number, table_part_num.S_part_number,
 table_demand_hdr.demand_type, table_demand_hdr.request_status,
 table_demand_dtl.demand_qty, table_demand_dtl.activity,
 table_demand_dtl.next_date, table_demand_dtl.details_status,
 table_part_num.description, table_part_num.S_description, table_demand_dtl.details_date,
 table_part_inst.part_serial_no
 from table_demand_hdr, table_demand_dtl, table_mod_level,
  table_part_num, table_part_inst
 where table_demand_hdr.objid = table_demand_dtl.demand_dtl2demand_hdr
 AND table_mod_level.objid = table_part_inst.n_part_inst2part_mod
 AND table_part_num.objid = table_mod_level.part_info2part_num
 ;
COMMENT ON TABLE sa.table_repair_sum IS 'Contains repair information about parts on a part request.  Used on third frame of part request form';
COMMENT ON COLUMN sa.table_repair_sum.objid IS 'Demand hdr internal record number';
COMMENT ON COLUMN sa.table_repair_sum.details_objid IS 'Demand_dlt internal record number';
COMMENT ON COLUMN sa.table_repair_sum.part_mod_objid IS 'Part revision internal record number';
COMMENT ON COLUMN sa.table_repair_sum.request_date IS 'The create date for the request header';
COMMENT ON COLUMN sa.table_repair_sum.case_id_number IS 'The case or subcase optionally related to the request';
COMMENT ON COLUMN sa.table_repair_sum.rma_number IS 'The part request number for the request';
COMMENT ON COLUMN sa.table_repair_sum.site_name IS 'Local copy of the site name';
COMMENT ON COLUMN sa.table_repair_sum.part_number IS 'Part number/name';
COMMENT ON COLUMN sa.table_repair_sum.request_type IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_repair_sum.request_status IS 'Status of the request';
COMMENT ON COLUMN sa.table_repair_sum.order_qty IS 'The orderquantity';
COMMENT ON COLUMN sa.table_repair_sum."ACTIVITY" IS 'Reserved; future';
COMMENT ON COLUMN sa.table_repair_sum.required_date IS 'The date required';
COMMENT ON COLUMN sa.table_repair_sum.details_status IS 'The status for the detail';
COMMENT ON COLUMN sa.table_repair_sum.part_num IS 'Maps to sales and mfg systems';
COMMENT ON COLUMN sa.table_repair_sum.details_date IS 'The create date for the part request';
COMMENT ON COLUMN sa.table_repair_sum.part_serial_no IS 'For serial tracked parts, the serial number of the part';