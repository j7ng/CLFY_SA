CREATE TABLE sa.new_promo_sql (
  x_promo_code VARCHAR2(10 BYTE),
  x_sql_statement VARCHAR2(2000 BYTE)
);
ALTER TABLE sa.new_promo_sql ADD SUPPLEMENTAL LOG GROUP dmtsora735969489_0 (x_promo_code, x_sql_statement) ALWAYS;