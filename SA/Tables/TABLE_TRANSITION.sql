CREATE TABLE sa.table_transition (
  objid NUMBER,
  description VARCHAR2(255 BYTE),
  "RANK" NUMBER,
  dialog_id NUMBER,
  "NAME" VARCHAR2(40 BYTE),
  status NUMBER,
  focus_type NUMBER,
  focus_subtype VARCHAR2(20 BYTE),
  appl_id VARCHAR2(20 BYTE),
  dev NUMBER,
  from_state2gbst_elm NUMBER(*,0),
  to_state2gbst_elm NUMBER(*,0)
);
ALTER TABLE sa.table_transition ADD SUPPLEMENTAL LOG GROUP dmtsora2134485252_0 (appl_id, description, dev, dialog_id, focus_subtype, focus_type, from_state2gbst_elm, "NAME", objid, "RANK", status, to_state2gbst_elm) ALWAYS;