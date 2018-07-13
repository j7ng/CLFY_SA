CREATE TABLE sa.tmp_promo_esns (
  esn VARCHAR2(20 BYTE)
);
ALTER TABLE sa.tmp_promo_esns ADD SUPPLEMENTAL LOG GROUP dmtsora180237932_0 (esn) ALWAYS;