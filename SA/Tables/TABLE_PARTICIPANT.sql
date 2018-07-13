CREATE TABLE sa.table_participant (
  objid NUMBER,
  dev NUMBER,
  focus_type NUMBER,
  focus_lowid NUMBER,
  role_code NUMBER,
  participant2act_entry NUMBER
);
ALTER TABLE sa.table_participant ADD SUPPLEMENTAL LOG GROUP dmtsora1960512780_0 (dev, focus_lowid, focus_type, objid, participant2act_entry, role_code) ALWAYS;