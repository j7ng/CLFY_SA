CREATE TABLE sa.table_choice_fld (
  objid NUMBER,
  referring_type NUMBER,
  logical_name VARCHAR2(32 BYTE),
  rel_name VARCHAR2(32 BYTE),
  default_list VARCHAR2(32 BYTE),
  dev NUMBER,
  choice2list_struct NUMBER
);
ALTER TABLE sa.table_choice_fld ADD SUPPLEMENTAL LOG GROUP dmtsora473439273_0 (choice2list_struct, default_list, dev, logical_name, objid, referring_type, rel_name) ALWAYS;