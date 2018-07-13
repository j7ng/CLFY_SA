CREATE TABLE sa.table_cursor_db (
  objid NUMBER,
  "ID" NUMBER,
  "NAME" VARCHAR2(80 BYTE),
  width NUMBER,
  height NUMBER,
  flags NUMBER,
  pixels VARCHAR2(255 BYTE),
  dev NUMBER
);
ALTER TABLE sa.table_cursor_db ADD SUPPLEMENTAL LOG GROUP dmtsora1861183332_0 (dev, flags, height, "ID", "NAME", objid, pixels, width) ALWAYS;