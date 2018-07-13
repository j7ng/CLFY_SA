CREATE TABLE sa.item_availability (
  site VARCHAR2(10 BYTE),
  item_code VARCHAR2(50 BYTE),
  qty_on_bko VARCHAR2(30 BYTE),
  qty_available VARCHAR2(30 BYTE),
  insert_date DATE,
  file_name VARCHAR2(100 BYTE)
);