CREATE TABLE sa.table_csc_attach (
  objid NUMBER,
  "REFERENCE" VARCHAR2(255 BYTE),
  "FORMAT" VARCHAR2(40 BYTE),
  csc_size VARCHAR2(40 BYTE),
  attach_type VARCHAR2(20 BYTE),
  server_id NUMBER,
  dev NUMBER
);
ALTER TABLE sa.table_csc_attach ADD SUPPLEMENTAL LOG GROUP dmtsora1518173184_0 (attach_type, csc_size, dev, "FORMAT", objid, "REFERENCE", server_id) ALWAYS;