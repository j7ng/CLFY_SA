CREATE TABLE sa.x_defect_list (
  esn VARCHAR2(20 BYTE),
  insert_date DATE,
  checked_date DATE
);
ALTER TABLE sa.x_defect_list ADD SUPPLEMENTAL LOG GROUP dmtsora1380394705_0 (checked_date, esn, insert_date) ALWAYS;