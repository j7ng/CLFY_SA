CREATE TABLE sa.data_config_mapping_log (
  x_parent_id VARCHAR2(30 BYTE),
  x_part_class_objid NUMBER,
  x_rate_plan VARCHAR2(60 BYTE),
  x_data_config_objid NUMBER,
  "ACTION" VARCHAR2(10 BYTE),
  changed_by VARCHAR2(30 BYTE),
  change_date DATE
);