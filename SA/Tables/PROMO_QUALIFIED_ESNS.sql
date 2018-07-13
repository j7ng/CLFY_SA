CREATE TABLE sa.promo_qualified_esns (
  item_code VARCHAR2(30 BYTE),
  esn VARCHAR2(20 BYTE),
  ship_in_date DATE,
  ship_start_date DATE,
  ship_end_date DATE,
  status VARCHAR2(255 BYTE),
  creation_date DATE,
  process_date DATE
);
ALTER TABLE sa.promo_qualified_esns ADD SUPPLEMENTAL LOG GROUP dmtsora950030729_0 (creation_date, esn, item_code, process_date, ship_end_date, ship_in_date, ship_start_date, status) ALWAYS;