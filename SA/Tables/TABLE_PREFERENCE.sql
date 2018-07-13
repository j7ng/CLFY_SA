CREATE TABLE sa.table_preference (
  objid NUMBER,
  dev NUMBER,
  subtype NUMBER,
  subtype_value VARCHAR2(80 BYTE),
  "ACTIVE" NUMBER,
  pref2web_user NUMBER,
  pref_type2gbst_elm NUMBER,
  source_lowid NUMBER,
  source_type NUMBER
);
ALTER TABLE sa.table_preference ADD SUPPLEMENTAL LOG GROUP dmtsora1360756017_0 ("ACTIVE", dev, objid, pref2web_user, pref_type2gbst_elm, source_lowid, source_type, subtype, subtype_value) ALWAYS;