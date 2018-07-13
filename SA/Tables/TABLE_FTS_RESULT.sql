CREATE TABLE sa.table_fts_result (
  objid NUMBER,
  type_id NUMBER,
  object_id NUMBER,
  attch_id NUMBER,
  id_number VARCHAR2(32 BYTE),
  title VARCHAR2(80 BYTE),
  file_name VARCHAR2(80 BYTE),
  relevance NUMBER,
  col_name VARCHAR2(80 BYTE),
  dev NUMBER
);
ALTER TABLE sa.table_fts_result ADD SUPPLEMENTAL LOG GROUP dmtsora865824564_0 (attch_id, col_name, dev, file_name, id_number, object_id, objid, relevance, title, type_id) ALWAYS;