CREATE TABLE sa.table_demand_dtl (
  objid NUMBER,
  demand_type NUMBER,
  demand_subtype NUMBER,
  detail_number VARCHAR2(20 BYTE),
  details_date DATE,
  "ACTIVITY" NUMBER,
  details_status VARCHAR2(40 BYTE),
  demand_qty NUMBER,
  shipped_qty NUMBER,
  next_date DATE,
  ship_to_flag NUMBER,
  po_number VARCHAR2(30 BYTE),
  detail_notes VARCHAR2(255 BYTE),
  requested_mod VARCHAR2(10 BYTE),
  part_price NUMBER(19,4),
  vendor_rma VARCHAR2(20 BYTE),
  serial_no VARCHAR2(40 BYTE),
  det_type NUMBER,
  rep_warranty DATE,
  movement_type NUMBER,
  backorder_qty NUMBER,
  price_program VARCHAR2(20 BYTE),
  request_type VARCHAR2(40 BYTE),
  "PRIORITY" VARCHAR2(40 BYTE),
  ship_via VARCHAR2(80 BYTE),
  request_status VARCHAR2(40 BYTE),
  closed NUMBER,
  ship_date DATE,
  carrier VARCHAR2(40 BYTE),
  receipt_date DATE,
  waybill VARCHAR2(40 BYTE),
  repair_type VARCHAR2(40 BYTE),
  repair_status VARCHAR2(40 BYTE),
  s_repair_status VARCHAR2(40 BYTE),
  failure_code VARCHAR2(40 BYTE),
  repair_cost NUMBER(19,4),
  doa NUMBER,
  ntf NUMBER,
  reported_prob VARCHAR2(255 BYTE),
  repair_comment VARCHAR2(255 BYTE),
  originator VARCHAR2(30 BYTE),
  s_originator VARCHAR2(30 BYTE),
  est_rtn_date DATE,
  warranty NUMBER,
  title VARCHAR2(80 BYTE),
  rma_history LONG,
  ownership_stmp DATE,
  modify_stmp DATE,
  dist NUMBER,
  removed NUMBER,
  picked_qty NUMBER,
  fulfilled_qty NUMBER,
  received_qty NUMBER,
  rpr_time NUMBER,
  test_time NUMBER,
  qa_time NUMBER,
  last_fulf_sn VARCHAR2(40 BYTE),
  last_rcv_sn VARCHAR2(40 BYTE),
  mtl_cost NUMBER(19,4),
  labor_cost NUMBER(19,4),
  dev NUMBER,
  demand_dtl2demand_hdr NUMBER(*,0),
  demand_dtl2part_inst NUMBER(*,0),
  demand_dtl2retrn_info NUMBER(*,0),
  demand_dtl2pick_part NUMBER(*,0),
  demand_dtl_owner2user NUMBER(*,0),
  demand_dtl2condition NUMBER(*,0),
  demand_dtl_wip2wipbin NUMBER(*,0),
  demand_dtl_prvq2queue NUMBER(*,0),
  demand_dtl_curq2queue NUMBER(*,0),
  dmnd_dtl_sts2gbst_elm NUMBER(*,0),
  demand_dtl_orig2user NUMBER(*,0),
  demand_dtl2part_info NUMBER(*,0),
  demand_dtl2site_part NUMBER(*,0),
  remove_dtl2part_trans NUMBER(*,0),
  demand_dtl2inv_bin NUMBER(*,0),
  orig_part2part_info NUMBER(*,0),
  demand_pick2x_pi_hist NUMBER,
  demand_rec2x_pi_hist NUMBER,
  child_dtl2demand_dtl NUMBER,
  in_repair_qty NUMBER,
  orig_id VARCHAR2(20 BYTE),
  part_used_qty NUMBER,
  update_inv_qty NUMBER
);
ALTER TABLE sa.table_demand_dtl ADD SUPPLEMENTAL LOG GROUP dmtsora541120857_0 ("ACTIVITY", backorder_qty, carrier, closed, demand_qty, demand_subtype, demand_type, details_date, details_status, detail_notes, detail_number, det_type, movement_type, next_date, objid, part_price, po_number, price_program, "PRIORITY", receipt_date, repair_status, repair_type, rep_warranty, requested_mod, request_status, request_type, serial_no, shipped_qty, ship_date, ship_to_flag, ship_via, vendor_rma, waybill) ALWAYS;
ALTER TABLE sa.table_demand_dtl ADD SUPPLEMENTAL LOG GROUP dmtsora541120857_1 (demand_dtl2condition, demand_dtl2demand_hdr, demand_dtl2part_inst, demand_dtl2pick_part, demand_dtl2retrn_info, demand_dtl_owner2user, dev, dist, doa, est_rtn_date, failure_code, fulfilled_qty, labor_cost, last_fulf_sn, last_rcv_sn, modify_stmp, mtl_cost, ntf, originator, ownership_stmp, picked_qty, qa_time, received_qty, removed, repair_comment, repair_cost, reported_prob, rpr_time, s_originator, s_repair_status, test_time, title, warranty) ALWAYS;
ALTER TABLE sa.table_demand_dtl ADD SUPPLEMENTAL LOG GROUP dmtsora541120857_2 (child_dtl2demand_dtl, demand_dtl2inv_bin, demand_dtl2part_info, demand_dtl2site_part, demand_dtl_curq2queue, demand_dtl_orig2user, demand_dtl_prvq2queue, demand_dtl_wip2wipbin, demand_pick2x_pi_hist, demand_rec2x_pi_hist, dmnd_dtl_sts2gbst_elm, in_repair_qty, orig_id, orig_part2part_info, part_used_qty, remove_dtl2part_trans, update_inv_qty) ALWAYS;
COMMENT ON TABLE sa.table_demand_dtl IS 'Part request detail; contains line item information for part requests including part information';
COMMENT ON COLUMN sa.table_demand_dtl.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_demand_dtl.demand_type IS 'Reserved; future';
COMMENT ON COLUMN sa.table_demand_dtl.demand_subtype IS 'Reserved; future';
COMMENT ON COLUMN sa.table_demand_dtl.detail_number IS 'The part request number for the request';
COMMENT ON COLUMN sa.table_demand_dtl.details_date IS 'The create date for the part request';
COMMENT ON COLUMN sa.table_demand_dtl."ACTIVITY" IS 'Reserved; future';
COMMENT ON COLUMN sa.table_demand_dtl.details_status IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_demand_dtl.demand_qty IS 'The quantity ordered';
COMMENT ON COLUMN sa.table_demand_dtl.shipped_qty IS 'The quantity shipped';
COMMENT ON COLUMN sa.table_demand_dtl.next_date IS 'The date required';
COMMENT ON COLUMN sa.table_demand_dtl.ship_to_flag IS 'Reserved; future';
COMMENT ON COLUMN sa.table_demand_dtl.po_number IS 'The purchase order for the request';
COMMENT ON COLUMN sa.table_demand_dtl.detail_notes IS 'Order notes for the detail';
COMMENT ON COLUMN sa.table_demand_dtl.requested_mod IS 'The part revision requested for the request';
COMMENT ON COLUMN sa.table_demand_dtl.part_price IS 'The price for the request';
COMMENT ON COLUMN sa.table_demand_dtl.vendor_rma IS 'Reserved; future';
COMMENT ON COLUMN sa.table_demand_dtl.serial_no IS 'Serial number for the request';
COMMENT ON COLUMN sa.table_demand_dtl.det_type IS 'Reserved; future';
COMMENT ON COLUMN sa.table_demand_dtl.rep_warranty IS 'Reserved; future';
COMMENT ON COLUMN sa.table_demand_dtl.movement_type IS 'Reserved; future';
COMMENT ON COLUMN sa.table_demand_dtl.backorder_qty IS 'Quantity put on backorder';
COMMENT ON COLUMN sa.table_demand_dtl.price_program IS 'Reserved; future';
COMMENT ON COLUMN sa.table_demand_dtl.request_type IS 'Type of request. This is a user-defined popup with default name RMA_TYPE';
COMMENT ON COLUMN sa.table_demand_dtl."PRIORITY" IS 'Priority displayed in WIP and Queue forms (275 & 728)';
COMMENT ON COLUMN sa.table_demand_dtl.ship_via IS 'Means/priority of shipment; e.g., overnight delivery; from user-defined pop up with default name SHIP_VIA';
COMMENT ON COLUMN sa.table_demand_dtl.request_status IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_demand_dtl.closed IS 'Indicates whether the request is closed';
COMMENT ON COLUMN sa.table_demand_dtl.ship_date IS 'The date the request was shipped';
COMMENT ON COLUMN sa.table_demand_dtl.carrier IS 'The user-defined carrier the request was shipped by; from a user-defined pop up with default name CARRIER';
COMMENT ON COLUMN sa.table_demand_dtl.receipt_date IS 'The date the request was received';
COMMENT ON COLUMN sa.table_demand_dtl.waybill IS 'The waybill for the request';
COMMENT ON COLUMN sa.table_demand_dtl.repair_type IS 'The type of repair for the request. This is a user-defined popup with default name REPAIR_TYPE';
COMMENT ON COLUMN sa.table_demand_dtl.repair_status IS 'The status of repair for the request. This is a user-defined popup with default name REPAIR_STATUS';
COMMENT ON COLUMN sa.table_demand_dtl.failure_code IS 'The failure code for the part. This is from a user-defined popup with default name FAILURE_CODE';
COMMENT ON COLUMN sa.table_demand_dtl.repair_cost IS 'The cost to repair the request';
COMMENT ON COLUMN sa.table_demand_dtl.doa IS 'Indicates whether the item was dead on arrival';
COMMENT ON COLUMN sa.table_demand_dtl.ntf IS 'Indicates whether no trouble was found in the detail';
COMMENT ON COLUMN sa.table_demand_dtl.reported_prob IS 'The reported problem for the request';
COMMENT ON COLUMN sa.table_demand_dtl.repair_comment IS 'The repair comments for the request';
COMMENT ON COLUMN sa.table_demand_dtl.originator IS 'The originator for the detail';
COMMENT ON COLUMN sa.table_demand_dtl.est_rtn_date IS 'The estimated return date for the part';
COMMENT ON COLUMN sa.table_demand_dtl.warranty IS 'Warranty checkbox';
COMMENT ON COLUMN sa.table_demand_dtl.title IS 'Part request title, composed from the part number and part revision';
COMMENT ON COLUMN sa.table_demand_dtl.rma_history IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_demand_dtl.ownership_stmp IS 'The date and time when ownership last changed';
COMMENT ON COLUMN sa.table_demand_dtl.modify_stmp IS 'Date and time when object was last saved';
COMMENT ON COLUMN sa.table_demand_dtl.dist IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_demand_dtl.removed IS 'Indicates the logical removal of the log object; i.e., 0=present, 1=removed, default=0';
COMMENT ON COLUMN sa.table_demand_dtl.picked_qty IS 'The picked (reserved for fulfill) quantity';
COMMENT ON COLUMN sa.table_demand_dtl.fulfilled_qty IS 'The fulfilled (moved) quantity';
COMMENT ON COLUMN sa.table_demand_dtl.received_qty IS 'The received (from a fulfill) quantity';
COMMENT ON COLUMN sa.table_demand_dtl.rpr_time IS 'Labor invested in the repair of the part on this request';
COMMENT ON COLUMN sa.table_demand_dtl.test_time IS 'Labor invested in the testing of part on this request';
COMMENT ON COLUMN sa.table_demand_dtl.qa_time IS 'Labor invested in the quality assurance of part on this request';
COMMENT ON COLUMN sa.table_demand_dtl.last_fulf_sn IS 'Last fulfill Serial number for the request';
COMMENT ON COLUMN sa.table_demand_dtl.last_rcv_sn IS 'Last received Serial number for the request';
COMMENT ON COLUMN sa.table_demand_dtl.mtl_cost IS 'Total material cost recorded within depot repair';
COMMENT ON COLUMN sa.table_demand_dtl.labor_cost IS 'Total labor cost calculated from data within depot repair';
COMMENT ON COLUMN sa.table_demand_dtl.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_demand_dtl.demand_dtl2demand_hdr IS 'Part request header to which the detail belongs';
COMMENT ON COLUMN sa.table_demand_dtl.demand_dtl2part_inst IS 'Part instance received against the part request. Replaced by recd_dtl2part_inst for all operations except for ECO upgrades, which sets this relation to the upgraded part_inst';
COMMENT ON COLUMN sa.table_demand_dtl.demand_dtl2retrn_info IS 'Reserved; future';
COMMENT ON COLUMN sa.table_demand_dtl.demand_dtl2pick_part IS 'Related picked part. Reserved; obsolete. Replaced by pickd_dtl2part_inst';
COMMENT ON COLUMN sa.table_demand_dtl.demand_dtl_owner2user IS 'User that owns the part request detail object';
COMMENT ON COLUMN sa.table_demand_dtl.demand_dtl2condition IS 'Condition of the part request detail object';
COMMENT ON COLUMN sa.table_demand_dtl.demand_dtl_wip2wipbin IS 'WIPbin where the part request detail object currently resides';
COMMENT ON COLUMN sa.table_demand_dtl.demand_dtl_prvq2queue IS 'Used to record which queue demand_dtl was accepted from; for temporary accept';
COMMENT ON COLUMN sa.table_demand_dtl.demand_dtl_curq2queue IS 'Queue to which the part request detail object is currently dispatched';
COMMENT ON COLUMN sa.table_demand_dtl.dmnd_dtl_sts2gbst_elm IS 'Status of the part request detail object';
COMMENT ON COLUMN sa.table_demand_dtl.demand_dtl_orig2user IS 'User that originated the part request detail object';
COMMENT ON COLUMN sa.table_demand_dtl.demand_dtl2part_info IS 'Supplied part revision for the part request detail object';
COMMENT ON COLUMN sa.table_demand_dtl.demand_dtl2site_part IS 'The installed part related to the request';
COMMENT ON COLUMN sa.table_demand_dtl.remove_dtl2part_trans IS 'Reserved; obsolete. Replaced by rem_dtl2part_trans';
COMMENT ON COLUMN sa.table_demand_dtl.demand_dtl2inv_bin IS 'The desired destination inventory bin. Note: the actual destination inventory bin is that of the related fulfull part_trans';
COMMENT ON COLUMN sa.table_demand_dtl.orig_part2part_info IS 'Part revision which was originally requested';
COMMENT ON COLUMN sa.table_demand_dtl.demand_pick2x_pi_hist IS 'History: Part requests which have picked (reserved) the instance to satisfy their demands. Note: this relation holds only until the demand_dtl has been fulfilled, at which time it is nulled';
COMMENT ON COLUMN sa.table_demand_dtl.demand_rec2x_pi_hist IS 'History: Part requests which received the part instance';
COMMENT ON COLUMN sa.table_demand_dtl.child_dtl2demand_dtl IS 'Parent part request from which the part request was spawned';
COMMENT ON COLUMN sa.table_demand_dtl.in_repair_qty IS 'This is always the same qty as the order qty';
COMMENT ON COLUMN sa.table_demand_dtl.orig_id IS 'If originated from another demand_dtl, the originating part request s detail_number (see relation demand_dtl.child_dtl2demand_dtl)';
COMMENT ON COLUMN sa.table_demand_dtl.part_used_qty IS 'Calculated from the addition of removed, installed or exchanged parts from the log parts used process';
COMMENT ON COLUMN sa.table_demand_dtl.update_inv_qty IS 'Always the same qty as the part_used_qty if the update inventory action is completed successfully';