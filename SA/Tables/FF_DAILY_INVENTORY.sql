CREATE TABLE sa.ff_daily_inventory (
  warehouse VARCHAR2(10 BYTE),
  part_number VARCHAR2(50 BYTE),
  bko VARCHAR2(30 BYTE),
  on_hand VARCHAR2(30 BYTE),
  ff VARCHAR2(10 BYTE),
  insert_date DATE,
  file_name VARCHAR2(100 BYTE)
);