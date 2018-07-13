CREATE TABLE sa.table_string_db (
  objid NUMBER,
  "ID" NUMBER,
  "STRING" VARCHAR2(255 BYTE),
  locale NUMBER,
  "TYPE" NUMBER,
  dev NUMBER,
  "NAME" VARCHAR2(64 BYTE),
  translate_ind NUMBER
);
ALTER TABLE sa.table_string_db ADD SUPPLEMENTAL LOG GROUP dmtsora288822102_0 (dev, "ID", locale, "NAME", objid, "STRING", translate_ind, "TYPE") ALWAYS;