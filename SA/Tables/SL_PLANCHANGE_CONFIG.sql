CREATE TABLE sa.sl_planchange_config (
  state_cd VARCHAR2(2 BYTE),
  old_plan VARCHAR2(40 BYTE),
  new_plan VARCHAR2(40 BYTE),
  additional_days NUMBER
);