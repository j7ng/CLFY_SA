CREATE TABLE sa.table_search_control (
  objid NUMBER,
  description VARCHAR2(255 BYTE),
  parameter_set VARCHAR2(30 BYTE),
  default_status VARCHAR2(5 BYTE),
  "AVAILABILITY" VARCHAR2(20 BYTE),
  target_type VARCHAR2(10 BYTE),
  source_object NUMBER,
  external_name VARCHAR2(80 BYTE),
  internal_name VARCHAR2(255 BYTE),
  display_order NUMBER,
  reserved VARCHAR2(10 BYTE),
  dev NUMBER
);
ALTER TABLE sa.table_search_control ADD SUPPLEMENTAL LOG GROUP dmtsora1072226022_0 ("AVAILABILITY", default_status, description, dev, display_order, external_name, internal_name, objid, parameter_set, reserved, source_object, target_type) ALWAYS;