CREATE TABLE sa.table_to_do_list (
  objid NUMBER,
  rec_level NUMBER,
  start_time DATE,
  end_time DATE,
  "VERSION" NUMBER,
  parent_type NUMBER,
  flags NUMBER,
  comments VARCHAR2(100 BYTE),
  rootobjid NUMBER,
  rootobjtyp NUMBER,
  "OPCODE" NUMBER,
  entry_time DATE,
  flags2 NUMBER,
  flags3 NUMBER,
  dev NUMBER,
  to_do2dist_index NUMBER(*,0),
  to_do2data NUMBER(*,0)
);
ALTER TABLE sa.table_to_do_list ADD SUPPLEMENTAL LOG GROUP dmtsora1650595146_0 (comments, dev, end_time, entry_time, flags, flags2, flags3, objid, "OPCODE", parent_type, rec_level, rootobjid, rootobjtyp, start_time, to_do2data, to_do2dist_index, "VERSION") ALWAYS;