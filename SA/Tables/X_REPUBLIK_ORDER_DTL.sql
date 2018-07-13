CREATE TABLE sa.x_republik_order_dtl (
  toss_order_id NUMBER NOT NULL,
  product_code VARCHAR2(10 BYTE),
  transpose_part_no VARCHAR2(40 BYTE),
  part_serial_no VARCHAR2(20 BYTE),
  promo_code VARCHAR2(10 BYTE),
  shipment_tracking_id VARCHAR2(50 BYTE)
);
ALTER TABLE sa.x_republik_order_dtl ADD SUPPLEMENTAL LOG GROUP dmtsora414917089_0 (part_serial_no, product_code, promo_code, shipment_tracking_id, toss_order_id, transpose_part_no) ALWAYS;