CREATE TABLE sa.x_dma_active (
  active_date DATE,
  dma VARCHAR2(100 BYTE),
  cnt NUMBER
);
ALTER TABLE sa.x_dma_active ADD SUPPLEMENTAL LOG GROUP dmtsora1358333827_0 (active_date, cnt, dma) ALWAYS;