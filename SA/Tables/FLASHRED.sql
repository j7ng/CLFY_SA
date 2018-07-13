CREATE TABLE sa.flashred (
  units NUMBER,
  cnt NUMBER,
  site_id VARCHAR2(80 BYTE)
);
ALTER TABLE sa.flashred ADD SUPPLEMENTAL LOG GROUP dmtsora982001299_0 (cnt, site_id, units) ALWAYS;