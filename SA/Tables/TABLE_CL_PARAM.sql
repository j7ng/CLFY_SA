CREATE TABLE sa.table_cl_param (
  objid NUMBER,
  dev NUMBER,
  "RANK" NUMBER,
  focus_type NUMBER,
  data_type NUMBER,
  param_name VARCHAR2(80 BYTE),
  text_value LONG,
  integer_value NUMBER,
  decimal_value NUMBER(19,4),
  datetime_value DATE,
  property_name VARCHAR2(80 BYTE),
  s_property_name VARCHAR2(80 BYTE),
  cl_param2cl_action NUMBER
);
ALTER TABLE sa.table_cl_param ADD SUPPLEMENTAL LOG GROUP dmtsora1667274722_0 (cl_param2cl_action, data_type, datetime_value, decimal_value, dev, focus_type, integer_value, objid, param_name, property_name, "RANK", s_property_name) ALWAYS;