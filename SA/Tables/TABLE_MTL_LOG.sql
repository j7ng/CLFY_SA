CREATE TABLE sa.table_mtl_log (
  objid NUMBER,
  failure_code VARCHAR2(40 BYTE),
  repair_code VARCHAR2(40 BYTE),
  billable NUMBER,
  bill_to VARCHAR2(30 BYTE),
  removed NUMBER,
  wrk_center VARCHAR2(40 BYTE),
  standard_cost NUMBER(19,4),
  notes VARCHAR2(255 BYTE),
  ref_designator VARCHAR2(20 BYTE),
  disposition NUMBER,
  transaction_id VARCHAR2(20 BYTE),
  dev NUMBER,
  mtl_log2onsite_log NUMBER(*,0),
  mtl_log2mod_level NUMBER(*,0)
);
ALTER TABLE sa.table_mtl_log ADD SUPPLEMENTAL LOG GROUP dmtsora1232238840_0 (billable, bill_to, dev, disposition, failure_code, mtl_log2mod_level, mtl_log2onsite_log, notes, objid, ref_designator, removed, repair_code, standard_cost, transaction_id, wrk_center) ALWAYS;