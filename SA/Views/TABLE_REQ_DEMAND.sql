CREATE OR REPLACE FORCE VIEW sa.table_req_demand (objid,hdr_objid,part_mod_objid,owner_objid,gbst_status_objid,rma_number,request_type,order_qty,"ACTIVITY",required_date,details_status,details_type,details_date,serial_no,shipped_qty,backorder_qty,"CONDITION",s_condition,fulfilled_qty,picked_qty,received_qty) AS
select table_demand_dtl.objid, table_demand_dtl.demand_dtl2demand_hdr,
 table_demand_dtl.demand_dtl2part_info, table_demand_dtl.demand_dtl_owner2user,
 table_demand_dtl.dmnd_dtl_sts2gbst_elm, table_demand_dtl.detail_number,
 table_demand_dtl.demand_subtype, table_demand_dtl.demand_qty,
 table_demand_dtl.activity, table_demand_dtl.next_date,
 table_demand_dtl.request_status, table_demand_dtl.request_type,
 table_demand_dtl.details_date, table_demand_dtl.serial_no,
 table_demand_dtl.shipped_qty, table_demand_dtl.backorder_qty,
 table_condition.title, table_condition.S_title, table_demand_dtl.fulfilled_qty,
 table_demand_dtl.picked_qty, table_demand_dtl.received_qty
 from table_demand_dtl, table_condition
 where table_demand_dtl.demand_dtl_owner2user IS NOT NULL
 AND table_demand_dtl.dmnd_dtl_sts2gbst_elm IS NOT NULL
 AND table_demand_dtl.demand_dtl2demand_hdr IS NOT NULL
 AND table_condition.objid = table_demand_dtl.demand_dtl2condition
 AND table_demand_dtl.demand_dtl2part_info IS NOT NULL
 ;
COMMENT ON TABLE sa.table_req_demand IS 'Replaces view req_sum (238) for database retrieval. Used by forms Product Detail Dialog (502) and Part Request Header (501). Avoid adding additional fields from tables: user (20), gbst_elm (79) and view part_mod_v (5333) as performance will degrade';
COMMENT ON COLUMN sa.table_req_demand.objid IS 'Demand_dlt internal record number';
COMMENT ON COLUMN sa.table_req_demand.hdr_objid IS 'Demand hdr internal record number';
COMMENT ON COLUMN sa.table_req_demand.part_mod_objid IS 'Part revision internal record number';
COMMENT ON COLUMN sa.table_req_demand.owner_objid IS 'User owner of the request';
COMMENT ON COLUMN sa.table_req_demand.gbst_status_objid IS 'Status gbst_elm internal record number';
COMMENT ON COLUMN sa.table_req_demand.rma_number IS 'The part request number for the request';
COMMENT ON COLUMN sa.table_req_demand.request_type IS 'Reserved; future';
COMMENT ON COLUMN sa.table_req_demand.order_qty IS 'The part request order quantity';
COMMENT ON COLUMN sa.table_req_demand."ACTIVITY" IS 'Reserved; future';
COMMENT ON COLUMN sa.table_req_demand.required_date IS 'The date required';
COMMENT ON COLUMN sa.table_req_demand.details_status IS 'Status of the request';
COMMENT ON COLUMN sa.table_req_demand.details_type IS 'Type displayed in WIP and queue forms';
COMMENT ON COLUMN sa.table_req_demand.details_date IS 'The create date for the part request';
COMMENT ON COLUMN sa.table_req_demand.serial_no IS 'Serial number for the request';
COMMENT ON COLUMN sa.table_req_demand.shipped_qty IS 'The quantity shipped';
COMMENT ON COLUMN sa.table_req_demand.backorder_qty IS 'Reserved; future';
COMMENT ON COLUMN sa.table_req_demand."CONDITION" IS 'Part request condition';
COMMENT ON COLUMN sa.table_req_demand.fulfilled_qty IS 'Quantify fulfilled (moved) against the part request)';
COMMENT ON COLUMN sa.table_req_demand.picked_qty IS 'Quantify picked (reserved for a fulfill) against the part request)';
COMMENT ON COLUMN sa.table_req_demand.received_qty IS 'Quantify received (from a fulfill) against the part request)';