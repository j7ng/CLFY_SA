CREATE TABLE sa.table_cycle_stage (
  objid NUMBER,
  stage_id VARCHAR2(25 BYTE),
  "NAME" VARCHAR2(50 BYTE),
  s_name VARCHAR2(50 BYTE),
  description VARCHAR2(255 BYTE),
  objective VARCHAR2(255 BYTE),
  seller_actions VARCHAR2(255 BYTE),
  buyer_actions VARCHAR2(255 BYTE),
  fallout_pct NUMBER,
  close_pct NUMBER,
  in_days NUMBER,
  close_days NUMBER,
  num_calls NUMBER,
  dev NUMBER,
  stage2cls_group NUMBER,
  stage_status2gbst_elm NUMBER
);
ALTER TABLE sa.table_cycle_stage ADD SUPPLEMENTAL LOG GROUP dmtsora54142945_0 (buyer_actions, close_days, close_pct, description, dev, fallout_pct, in_days, "NAME", num_calls, objective, objid, seller_actions, stage2cls_group, stage_id, stage_status2gbst_elm, s_name) ALWAYS;
COMMENT ON TABLE sa.table_cycle_stage IS 'Specifies a stage in a life cycle';
COMMENT ON COLUMN sa.table_cycle_stage.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_cycle_stage.stage_id IS 'Identifier of the stage within life cycle';
COMMENT ON COLUMN sa.table_cycle_stage."NAME" IS 'Name of the stage';
COMMENT ON COLUMN sa.table_cycle_stage.description IS 'Description of the stage';
COMMENT ON COLUMN sa.table_cycle_stage.objective IS 'Objective or desired outcome of the stage';
COMMENT ON COLUMN sa.table_cycle_stage.seller_actions IS 'Actions that the seller must perform';
COMMENT ON COLUMN sa.table_cycle_stage.buyer_actions IS 'Actions that the buyer must perform';
COMMENT ON COLUMN sa.table_cycle_stage.fallout_pct IS 'Average percent of deals that do not move forward to the next stage';
COMMENT ON COLUMN sa.table_cycle_stage.close_pct IS 'Average percent of deals that eventually close from the stage';
COMMENT ON COLUMN sa.table_cycle_stage.in_days IS 'Average number of days spent in the stage';
COMMENT ON COLUMN sa.table_cycle_stage.close_days IS 'Average number of days to close from the stage';
COMMENT ON COLUMN sa.table_cycle_stage.num_calls IS 'Average number of calls in the stage';
COMMENT ON COLUMN sa.table_cycle_stage.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_cycle_stage.stage2cls_group IS 'Factory group which implements the stage';
COMMENT ON COLUMN sa.table_cycle_stage.stage_status2gbst_elm IS 'Status assigned to the cycle stage';