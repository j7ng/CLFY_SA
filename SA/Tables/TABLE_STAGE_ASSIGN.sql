CREATE TABLE sa.table_stage_assign (
  objid NUMBER,
  seq_num NUMBER,
  dev NUMBER,
  assign2cycle_stage NUMBER(*,0),
  assign2life_cycle NUMBER(*,0)
);
ALTER TABLE sa.table_stage_assign ADD SUPPLEMENTAL LOG GROUP dmtsora1603355637_0 (assign2cycle_stage, assign2life_cycle, dev, objid, seq_num) ALWAYS;