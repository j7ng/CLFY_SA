CREATE TABLE sa.table_stage_metric (
  objid NUMBER,
  dev NUMBER,
  metric2cycle_stage NUMBER(*,0)
);
ALTER TABLE sa.table_stage_metric ADD SUPPLEMENTAL LOG GROUP dmtsora2095862489_0 (dev, metric2cycle_stage, objid) ALWAYS;