CREATE TABLE sa.table_btn_argument (
  objid NUMBER,
  "RANK" NUMBER,
  cobj_name VARCHAR2(80 BYTE),
  field_name VARCHAR2(80 BYTE),
  behavior VARCHAR2(16 BYTE),
  dev NUMBER,
  btn_argument2in_action NUMBER(*,0),
  btn_argument2out_action NUMBER(*,0)
);
ALTER TABLE sa.table_btn_argument ADD SUPPLEMENTAL LOG GROUP dmtsora2044860481_0 (behavior, btn_argument2in_action, btn_argument2out_action, cobj_name, dev, field_name, objid, "RANK") ALWAYS;