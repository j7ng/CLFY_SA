CREATE OR REPLACE FORCE VIEW sa.table_req_sum (objid,hdr_objid,part_mod_objid,request_date,case_id_number,rma_number,site_name,s_site_name,part_number,s_part_number,request_type,request_status,order_qty,"ACTIVITY",required_date,details_status,details_type,part_num,s_part_num,details_date,serial_no,shipped_qty,backorder_qty,part_mod_l,s_part_mod_l,"CONDITION",s_condition,status,s_status,"OWNER",s_owner,fulfilled_qty,picked_qty,received_qty,domain,s_domain,cond_objid,cond_code,owner_objid,header_number,s_header_number,orig_id) AS
select table_demand_dtl.objid, table_demand_hdr.objid,
 table_mod_level.objid, table_demand_hdr.header_date,
 table_demand_hdr.header_case_no, table_demand_dtl.detail_number,
 table_demand_hdr.site_name, table_demand_hdr.S_site_name, table_part_num.part_number, table_part_num.S_part_number,
 table_demand_dtl.demand_subtype, table_demand_hdr.request_status,
 table_demand_dtl.demand_qty, table_demand_dtl.activity,
 table_demand_dtl.next_date, table_demand_dtl.request_status,
 table_demand_dtl.request_type, table_part_num.description, table_part_num.S_description,
 table_demand_dtl.details_date, table_demand_dtl.serial_no,
 table_demand_dtl.shipped_qty, table_demand_dtl.backorder_qty,
 table_mod_level.mod_level, table_mod_level.S_mod_level, table_condition.title, table_condition.S_title,
 table_gse_status.title, table_gse_status.S_title, table_user.login_name, table_user.S_login_name,
 table_demand_dtl.fulfilled_qty, table_demand_dtl.picked_qty,
 table_demand_dtl.received_qty, table_part_num.domain, table_part_num.S_domain,
 table_condition.objid, table_condition.condition,
 table_user.objid, table_demand_hdr.header_number, table_demand_hdr.S_header_number,
 table_demand_dtl.orig_id
 from table_gbst_elm table_gse_status, table_demand_dtl, table_demand_hdr, table_mod_level,
  table_part_num, table_condition, table_user
 where table_demand_hdr.objid = table_demand_dtl.demand_dtl2demand_hdr
 AND table_part_num.objid = table_mod_level.part_info2part_num
 AND table_condition.objid = table_demand_dtl.demand_dtl2condition
 AND table_mod_level.objid = table_demand_dtl.demand_dtl2part_info
 AND table_gse_status.objid = table_demand_dtl.dmnd_dtl_sts2gbst_elm
 AND table_user.objid = table_demand_dtl.demand_dtl_owner2user
 ;
COMMENT ON TABLE sa.table_req_sum IS 'Queries in the query group. No longer use by forms Part Request Details (502). Still used only as an in-memory data store in conjunction with views 5332 and 5333';
COMMENT ON COLUMN sa.table_req_sum.objid IS 'Demand_dlt internal record number';
COMMENT ON COLUMN sa.table_req_sum.hdr_objid IS 'Demand hdr internal record number';
COMMENT ON COLUMN sa.table_req_sum.part_mod_objid IS 'Part revision internal record number';
COMMENT ON COLUMN sa.table_req_sum.request_date IS 'The create date for the request header';
COMMENT ON COLUMN sa.table_req_sum.case_id_number IS 'The case or subcase optionally related to the request';
COMMENT ON COLUMN sa.table_req_sum.rma_number IS 'The part request number for the request';
COMMENT ON COLUMN sa.table_req_sum.site_name IS 'Local copy of the site name';
COMMENT ON COLUMN sa.table_req_sum.part_number IS 'Part number/name';
COMMENT ON COLUMN sa.table_req_sum.request_type IS 'Reserved; future';
COMMENT ON COLUMN sa.table_req_sum.request_status IS 'Status of the request';
COMMENT ON COLUMN sa.table_req_sum.order_qty IS 'The order quantity';
COMMENT ON COLUMN sa.table_req_sum."ACTIVITY" IS 'Reserved; future';
COMMENT ON COLUMN sa.table_req_sum.required_date IS 'The date required';
COMMENT ON COLUMN sa.table_req_sum.details_status IS 'Status of the request';
COMMENT ON COLUMN sa.table_req_sum.details_type IS 'Type displayed in WIP and queue forms';
COMMENT ON COLUMN sa.table_req_sum.part_num IS 'Maps to sales and mfg systems';
COMMENT ON COLUMN sa.table_req_sum.details_date IS 'The create date for the part request';
COMMENT ON COLUMN sa.table_req_sum.serial_no IS 'Serial number for the request';
COMMENT ON COLUMN sa.table_req_sum.shipped_qty IS 'The quantity shipped';
COMMENT ON COLUMN sa.table_req_sum.backorder_qty IS 'Reserved; future';
COMMENT ON COLUMN sa.table_req_sum.part_mod_l IS 'Revision level';
COMMENT ON COLUMN sa.table_req_sum."CONDITION" IS 'Part request condition';
COMMENT ON COLUMN sa.table_req_sum.status IS 'Status of the part request';
COMMENT ON COLUMN sa.table_req_sum."OWNER" IS 'User login name';
COMMENT ON COLUMN sa.table_req_sum.fulfilled_qty IS 'Quantify fulfilled (moved) against the part request)';
COMMENT ON COLUMN sa.table_req_sum.picked_qty IS 'Quantify picked (reserved for a fulfill) against the part request)';
COMMENT ON COLUMN sa.table_req_sum.received_qty IS 'Quantify received (from a fulfill) against the part request)';
COMMENT ON COLUMN sa.table_req_sum.domain IS 'Name of the domain for the part num. See object prt_domain';
COMMENT ON COLUMN sa.table_req_sum.cond_objid IS 'Part request condition internal record number';
COMMENT ON COLUMN sa.table_req_sum.cond_code IS 'Part request condition code';
COMMENT ON COLUMN sa.table_req_sum.owner_objid IS 'User owner of the part request internal record number';
COMMENT ON COLUMN sa.table_req_sum.header_number IS 'header_number';
COMMENT ON COLUMN sa.table_req_sum.orig_id IS 'If originated from another demand_dtl, the originating part request s detail_number (see relation demand_dtl.child_dtl2demand_dtl)';