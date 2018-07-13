CREATE TABLE sa.x_promotion_code_pool (
  part_serial_no VARCHAR2(30 BYTE),
  x_red_code VARCHAR2(30 BYTE),
  x_creation_date DATE
);
ALTER TABLE sa.x_promotion_code_pool ADD SUPPLEMENTAL LOG GROUP dmtsora1986338297_0 (part_serial_no, x_creation_date, x_red_code) ALWAYS;