CREATE TABLE sa.table_to_do_entry (
  objid NUMBER,
  "OPCODE" NUMBER,
  entry_time DATE,
  start_time DATE,
  end_time DATE,
  "VERSION" NUMBER,
  reverse_ind NUMBER,
  rec_level NUMBER,
  dev NUMBER,
  to_do_entry2act_entry NUMBER(*,0),
  to_do_entry2dist_obj NUMBER(*,0)
);
ALTER TABLE sa.table_to_do_entry ADD SUPPLEMENTAL LOG GROUP dmtsora2045963649_0 (dev, end_time, entry_time, objid, "OPCODE", rec_level, reverse_ind, start_time, to_do_entry2act_entry, to_do_entry2dist_obj, "VERSION") ALWAYS;