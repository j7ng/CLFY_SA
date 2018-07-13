CREATE TABLE sa.mtm_cos_partclass_carrier (
  objid NUMBER,
  sp_mkt_name VARCHAR2(50 BYTE),
  fea_name VARCHAR2(50 BYTE) NOT NULL,
  fea_value VARCHAR2(50 BYTE) NOT NULL,
  part_class_name VARCHAR2(40 BYTE),
  part_class_objid NUMBER,
  x_parent_name VARCHAR2(40 BYTE),
  new_cos VARCHAR2(100 BYTE),
  x_start_date DATE,
  x_end_date DATE
);
COMMENT ON COLUMN sa.mtm_cos_partclass_carrier.objid IS 'UNIQUE RECORD IDENTIFIER';
COMMENT ON COLUMN sa.mtm_cos_partclass_carrier.sp_mkt_name IS 'SERVICE PLAN MARKET NAME';
COMMENT ON COLUMN sa.mtm_cos_partclass_carrier.fea_name IS 'FEATURES NAME';
COMMENT ON COLUMN sa.mtm_cos_partclass_carrier.fea_value IS 'FEATURES VALUE';
COMMENT ON COLUMN sa.mtm_cos_partclass_carrier.part_class_name IS 'PART CLASS NAME';
COMMENT ON COLUMN sa.mtm_cos_partclass_carrier.part_class_objid IS 'PART CLASS OBJID';
COMMENT ON COLUMN sa.mtm_cos_partclass_carrier.x_parent_name IS 'CARRIER NAME';
COMMENT ON COLUMN sa.mtm_cos_partclass_carrier.new_cos IS 'NEW COS VALUE';
COMMENT ON COLUMN sa.mtm_cos_partclass_carrier.x_start_date IS 'EFFECTIVE START DATE';
COMMENT ON COLUMN sa.mtm_cos_partclass_carrier.x_end_date IS 'EFFECTIVE END DATE';