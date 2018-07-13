CREATE TABLE sa.table_receipts_directives (
  objid NUMBER,
  table_name VARCHAR2(30 BYTE),
  obj_to_view_path VARCHAR2(255 BYTE),
  col_to_select VARCHAR2(255 BYTE),
  viewing_format VARCHAR2(255 BYTE),
  name_obj_recvd VARCHAR2(20 BYTE),
  name_obj_to_view VARCHAR2(20 BYTE),
  dev NUMBER
);
ALTER TABLE sa.table_receipts_directives ADD SUPPLEMENTAL LOG GROUP dmtsora1284180870_0 (col_to_select, dev, name_obj_recvd, name_obj_to_view, objid, obj_to_view_path, table_name, viewing_format) ALWAYS;