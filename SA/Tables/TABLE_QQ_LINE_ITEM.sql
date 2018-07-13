CREATE TABLE sa.table_qq_line_item (
  objid NUMBER,
  line_no NUMBER,
  part_number VARCHAR2(30 BYTE),
  quantity NUMBER,
  description VARCHAR2(255 BYTE),
  s_description VARCHAR2(255 BYTE),
  "COST" NUMBER,
  list_price NUMBER,
  actual_price NUMBER,
  extension NUMBER,
  tax_ind NUMBER,
  taxable NUMBER,
  comments VARCHAR2(255 BYTE),
  s_comments VARCHAR2(255 BYTE),
  revision VARCHAR2(10 BYTE),
  dev NUMBER,
  q_item2quick_quote NUMBER(*,0),
  q_item2mod_level NUMBER(*,0)
);
ALTER TABLE sa.table_qq_line_item ADD SUPPLEMENTAL LOG GROUP dmtsora262851087_0 (actual_price, comments, "COST", description, dev, extension, line_no, list_price, objid, part_number, quantity, q_item2mod_level, q_item2quick_quote, revision, s_comments, s_description, taxable, tax_ind) ALWAYS;