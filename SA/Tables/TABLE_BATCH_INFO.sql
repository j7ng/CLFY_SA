CREATE TABLE sa.table_batch_info (
  objid NUMBER,
  dev NUMBER,
  detail_id VARCHAR2(20 BYTE),
  inst_objid NUMBER,
  to_bin_objid NUMBER,
  inst_status NUMBER,
  request_status VARCHAR2(80 BYTE),
  mod_objid NUMBER,
  fm_expn_objid NUMBER,
  route_to_test NUMBER,
  unit_damage NUMBER,
  pkg_problem NUMBER,
  carrier VARCHAR2(40 BYTE),
  waybill VARCHAR2(40 BYTE),
  "TYPE" NUMBER,
  create_date DATE,
  serial_no VARCHAR2(30 BYTE),
  orig_order_qty NUMBER,
  picked_qty NUMBER
);
ALTER TABLE sa.table_batch_info ADD SUPPLEMENTAL LOG GROUP dmtsora683087437_0 (carrier, create_date, detail_id, dev, fm_expn_objid, inst_objid, inst_status, mod_objid, objid, orig_order_qty, picked_qty, pkg_problem, request_status, route_to_test, serial_no, to_bin_objid, "TYPE", unit_damage, waybill) ALWAYS;