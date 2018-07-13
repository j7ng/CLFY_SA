CREATE TABLE sa.table_win_locale_info (
  objid NUMBER,
  dev NUMBER,
  locale_group VARCHAR2(50 BYTE),
  locale_lang VARCHAR2(100 BYTE),
  locale_code VARCHAR2(3 BYTE)
);
ALTER TABLE sa.table_win_locale_info ADD SUPPLEMENTAL LOG GROUP dmtsora760060460_0 (dev, locale_code, locale_group, locale_lang, objid) ALWAYS;