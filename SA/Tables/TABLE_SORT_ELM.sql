CREATE TABLE sa.table_sort_elm (
  objid NUMBER,
  sort_num NUMBER,
  field_name VARCHAR2(80 BYTE),
  path_name VARCHAR2(255 BYTE),
  sort_seq VARCHAR2(15 BYTE),
  dev NUMBER,
  sort_elm2query NUMBER(*,0),
  sort_elm2filterset NUMBER(*,0),
  sort_elm2web_filter NUMBER,
  addnl_info VARCHAR2(255 BYTE),
  sort_elm2xfilterset NUMBER
);
ALTER TABLE sa.table_sort_elm ADD SUPPLEMENTAL LOG GROUP dmtsora755991386_0 (addnl_info, dev, field_name, objid, path_name, sort_elm2filterset, sort_elm2query, sort_elm2web_filter, sort_elm2xfilterset, sort_num, sort_seq) ALWAYS;