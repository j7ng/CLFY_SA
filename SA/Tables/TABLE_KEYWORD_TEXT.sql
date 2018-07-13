CREATE TABLE sa.table_keyword_text (
  objid NUMBER,
  keyword_text LONG,
  dev NUMBER,
  keywords2probdesc NUMBER(*,0)
);
ALTER TABLE sa.table_keyword_text ADD SUPPLEMENTAL LOG GROUP dmtsora1987426111_0 (dev, keywords2probdesc, objid) ALWAYS;