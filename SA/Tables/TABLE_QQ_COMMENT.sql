CREATE TABLE sa.table_qq_comment (
  objid NUMBER,
  sequence_num NUMBER,
  comments VARCHAR2(255 BYTE),
  create_date DATE,
  "ACTIVE" NUMBER,
  dev NUMBER,
  comment2quick_quote NUMBER(*,0),
  comment2contract NUMBER(*,0)
);
ALTER TABLE sa.table_qq_comment ADD SUPPLEMENTAL LOG GROUP dmtsora9966792_0 ("ACTIVE", comment2contract, comment2quick_quote, comments, create_date, dev, objid, sequence_num) ALWAYS;