CREATE TABLE sa.table_hint_inst (
  objid NUMBER,
  logic_value NUMBER,
  logic_val_str VARCHAR2(10 BYTE),
  dev NUMBER,
  hint_logic2prog_logic NUMBER(*,0),
  hint_info2diag_hint NUMBER(*,0),
  hint_info2case NUMBER(*,0)
);
ALTER TABLE sa.table_hint_inst ADD SUPPLEMENTAL LOG GROUP dmtsora1465258027_0 (dev, hint_info2case, hint_info2diag_hint, hint_logic2prog_logic, logic_value, logic_val_str, objid) ALWAYS;