CREATE TABLE sa.x_dma_areas (
  dma VARCHAR2(100 BYTE),
  zip_code VARCHAR2(100 BYTE),
  "STATE" VARCHAR2(100 BYTE)
);
ALTER TABLE sa.x_dma_areas ADD SUPPLEMENTAL LOG GROUP dmtsora2003111337_0 (dma, "STATE", zip_code) ALWAYS;