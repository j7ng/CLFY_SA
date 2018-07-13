CREATE TABLE sa.table_new_receipts (
  objid NUMBER,
  table_name VARCHAR2(30 BYTE),
  lowid_of_obj_recvd NUMBER,
  receipt_date DATE,
  receipt_type VARCHAR2(1 BYTE),
  lowid_of_obj_to_view NUMBER,
  formatted_id VARCHAR2(255 BYTE),
  name_obj_recvd VARCHAR2(20 BYTE),
  name_obj_to_view VARCHAR2(20 BYTE),
  dev NUMBER
);
ALTER TABLE sa.table_new_receipts ADD SUPPLEMENTAL LOG GROUP dmtsora1295199603_0 (dev, formatted_id, lowid_of_obj_recvd, lowid_of_obj_to_view, name_obj_recvd, name_obj_to_view, objid, receipt_date, receipt_type, table_name) ALWAYS;