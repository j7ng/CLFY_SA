CREATE TABLE sa.table_locale (
  objid NUMBER,
  dev NUMBER,
  iso_lang VARCHAR2(2 BYTE),
  iso_cntry VARCHAR2(2 BYTE),
  win32_lcid NUMBER,
  clarify_lang NUMBER,
  crt_locale VARCHAR2(255 BYTE),
  browser_charset VARCHAR2(40 BYTE)
);
ALTER TABLE sa.table_locale ADD SUPPLEMENTAL LOG GROUP dmtsora522932144_0 (browser_charset, clarify_lang, crt_locale, dev, iso_cntry, iso_lang, objid, win32_lcid) ALWAYS;